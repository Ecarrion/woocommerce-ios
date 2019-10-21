import UIKit

// MARK: - WooBasicTableViewCell

/// A UITableViewCell with bonus purple Woo styling.
///
/// So `BasicTableViewCell` uses springs and struts, causing
/// a different leading margin ("left margin") measurement than
/// a custom cell. Custom cells follow the superview margin. Custom
/// cells set a 20 point leading margin on an iPhone XS Max.
/// But a BasicTableViewCell sets the leading margin to 16 points.
/// So here we are, building a `BasicTableViewCell` as a custom cell,
/// so that the margins match. --- ¯\_(ツ)_/¯ 21.05.2019 tc
///
class WooBasicTableViewCell: UITableViewCell {

    @IBOutlet weak var bodyLabel: UILabel!

    public var accessoryImage: UIImage? {
        didSet {
            configureAccessoryView()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        configureBackground()
        configureSelectionStyle()
        configureLabel()
    }

    func configureBackground() {
        applyDefaultBackgroundStyle()
    }

    /// Set up the cell selection style
    ///
    func configureSelectionStyle() {
        selectionStyle = .default
    }

    /// Style the label(s)
    ///
    func configureLabel() {
        bodyLabel?.applyBodyStyle()
        bodyLabel?.textColor = StyleManager.wooCommerceBrandColor
    }

    /// Add the accessoryView image, if any
    ///
    func configureAccessoryView() {
        guard let accessoryImage = accessoryImage else {
            accessoryView = nil
            return
        }
        let accessoryImageView = UIImageView(image: accessoryImage)
        accessoryImageView.tintColor = StyleManager.buttonPrimaryColor
        accessoryView = accessoryImageView
    }
}
