import Foundation
import Networking
import Storage


// MARK: - OrderStore
//
public class NotificationStore: Store {

    /// Thread Safety
    ///
    private static let lock = NSLock()

    /// Shared private StorageType for use during then entire notification sync process
    ///
    private static var privateStorage: StorageType!

    /// Registers for supported Actions.
    ///
    override public func registerSupportedActions(in dispatcher: Dispatcher) {
        dispatcher.register(processor: self, for: NotificationAction.self)
    }

    /// Receives and executes Actions.
    ///
    override public func onAction(_ action: Action) {
        guard let action = action as? NotificationAction else {
            assertionFailure("NotificationStore received an unsupported action")
            return
        }

        switch action {
        case .synchronizeNotifications(let onCompletion):
            synchronizeNotifications(onCompletion: onCompletion)
        case .updateLastSeen(let timestamp, let onCompletion):
            updateLastSeen(timestamp: timestamp, onCompletion: onCompletion)
        case .updateReadStatus(let noteID, let read, let onCompletion):
            updateReadStatus(noteID: noteID, read: read, onCompletion: onCompletion)
        }
    }
}


// MARK: - Services!
//
private extension NotificationStore {

    /// Retrieves the latest notifications (if any!).
    ///
    func synchronizeNotifications(onCompletion: @escaping (Error?) -> Void) {
        let remote = NotificationsRemote(network: network)

        remote.loadHashes(pageSize: Constants.maximumPageSize) { [weak self] (hashes, error) in
            guard let hashes = hashes else {
                onCompletion(error)
                return
            }

            self?.deleteLocalMissingNotes(from: hashes) { [weak self] in

                self?.determineUpdatedNotes(using: hashes) { outdatedIDs in

                    guard outdatedIDs.isEmpty == false else {
                        onCompletion(nil)
                        return
                    }

                    remote.loadNotes(noteIds: outdatedIDs, pageSize: Constants.maximumPageSize) { [weak self] (notes, error) in

                        guard let notes = notes else {
                            onCompletion(error)
                            return
                        }

                        self?.updateLocalNotes(with: notes) {
                            onCompletion(nil)
                        }
                    }
                }
            }
        }
    }

    

    /// Updates the last seen notification
    ///
    func updateLastSeen(timestamp: String, onCompletion: @escaping (Error?) -> Void) {
        let remote = NotificationsRemote(network: network)
        remote.updateLastSeen(timestamp) { (error) in
            onCompletion(error)
        }
    }

    /// Updates the read status for the given notification ID
    ///
    func updateReadStatus(noteID: Int64, read: Bool, onCompletion: @escaping (Error?) -> Void) {
        let remote = NotificationsRemote(network: network)
        remote.updateReadStatus(String(noteID), read: read) { [weak self] (error) in
            guard let `self` = self, error == nil else {
                onCompletion(error)
                return
            }

            self.updateLocalNoteReadStatus(for: noteID, read: read) {
                onCompletion(nil)
            }
        }
    }
}


// MARK: - Persistence
//
extension NotificationStore {

    /// Deletes the collection of local notifications that cannot be found in a given collection of
    /// remote hashes.
    ///
    /// - Parameter remoteIds: Collection of remote Note IDs.
    ///
    func deleteLocalMissingNotes(from hashes: [NoteHash], completion: @escaping (() -> Void)) {
        let derivedStorage = type(of: self).sharedDerivedStorage(with: storageManager)

        derivedStorage.perform {
            // The beauty of threadsafe Immutable Entities!!
            let remoteIDs = hashes.map { $0.noteID }
            let predicate = NSPredicate(format: "NOT (noteID IN %@)", remoteIDs)

            for orphan in derivedStorage.allObjects(ofType: Storage.Note.self, matching: predicate, sortedBy: nil) {
                derivedStorage.deleteObject(orphan)
            }
        }

        storageManager.saveDerivedType(derivedStorage: derivedStorage) {
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    /// Given a collection of Notes, this method will insert missing local ones, and update the others that can be found.
    ///
    /// - Parameters:
    ///     - remoteNotes: Collection of Notes
    ///     - completion: Callback to be executed on completion
    ///
    func updateLocalNotes(with remoteNotes: [Note], completion: (() -> Void)? = nil) {
        let derivedStorage = type(of: self).sharedDerivedStorage(with: storageManager)

        derivedStorage.perform {
            for remoteNote in remoteNotes {
                let localNote = derivedStorage.loadNotification(noteID: remoteNote.noteId) ?? derivedStorage.insertNewObject(ofType: Storage.Note.self)
                localNote.update(with: remoteNote)
            }
        }

        storageManager.saveDerivedType(derivedStorage: derivedStorage) {
            DispatchQueue.main.async {
                completion?()
            }
        }
    }

    /// Updates the read status for the given noteID in the Storage layer. If the local note to update cannot be found,
    /// nothing is updated/created in storage.
    ///
    func updateLocalNoteReadStatus(for noteID: Int64, read: Bool, completion: (() -> Void)? = nil) {
        assert(Thread.isMainThread)
        let storage = storageManager.viewStorage
        guard let storageNote = storage.loadNotification(noteID: noteID) else {
            completion?()
            return
        }

        storageNote.read = read
        storage.saveIfNeeded()
        completion?()
    }

    /// Given a collection of NoteHash Entities, this method will determine the `.noteID`'s of those entities that
    /// are either not locally found, or got their `.hash` field outdated.
    ///
    func determineUpdatedNotes(using hashes: [NoteHash], completion: @escaping ([Int64]) -> Void) {
        let derivedStorage = type(of: self).sharedDerivedStorage(with: storageManager)

        derivedStorage.perform {
            let remoteIds = hashes.map { $0.noteID }
            let predicate = NSPredicate(format: "noteID IN %@", remoteIds)
            var localHashes = [Int64: Int64]()

            for note in derivedStorage.allObjects(ofType: StorageNote.self, matching: predicate, sortedBy: nil) {
                localHashes[note.noteID] = Int64(note.noteHash)
            }

            let outdated = hashes.filter { remote in
                let localHash = localHashes[remote.noteID]
                return localHash == nil || localHash != remote.hash
            }

            let outdatedIds = outdated.map { $0.noteID }

            DispatchQueue.main.async {
                completion(outdatedIds)
            }
        }
    }
}


// MARK: - Thread Safety Helpers
//
extension NotificationStore {
    /// Returns the current shared derived StorageType, if any. Otherwise proceeds to create a new
    /// derived StorageType, given a specified StorageManagerType.
    ///
    static func sharedDerivedStorage(with manager: StorageManagerType) -> StorageType {
        lock.lock()
        if privateStorage == nil {
            privateStorage = manager.newDerivedStorage()
        }
        lock.unlock()

        return privateStorage
    }

    /// Nukes the private Shared Derived Storage instance.
    ///
    static func resetSharedDerivedStorage() {
        privateStorage = nil
    }
}


// MARK: - Constants!
//
extension NotificationStore {

    enum Constants {
        static let maximumPageSize: Int = 100
    }
}