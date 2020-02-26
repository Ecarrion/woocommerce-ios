import Foundation
import UIKit
import Gridicons


/// WooCommerce UIImage Assets
///
extension UIImage {

    /// Add Icon
    ///
    static var addOutlineImage: UIImage {
        return Gridicon.iconOfType(.addOutline)
    }

    /// Notice Icon
    ///
    static var noticeImage: UIImage {
        let tintColor = UIColor.listIcon
        return Gridicon.iconOfType(.notice).imageWithTintColor(tintColor)!
    }

    /// Aside Image
    ///
    static var asideImage: UIImage {
        return Gridicon.iconOfType(.aside)
            .imageFlippedForRightToLeftLayoutDirection()
    }

    /// Bell Icon
    ///
    static var bellImage: UIImage {
        return Gridicon.iconOfType(.bell)
    }

    /// Camera Icon
    ///
    static var cameraImage: UIImage {
        return Gridicon.iconOfType(.camera)
            .imageFlippedForRightToLeftLayoutDirection()
            .applyTintColor(.placeholderImage)!
    }

    /// Add Image icon
    ///
    static var addImage: UIImage {
        let tintColor = UIColor.neutral(.shade40)
        return Gridicon.iconOfType(.addImage).imageWithTintColor(tintColor)!
    }

    /// Checkmark image, no style applied
    ///
    static var checkmarkImage: UIImage {
        return Gridicon.iconOfType(.checkmark)
    }

    /// WooCommerce Styled Checkmark
    ///
    static var checkmarkStyledImage: UIImage {
        let tintColor = UIColor.primary
        return checkmarkImage.imageWithTintColor(tintColor)!
    }

    /// Chevron Pointing Right
    ///
    static var chevronImage: UIImage {
        let tintColor = UIColor.neutral(.shade40)
        return Gridicon.iconOfType(.chevronRight).imageWithTintColor(tintColor)!
    }

    /// Chevron Pointing Down
    ///
    static var chevronDownImage: UIImage {
        return Gridicon.iconOfType(.chevronDown)
    }

    /// Chevron Pointing Up
    ///
    static var chevronUpImage: UIImage {
        return Gridicon.iconOfType(.chevronUp)
    }

    /// Close bar button item
    ///
    static var closeButton: UIImage {
        return Gridicon.iconOfType(.cross)
    }

    /// Cog Icon
    ///
    static var cogImage: UIImage {
        return Gridicon.iconOfType(.cog)
    }

    /// Comment Icon
    ///
    static var commentImage: UIImage {
        return Gridicon.iconOfType(.comment)
    }

    /// Delete Icon
    ///
    static var deleteImage: UIImage {
        let tintColor = UIColor.primary
        return Gridicon.iconOfType(.crossCircle)
            .imageWithTintColor(tintColor)!
            .imageFlippedForRightToLeftLayoutDirection()
    }

    /// Ellipsis Icon
    ///
    static var ellipsisImage: UIImage {
        return Gridicon.iconOfType(.ellipsis)
            .imageFlippedForRightToLeftLayoutDirection()
    }

    /// Empty Products Icon
    ///
    static var emptyProductsImage: UIImage {
        return UIImage(named: "woo-empty-products")!
    }

    /// Empty Reviews Icon
    ///
    static var emptyReviewsImage: UIImage {
        return UIImage(named: "woo-empty-reviews")!
    }

    /// Error State Image
    ///
    static var errorStateImage: UIImage {
        return UIImage(named: "woo-error-state")!
    }

    /// External Link Icon
    ///
    static var externalImage: UIImage {
        return Gridicon.iconOfType(.external)
            .imageFlippedForRightToLeftLayoutDirection()
    }

    /// Filter Icon
    ///
    static var filterImage: UIImage {
        return Gridicon.iconOfType(.filter)
    }

    /// Gift Icon (with a red dot at the top right corner)
    ///
    static var giftWithTopRightRedDotImage: UIImage {
        guard let image = Gridicon.iconOfType(.gift, withSize: CGSize(width: 24, height: 24))
            // Applies a constant gray color that looks fine in both Light/Dark modes, since we are generating an image with multiple colors.
            .applyTintColor(.gray(.shade30))?
            .imageWithTopRightDot(imageOrigin: CGPoint(x: 0, y: 2),
                                  finalSize: CGSize(width: 26, height: 26)) else {
                                    fatalError()
        }
        return image
    }

    /// Gravatar Placeholder Image
    ///
    static var gravatarPlaceholderImage: UIImage {
        return UIImage(named: "gravatar")!
    }

    /// Heart Outline
    ///
    static var heartOutlineImage: UIImage {
        return Gridicon.iconOfType(.heartOutline)
    }

    /// Login prologue slanted rectangle
    ///
    static var slantedRectangle: UIImage {
        return UIImage(named: "prologue-slanted-rectangle")!
    }

    /// Inventory Icon
    ///
    static var inventoryImage: UIImage {
        return Gridicon.iconOfType(.listCheckmark, withSize: CGSize(width: 24, height: 24))
    }

    /// Jetpack Logo Image
    ///
    static var jetpackLogoImage: UIImage {
        return UIImage(named: "icon-jetpack-gray")!
    }

    /// Info Icon
    ///
    static var infoImage: UIImage {
        return Gridicon.iconOfType(.info, withSize: CGSize(width: 24, height: 24))
    }

