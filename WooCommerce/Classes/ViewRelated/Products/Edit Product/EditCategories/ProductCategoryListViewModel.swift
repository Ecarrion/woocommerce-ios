import Foundation
import Yosemite

final class ProductCategoryListViewModel {

    /// Represents the current state of `synchronizeProductCategories` action. Useful for the consumer to update it's UI upon changes
    ///
    enum SyncingState {
        case initialized
        case syncing(pageNumber: Int, pageSize: Int)
        case failed(pageNumber: Int, pageSize: Int)
        case synced
    }

    /// Product the user is editiing
    ///
    private let product: Product

    /// Closure to be invoked when `syncCoordinatorState` changes
    ///
    private var onSyncStateChange: ((SyncingState) -> Void)?

    /// Current `synchingCoordinator` state
    ///
    private var syncCoordinatorState: SyncingState = .initialized {
        didSet {
            onSyncStateChange?(syncCoordinatorState)
        }
    }

    /// SyncCoordinator: Keeps tracks of which pages have been refreshed, and encapsulates the "What should we sync now" logic.
    ///
    private lazy var syncingCoordinator: SyncingCoordinator = {
        let coordinator = SyncingCoordinator()
        coordinator.delegate = self
        return coordinator
    }()

    /// `ResultsController` that represents all stored product categories
    ///
    private lazy var resultController: ResultsController<StorageProductCategory> = {
        let storageManager = ServiceLocator.storageManager
        let predicate = NSPredicate(format: "siteID = %ld", self.product.siteID)
        let descriptor = NSSortDescriptor(keyPath: \StorageProductCategory.name, ascending: true)
        return ResultsController<StorageProductCategory>(storageManager: storageManager, matching: predicate, sortedBy: [descriptor])
    }()

    init(product: Product) {
        self.product = product
    }

    /// Returns the number sections.
    ///
    func numberOfSections() -> Int {
        return resultController.sections.count
    }

    /// Returns the number of items for a given `section` that should be displayed
    ///
    func numberOfRowsInSection(section: Int) -> Int {
        return resultController.sections[section].numberOfObjects
    }

    /// Returns a product category for a given `indexPath`
    ///
    func item(at indexPath: IndexPath) -> ProductCategory {
        return resultController.object(at: indexPath)
    }

    /// Load existing categories from storage and fire the synchronize product categories action
    ///
    func performInitialFetch() {
        try? resultController.performFetch()
        syncingCoordinator.resetInternalState()
        syncingCoordinator.synchronizeFirstPage()
    }

    /// Perform actions when an item is about to be displayed. Like fetching the next item page.
    ///
    func itemWillBeDisplayed(at indexPath: IndexPath) {
        let lastCategoryIndex = categoriesResultController.objectIndex(from: indexPath)
        syncingCoordinator.ensureNextPageIsSynchronized(lastVisibleIndex: lastCategoryIndex)
    }

    /// Observes and notifies of changes made to product categories
    /// Calling this method will remove any other previous observer.
    ///
    func observeCategoryListChanges(onReload: @escaping () -> (Void)) {
        categoriesResultController.onDidChangeContent = onReload
    }

    /// Observes and notifies of changes made to the underlying synching coordinator. The current state will be dispatched upon subscription.
    /// Calling this method will remove any other previous observer.
    ///
    func observeSyncStateChanges(onStateChanges: @escaping (SyncingState) -> Void) {
        onSyncStateChange = onStateChanges
        onSyncStateChange?(syncCoordinatorState)
    }

    /// Returns `true` if the receiver's product contains the given category. Otherwise returns `false`
    ///
    func isCategorySelected(_ category: ProductCategory) -> Bool {
        return product.categories.contains(category)
    }
}

// MARK: - Synchronize Categories
//
private extension ProductCategoryListViewModel {
    /// Synchronizes product categories with a given page number and page size.
    ///
    func syncronizeCategories(pageNumber: Int, pageSize: Int, onCompletion: @escaping ((Error?) -> Void)) {
        let action = ProductCategoryAction.synchronizeProductCategories(siteID: product.siteID, pageNumber: pageNumber, pageSize: pageSize) { error in
            if let error = error {
                DDLogError("⛔️ Error fetching product categories: \(error.localizedDescription)")
            }
            onCompletion(error)
        }
        ServiceLocator.stores.dispatch(action)
    }

    /// Subscribe an observer to `categoriesResultController` changes
    ///
    func observeResultControllerChanges(onReload: @escaping () -> (Void)) {
        categoriesResultController.onDidChangeContent = {
            onReload()
        }
    }
}

// MARK: - SyncingCoordinator Delegate
//
extension ProductCategoryListViewModel: SyncingCoordinatorDelegate {
    /// Synchronizes the ProductCategories for the Default Store (if any).
    ///
    func sync(pageNumber: Int, pageSize: Int, reason: String? = nil, onCompletion: ((Bool) -> Void)? = nil) {
        syncCoordinatorState = .syncing(pageNumber: pageNumber, pageSize: pageSize)
        syncronizeCategories(pageNumber: pageNumber, pageSize: pageSize) { [weak self] error in
            self?.syncCoordinatorState = .synced
            onCompletion?(error == nil)
        }
    }
}
