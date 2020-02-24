import Foundation
import XCTest

class ReviewsScreen: BaseScreen {

    struct ElementStringIDs {
        static let markAllAsReadButton = "reviews-mark-all-as-read-button"
    }

    let tabBar = TabNavComponent()
    let markAllAsReadButton: XCUIElement

    static var isVisible: Bool {
        let markAllAsReadButton = XCUIApplication().buttons[ElementStringIDs.markAllAsReadButton]
        return markAllAsReadButton.exists && markAllAsReadButton.isHittable
    }

    init() {
        markAllAsReadButton = XCUIApplication().buttons[ElementStringIDs.markAllAsReadButton]
        super.init(element: markAllAsReadButton)
    }

    @discardableResult
    func selectReview(atIndex index: Int) -> SingleReviewScreen {
        XCUIApplication().cells.element(boundBy: index).tap()
        return SingleReviewScreen()
    }
}
