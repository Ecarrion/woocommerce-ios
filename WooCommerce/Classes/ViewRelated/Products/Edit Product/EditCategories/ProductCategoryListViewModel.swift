import Foundation
import Yosemite

final class ProductCategoryListViewModel {

    /// Obscure token that allows the view model to retry the synchronizeCategories operation
    ///
    struct RetryToken: Equatable {
        fileprivate let fromPageNumber: Int
    }

    /// Represents the current state of `synchronizeCategories` action. Useful for the consumer to update it's UI upon changes
    ///
    enum SyncingState: Equatable {
        case initialized
        case syncing
        case failed(RetryToken)
        case synced
    }

    /// Reference to the StoresManager to dispatch Yosemite Actions.
    ///
    private let storesManager: StoresManager

    /// Product the user is editiing
    ///
    private let product: Product

    /// Tracks the user category selection
    ///
    private(set) var selectedCategories: Set<ProductCategory> {
        didSet {
            guard selectedCategories != oldValue else {
                return
            }
            updateViewModelsArray()
        }
    }

    /// Array of view models to be rendered by the View Controller.
    ///
    private(set) var categoryViewModels: [ProductCategoryViewModel] = []

    /// Closure to be invoked when `synchronizeCategories` state  changes
    ///
    private var onSyncStateChange: ((SyncingState) -> Void)?

    /// Current  category synchronization state
    ///
    private var syncCategoriesState: SyncingState = .initialized {
        didSet {
            guard syncCategoriesState != oldValue else {
                return
            }
            onSyncStateChange?(syncCategoriesState)
        }
    }

    private lazy var resultController: ResultsController<StorageProductCategory> = {
        let storageManager = ServiceLocator.storageManager
        let predicate = NSPredicate(format: "siteID = %ld", self.product.siteID)
        let descriptor = NSSortDescriptor(keyPath: \StorageProductCategory.name, ascending: true)
        return ResultsController<StorageProductCategory>(storageManager: storageManager, matching: predicate, sortedBy: [descriptor])
    }()

    init(storesManager: StoresManager = ServiceLocator.stores, product: Product) {
        self.storesManager = storesManager
        self.product = product
        self.selectedCategories = Set(product.categories)
    }

    /// Load existing categories from storage and fire the synchronize all categories action.
    ///
    func performFetch() {
        synchronizeAllCategories()
        try? resultController.performFetch()
    }

    /// Retry product categories synchronization when `syncCategoriesState` is on a `.failed` state.
    ///
    func retryCategorySynchronization(retryToken: RetryToken) {
        guard syncCategoriesState == .failed(retryToken) else {
            return
        }
        synchronizeAllCategories(fromPageNumber: retryToken.fromPageNumber)
    }

    /// Observes and notifies of changes made to product categories. the current state will be dispatched upon subscription.
    /// Calling this method will remove any other previous observer.
    ///
    func observeCategoryListStateChanges(onStateChanges: @escaping (SyncingState) -> Void) {
        onSyncStateChange = onStateChanges
        onSyncStateChange?(syncCategoriesState)
    }

    /// Toggles a category selection state based on the provided `CategoryViewModel` indexPath
    ///
    func toggleSelectionOfCategory(at indexPath: IndexPath) {
        guard let category = productCategory(at: indexPath) else {
            return
        }
        toggleCategorySelection(category)
    }
}

// MARK: - Synchronize Categories
//
private extension ProductCategoryListViewModel {
    /// Synchronizes all product categories starting at a specific page number. Default initial page number is set on `Default.firstPageNumber`
    ///
    func synchronizeAllCategories(fromPageNumber: Int = Default.firstPageNumber) {
        self.syncCategoriesState = .syncing
        let action = ProductCategoryAction.synchronizeProductCategories(siteID: product.siteID, fromPageNumber: fromPageNumber) { [weak self] error in
            if let error = error {
                self?.handleSychronizeAllCategoriesError(error)
                return
            }
            self?.updateViewModelsArray()
            self?.syncCategoriesState = .synced
        }
        storesManager.dispatch(action)
    }

    /// Update `syncCategoriesState` with the proper retryToken
    ///
    func handleSychronizeAllCategoriesError(_ error: ProductCategoryActionError) {
        switch error {
        case let .categoriesSynchronization(pageNumber, rawError):
            let retryToken = RetryToken(fromPageNumber: pageNumber)
            syncCategoriesState = .failed(retryToken)
            DDLogError("⛔️ Error fetching product categories: \(rawError.localizedDescription)")
        }
    }

    /// Updates  `categoryViewModels` from  the resultController's fetched objects.
    ///
    func updateViewModelsArray() {
        let fetchedCategories = resultController.fetchedObjects
        categoryViewModels = ProductCategoryViewModelBuilder.viewModels(from: fetchedCategories, selectedCategories: selectedCategories)
    }
}

// MARK: - Category Selection
//
private extension ProductCategoryListViewModel {
    /// Maps a `CategoryViewModel` indexPath into a fetched `ProductCategory`
    ///
    func productCategory(at indexPath: IndexPath) -> ProductCategory? {
        let categoryViewModel = categoryViewModels[indexPath.row]
        return resultController.fetchedObjects.first {
            $0.categoryID == categoryViewModel.categoryID
        }
    }

    /// Toggle the a category selection state
    ///
    func toggleCategorySelection(_ category: ProductCategory) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }
}

// MARK: - Constants
//
private extension ProductCategoryListViewModel {
    enum Default {
        public static let firstPageNumber = 1
    }
}
