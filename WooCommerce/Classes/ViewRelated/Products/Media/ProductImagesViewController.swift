import Photos
import UIKit
import WPMediaPicker
import Yosemite

/// Displays Product images with edit functionality.
///
final class ProductImagesViewController: UIViewController {
    typealias Completion = (_ images: [ProductImage]) -> Void

    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var addButtonBottomBorderView: UIView!
    @IBOutlet private weak var imagesContainerView: UIView!

    private let siteID: Int64
    private let productID: Int64
    private let productImagesService: ProductImagesService
    private var productImages: [ProductImage] {
        return productImageStatuses.compactMap { status in
            switch status {
            case .remote(let productImage):
                return productImage
            default:
                return nil
            }
        }
    }

    private var productImageStatuses: [ProductImageStatus] {
        didSet {
            imagesViewController.updateProductImages(productImageStatuses)
        }
    }

    // Child view controller.
    private lazy var imagesViewController: ProductImagesCollectionViewController = {
        let viewController = ProductImagesCollectionViewController(images: productImageStatuses,
                                                                   onDeletion: onDeletion)
        return viewController
    }()

    private lazy var mediaPickingCoordinator: MediaPickingCoordinator = {
        return MediaPickingCoordinator(siteID: siteID,
                                       onCameraCaptureCompletion: self.onCameraCaptureCompletion,
                                       onDeviceMediaLibraryPickerCompletion: self.onDeviceMediaLibraryPickerCompletion(assets:),
                                       onWPMediaPickerCompletion: self.onWPMediaPickerCompletion(mediaItems:))
    }()

    private let onCompletion: Completion

    init(product: Product, productImagesService: ProductImagesService, completion: @escaping Completion) {
        self.siteID = product.siteID
        self.productID = product.productID
        self.productImagesService = productImagesService
        self.productImageStatuses = product.images.map({ ProductImageStatus.remote(image: $0) })
        self.onCompletion = completion
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureMainView()
        configureNavigation()
        configureAddButton()
        configureAddButtonBottomBorderView()
        configureImagesContainerView()
    }
}

// MARK: - UI configurations
//
private extension ProductImagesViewController {
    func configureMainView() {
        view.backgroundColor = .basicBackground
    }

    func configureNavigation() {
        title = NSLocalizedString("Photos", comment: "Product images (Product images page title)")

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(completeEditing))

        removeNavigationBackBarButtonText()
    }

    func configureAddButton() {
        addButton.setTitle(NSLocalizedString("Add Photos", comment: "Action to add photos on the Product images screen"), for: .normal)
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        addButton.applySecondaryButtonStyle()
    }

    func configureAddButtonBottomBorderView() {
        addButtonBottomBorderView.backgroundColor = .systemColor(.separator)
    }

    func configureImagesContainerView() {
        imagesContainerView.backgroundColor = .basicBackground

        addChild(imagesViewController)
        imagesContainerView.addSubview(imagesViewController.view)
        imagesViewController.didMove(toParent: self)

        imagesViewController.view.translatesAutoresizingMaskIntoConstraints = false
        imagesContainerView.pinSubviewToSafeArea(imagesViewController.view)
    }
}

// MARK: - Actions
//
private extension ProductImagesViewController {

    @objc func addTapped() {
        showOptionsMenu()
    }

    @objc func completeEditing() {
        onCompletion(productImages)
    }

    func showOptionsMenu() {
        let pickingContext = MediaPickingContext(origin: self, view: addButton)
        mediaPickingCoordinator.present(context: pickingContext)
    }

