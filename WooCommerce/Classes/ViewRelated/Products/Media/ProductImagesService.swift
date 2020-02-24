import Yosemite

/// Encapsulates the implementation of Product images actions from the UI.
///
struct ProductImagesService {
    private let siteID: Int64

    init(siteID: Int64) {
        self.siteID = siteID
    }

    func uploadMediaAssetToSiteMediaLibrary(asset: ExportableAsset,
                                            completion: @escaping (_ image: ProductImage?, _ error: Error?) -> Void) {
        let action = MediaAction.uploadMedia(siteID: siteID,
                                             mediaAsset: asset) { (media, error) in
                                                guard let media = media else {
                                                    DispatchQueue.main.async {
                                                        completion(nil, error)
                                                    }
                                                    return
                                                }
                                                let productImage = ProductImage(imageID: media.mediaID,
                                                                                dateCreated: media.date,
                                                                                dateModified: media.date,
                                                                                src: media.src,
                                                                                name: media.name,
                                                                                alt: media.alt)
                                                DispatchQueue.main.async {
                                                    completion(productImage, nil)
                                                }
        }
        ServiceLocator.stores.dispatch(action)
    }
}
