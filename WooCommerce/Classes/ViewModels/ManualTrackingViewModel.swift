import UIKit
import Foundation
import Yosemite

struct AddEditTrackingSection {
    let rows: [AddEditTrackingRow]
}

enum AddEditTrackingRow: CaseIterable {
    case shippingProvider
    case trackingNumber
    case dateShipped
    case deleteTracking
    case datePicker

    var type: UITableViewCell.Type {
        switch self {
        case .shippingProvider:
            return TitleAndEditableValueTableViewCell.self
        case .trackingNumber:
            return TitleAndEditableValueTableViewCell.self
        case .dateShipped:
            return TitleAndEditableValueTableViewCell.self
        case .deleteTracking:
            return BasicTableViewCell.self
        case .datePicker:
            return DatePickerTableViewCell.self
        }
    }

    var reuseIdentifier: String {
        return type.reuseIdentifier
    }
}


/// Abstracts the different viewmodels supporting adding, editing and creating custom
/// shipment trackings
///
protocol ManualTrackingViewModel {
    var siteID: Int { get }
    var orderID: Int { get }
    var title: String { get }
    var providerCellName: String { get }
    var primaryActionTitle: String { get }
    var secondaryActionTitle: String? { get }

    var sections: [AddEditTrackingSection] { get }
    var trackingNumber: String? { get set }
    var shipmentDate: Date { get set }
    var shipmentTracking: ShipmentTracking? { get }

    var shipmentProvider: ShipmentTrackingProvider? { get set }
    var shipmentProviderGroupName: String? { get set }

    var canCommit: Bool { get }
    var isCustom: Bool { get }
    var isAdding: Bool { get }

    func registerCells(for tableView: UITableView)
}

extension ManualTrackingViewModel {
    func registerCells(for tableView: UITableView) {
        for row in AddEditTrackingRow.allCases {
            tableView.register(row.type.loadNib(),
                               forCellReuseIdentifier: row.reuseIdentifier)
        }
    }
}


/// View model supporting adding shipment tacking manually, using non-custom providers
///
final class AddTrackingViewModel: ManualTrackingViewModel {
    let siteID: Int
    let orderID: Int

    let title = NSLocalizedString("Add Tracking",
                                 comment: "Add tracking screen - title.")

    let primaryActionTitle = NSLocalizedString("Add",
                                               comment: "Add tracking screen - button title to add a tracking")
    let secondaryActionTitle: String? = nil

    let shipmentTracking: ShipmentTracking? = nil

    var trackingNumber: String?

    var shipmentDate = Date()

    var sections: [AddEditTrackingSection] {
        let trackingRows: [AddEditTrackingRow] = [.shippingProvider,
                                                      .trackingNumber,
                                                      .dateShipped,
                                                      .datePicker]

        return [
            AddEditTrackingSection(rows: trackingRows)]

    }

    var shipmentProvider: ShipmentTrackingProvider?
    var shipmentProviderGroupName: String?

    var providerCellName: String {
        return shipmentProvider?.name ?? ""
    }

    var canCommit: Bool {
        return shipmentProvider != nil &&
            trackingNumber != nil
    }

    let isAdding: Bool = true

    let isCustom: Bool = false

    init(siteID: Int, orderID: Int) {
        self.siteID = siteID
        self.orderID = orderID
    }
}
