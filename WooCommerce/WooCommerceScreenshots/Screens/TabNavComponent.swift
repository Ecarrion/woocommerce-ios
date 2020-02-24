import Foundation
import XCTest

class TabNavComponent: BaseScreen {

    struct ElementStringIDs {
        static let myStoreTabBarItem = "tab-bar-my-store-item"
        static let ordersTabBarItem = "tab-bar-orders-item"
        static let reviewsTabBarItem = "tab-bar-reviews-item"
    }


    let myStoreTabButton: XCUIElement
    let ordersTabButton: XCUIElement
    let reviewsTabButton: XCUIElement

    init() {
        let tabBar = XCUIApplication().tabBars.firstMatch

        myStoreTabButton = tabBar.buttons[ElementStringIDs.myStoreTabBarItem]
        ordersTabButton = tabBar.buttons[ElementStringIDs.ordersTabBarItem]
        reviewsTabButton = tabBar.buttons[ElementStringIDs.reviewsTabBarItem]

        super.init(element: myStoreTabButton)

        XCTAssert(myStoreTabButton.waitForExistence(timeout: 3))
        XCTAssert(ordersTabButton.waitForExistence(timeout: 3))
    }

    @discardableResult
    func gotoMyStoreScreen() -> MyStoreScreen {
        // Avoid transitioning if it is already on screen
        if !MyStoreScreen.isVisible {
            myStoreTabButton.tap()
        }
        return MyStoreScreen()
    }

    @discardableResult
    func gotoOrdersScreen() -> OrdersScreen {
        // Avoid transitioning if it is already on screen
        if !OrdersScreen.isVisible {
            ordersTabButton.tap()
        }

        return OrdersScreen()
    }

    @discardableResult
    func gotoReviewsScreen() -> ReviewsScreen {
        if !ReviewsScreen.isVisible {
            reviewsTabButton.tap()
        }

        return ReviewsScreen()
    }

    static func isLoaded() -> Bool {
        return XCUIApplication().buttons[ElementStringIDs.myStoreTabBarItem].exists
    }

    static func isVisible() -> Bool {
        return XCUIApplication().buttons[ElementStringIDs.myStoreTabBarItem].isHittable
    }
}