    /// Invisible Image
    ///
    static var invisibleImage: UIImage {
        return Gridicon.iconOfType(.image)
    }

    /// Login magic link
    ///
    static var loginMagicLinkImage: UIImage {
        return UIImage(named: "logic-magic-link")!
    }

    /// Login site address info
    ///
    static var loginSiteAddressInfoImage: UIImage {
        return UIImage(named: "login-site-address-info")!
    }

    /// Mail Icon
    ///
    static var mailImage: UIImage {
        return Gridicon.iconOfType(.mail)
    }

    /// More Icon
    ///
    static var moreImage: UIImage {
        let tintColor = UIColor.primary
        return ellipsisImage.imageWithTintColor(tintColor)!
    }

    /// Price Icon
    ///
    static var priceImage: UIImage {
        return Gridicon.iconOfType(.money, withSize: CGSize(width: 24, height: 24))
    }

    /// Product Placeholder Image
    ///
    static var productPlaceholderImage: UIImage {
        let tintColor = UIColor.listIcon
        return Gridicon.iconOfType(.product).imageWithTintColor(tintColor)!
    }

    /// Product Placeholder Image on Products Tab Cell
    ///
    static var productsTabProductCellPlaceholderImage: UIImage {
        let tintColor = UIColor.listSmallIcon
        return Gridicon
            .iconOfType(.product, withSize: CGSize(width: 20, height: 20))
            .imageWithTintColor(tintColor)!
    }

    /// Work In Progress banner icon on the Products Tab
    ///
    static var workInProgressBanner: UIImage {
        let tintColor = UIColor.gray(.shade30)
        return UIImage(named: "icon-tools")!
            .imageWithTintColor(tintColor)!
    }

    /// Product Image
    ///
    static var productImage: UIImage {
        return Gridicon.iconOfType(.product)
    }

    /// Pencil Icon
    ///
    static var pencilImage: UIImage {
        let tintColor = UIColor.primary
        return Gridicon.iconOfType(.pencil)
            .imageWithTintColor(tintColor)!
            .imageFlippedForRightToLeftLayoutDirection()
    }

    /// Quote Image
    ///
    static var quoteImage: UIImage {
        return Gridicon.iconOfType(.quote)
    }

    /// Pages Icon
    ///
    static var pagesImage: UIImage {
        return Gridicon.iconOfType(.pages)
            .imageFlippedForRightToLeftLayoutDirection()
    }

    /// Search Icon
    ///
    static var searchImage: UIImage {
        return Gridicon.iconOfType(.search)
            .imageFlippedForRightToLeftLayoutDirection()
    }

    /// Shipping Icon
    ///
    static var shippingImage: UIImage {
        return Gridicon.iconOfType(.shipping, withSize: CGSize(width: 24, height: 24))
    }

    /// Shipping class list selector empty icon
    ///
    static var shippingClassListSelectorEmptyImage: UIImage {
        return Gridicon.iconOfType(.shipping, withSize: CGSize(width: 80, height: 80))
    }

    /// Spam Icon
    ///
    static var spamImage: UIImage {
        return Gridicon.iconOfType(.spam)
    }

    /// Returns a star icon with the given size
    ///
    /// - Parameters:
    ///   - size: desired size of the resulting star icon
    /// - Returns: a bitmap image
    ///
    static func starImage(size: Double) -> UIImage {
        let starSize = CGSize(width: size, height: size)
        return Gridicon.iconOfType(.star,
                                   withSize: starSize)
    }

    /// Returns a star outline icon with the given size
    ///
    /// - Parameters:
    ///   - size: desired size of the resulting star icon
    /// - Returns: a bitmap image
    ///
    static func starOutlineImage(size: Double) -> UIImage {
        let starSize = CGSize(width: size, height: size)
        return Gridicon.iconOfType(.starOutline,
                                   withSize: starSize)
    }

    /// Stats Icon
    ///
    static var statsImage: UIImage {
        return Gridicon.iconOfType(.stats)
        .imageFlippedForRightToLeftLayoutDirection()
    }

    /// Stats Alt Icon
    ///
    static var statsAltImage: UIImage {
        return Gridicon.iconOfType(.statsAlt)
        .imageFlippedForRightToLeftLayoutDirection()
    }

    /// Trash Can Icon
    ///
    static var trashImage: UIImage {
        return Gridicon.iconOfType(.trash)
    }

    /// Creates a bitmap image of the Woo "bubble" logo based on a vector image in our asset catalog.
    ///
    /// - Parameters:
    ///   - size: desired size of the resulting bitmap image
    ///   - tintColor: desired tint color of the resulting bitmap image
    /// - Returns: a bitmap image
    ///
    static func wooLogoImage(withSize size: CGSize = Metrics.defaultWooLogoSize, tintColor: UIColor = .white) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        let vectorImage = UIImage(named: "woo-logo")!
        let renderer = UIGraphicsImageRenderer(size: size)
        let im2 = renderer.image { ctx in
            vectorImage.draw(in: rect)
        }

        return im2.imageWithTintColor(tintColor)
    }

    /// Waiting for Customers Image
    ///
    static var waitingForCustomersImage: UIImage {
        return UIImage(named: "woo-waiting-customers")!
    }
}

private extension UIImage {

    enum Metrics {
        static let defaultWooLogoSize = CGSize(width: 30, height: 18)
    }
}
