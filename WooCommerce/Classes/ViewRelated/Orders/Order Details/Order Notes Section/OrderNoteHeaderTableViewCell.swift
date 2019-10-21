import UIKit

// MARK: - OrderNoteHeaderTableViewCell
//
final class OrderNoteHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        configureLabels()
    }

    /// Date of Creation: To be displayed in the cell
    ///
    var dateCreated: String? {
        get {
            return dateLabel.text
        }
        set {
            dateLabel.text = newValue
        }
    }

}

// MARK: - Private Methods
//
extension OrderNoteHeaderTableViewCell {

    /// Setup: Labels
    ///
    fileprivate func configureLabels() {
        dateLabel.applyHeadlineStyle()
    }
}
