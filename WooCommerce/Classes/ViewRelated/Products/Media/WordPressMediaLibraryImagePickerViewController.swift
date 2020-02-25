import UIKit
import WPMediaPicker
import CoreServices
import Yosemite

final class WordPressMediaLibraryImagePickerViewController: UIViewController {
    typealias Completion = ((_ selectedMediaItems: [Media]) -> Void)
    private let onCompletion: Completion

    private lazy var mediaPickerOptions: WPMediaPickerOptions = {
        let options = WPMediaPickerOptions()
        options.showMostRecentFirst = true
        options.filter = [.image]
        options.allowCaptureOfMedia = false
        options.showSearchBar = false
        options.showActionBar = false
        options.badgedUTTypes = [String(kUTTypeGIF)]
        options.allowMultipleSelection = true
        return options
    }()

    private var mediaLibraryDataSource: WordPressMediaLibraryPickerDataSource?

    private var picker: WPNavigationMediaPickerViewController!

    private let siteID: Int64

    init(siteID: Int64, onCompletion: @escaping Completion) {
        self.siteID = siteID
        self.onCompletion = onCompletion
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let picker = WPNavigationMediaPickerViewController()
        mediaLibraryDataSource = WordPressMediaLibraryPickerDataSource(siteID: siteID)
        picker.dataSource = mediaLibraryDataSource
        picker.startOnGroupSelector = false
        picker.showGroupSelector = false
        picker.mediaPicker.options = mediaPickerOptions
        picker.delegate = self
        picker.modalPresentationStyle = .currentContext
        picker.mediaPicker.collectionView?.backgroundColor = .listBackground

        let emptyImagesText = NSLocalizedString("No images yet",
                                                comment: "Placeholder text shown when there are no images for the WordPress Media Library yet")
        picker.mediaPicker.defaultEmptyView.text = emptyImagesText
        self.picker = picker

        picker.view.translatesAutoresizingMaskIntoConstraints = false

        add(picker)
        view.pinSubviewToAllEdges(picker.view)
    }
}

extension WordPressMediaLibraryImagePickerViewController: WPMediaPickerViewControllerDelegate {
    func mediaPickerController(_ picker: WPMediaPickerViewController, didFinishPicking assets: [WPMediaAsset]) {
        onCompletion(assets as? [Media] ?? [])
        dismiss(animated: true)
    }

    func mediaPickerControllerDidCancel(_ picker: WPMediaPickerViewController) {
        dismiss(animated: true)
    }
}