    func onDeletion(productImage: ProductImage) {
        productImageStatuses.removeAll { (status) -> Bool in
            guard case .remote(let image) = status else {
                return false
            }
            return image.imageID == productImage.imageID
        }
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Image upload to WP Media Library and Product
// TODO-jc: move these to a Product Images service
private extension ProductImagesViewController {
    func uploadMediaAssetToSiteMediaLibraryThenAddToProduct(asset: PHAsset) {
        productImagesService.uploadMediaAssetToSiteMediaLibrary(asset: asset) { [weak self] (productImage, error) in
            guard let self = self else {
                return
            }
            guard let assetIndex = self.index(of: asset) else {
                self.showErrorAlert(error: nil)
                return
            }
            guard let productImage = productImage, error == nil else {
                self.updateProductImageStatus(at: assetIndex, error: error)
                return
            }
            self.updateProductImageStatus(at: assetIndex, productImage: productImage)
        }
    }

    func updateProductImageStatus(at index: Int, productImage: ProductImage) {
        productImageStatuses[index] = .remote(image: productImage)
    }

    func updateProductImageStatus(at index: Int, error: Error?) {
        // TODO
        showErrorAlert(error: error)
        productImageStatuses.remove(at: index)
    }

    func index(of asset: PHAsset) -> Int? {
        return productImageStatuses.firstIndex(where: { status -> Bool in
            switch status {
            case .uploading(let uploadingAsset):
                return uploadingAsset == asset
            default:
                return false
            }
        })
    }

    func addMediaToProduct(mediaItems: [Media]) {
        let newProductImageStatuses = mediaItems.map({
            ProductImage(imageID: $0.mediaID,
            dateCreated: Date(),
            dateModified: nil,
            src: $0.src,
            name: $0.name,
            alt: $0.alt)
        }).map({ ProductImageStatus.remote(image: $0) })
        self.productImageStatuses = newProductImageStatuses + productImageStatuses
    }
}

// MARK: - Action handling for camera capture
//
private extension ProductImagesViewController {
    func onCameraCaptureCompletion(asset: PHAsset?, error: Error?) {
        guard let asset = asset else {
            showErrorAlert(error: error)
            return
        }
        productImageStatuses = [.uploading(asset: asset)] + productImageStatuses
        uploadMediaAssetToSiteMediaLibraryThenAddToProduct(asset: asset)
    }
}

// MARK: Action handling for device media library picker
//
private extension ProductImagesViewController {
    func onDeviceMediaLibraryPickerCompletion(assets: [PHAsset]) {
        defer {
            dismiss(animated: true, completion: nil)
        }
        guard assets.isEmpty == false else {
            return
        }
        assets.forEach { asset in
            productImageStatuses = [.uploading(asset: asset)] + productImageStatuses
            uploadMediaAssetToSiteMediaLibraryThenAddToProduct(asset: asset)
        }
    }
}


// MARK: - Action handling for WordPress Media Library
//
private extension ProductImagesViewController {
    func onWPMediaPickerCompletion(mediaItems: [Media]) {
        addMediaToProduct(mediaItems: mediaItems)
    }
}

// MARK: Error handling
//
private extension ProductImagesViewController {
    func showErrorAlert(error: Error?) {
        let title = NSLocalizedString("Cannot upload image", comment: "")
        let alertController = UIAlertController(title: title,
                                                message: error?.localizedDescription,
                                                preferredStyle: .alert)
        let cancel = UIAlertAction(title: NSLocalizedString(
            "OK",
            comment: "Dismiss button on the alert when there is an error updating the product"
        ), style: .cancel, handler: nil)
        alertController.addAction(cancel)
        present(alertController, animated: true)
    }
}

// MARK: Error handling
//
private extension ProductImagesViewController {
    func displayErrorAlert(error: Error?) {
        let title = NSLocalizedString("Cannot upload image", comment: "Title of the alert when there is an error uploading image(s)")
        let alertController = UIAlertController(title: title,
                                                message: error?.localizedDescription,
                                                preferredStyle: .alert)
        let cancel = UIAlertAction(title: NSLocalizedString("OK",
                                                            comment: "Dismiss button on the alert when there is an error uploading image(s)"),
                                   style: .cancel,
                                   handler: nil)
        alertController.addAction(cancel)
        present(alertController, animated: true)
    }
}
