import Foundation
import XCTest

class OrdersScreen: BaseScreen {

    struct ElementStringIDs {
        static let searchButton = "order-search-button"
        static let filterButton = "order-filter-button"
    }

    let tabBar = TabNavComponent()
    let searchButton: XCUIElement
    let filterButton: XCUIElement

    static var isVisible: Bool {
        let searchButton = XCUIApplication().buttons[ElementStringIDs.searchButton]
        return searchButton.exists && searchButton.isHittable
    }

    init() {
        searchButton = XCUIApplication().buttons[ElementStringIDs.searchButton]
        filterButton = XCUIApplication().buttons[ElementStringIDs.filterButton]

        super.init(element: searchButton)
    }

    func selectOrder(atIndex index: Int) -> SingleOrderScreen {
        XCUIApplication().cells.element(boundBy: index).tap()
        return SingleOrderScreen()
    }

    func openSearchPane() -> OrderSearchScreen {
        searchButton.tap()
        return OrderSearchScreen()
    }
}
