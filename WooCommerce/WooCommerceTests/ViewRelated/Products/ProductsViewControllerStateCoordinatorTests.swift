import XCTest

@testable import WooCommerce
@testable import Yosemite

class ProductsViewControllerStateCoordinatorTests: XCTestCase {

    func testTransitioningToSyncingState() {
        let hasExistingData = true

        let expectationForLeavingState = expectation(description: "Wait for leaving state")
        expectationForLeavingState.expectedFulfillmentCount = 1
        let onLeavingState = { (state: ProductsViewControllerState) in
            XCTAssertEqual(state, .results)
            expectationForLeavingState.fulfill()
        }

        let expectationForEnteringState = expectation(description: "Wait for entering state")
        expectationForEnteringState.expectedFulfillmentCount = 1
        let onEnteringState = { (state: ProductsViewControllerState) in
            XCTAssertEqual(state, .syncing(withExistingData: hasExistingData))
            expectationForEnteringState.fulfill()
        }
        let stateCoordinator = ProductsViewControllerStateCoordinator(onLeavingState: onLeavingState, onEnteringState: onEnteringState)

        stateCoordinator.transitionToSyncingState(withExistingData: hasExistingData)
        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testTransitioningToResultsUpdatedStateTwice() {
        let expectationForLeavingState = expectation(description: "Wait for leaving state")
        expectationForLeavingState.expectedFulfillmentCount = 1
        let onLeavingState = { (state: ProductsViewControllerState) in
            XCTAssertEqual(state, .results)
            expectationForLeavingState.fulfill()
        }

        let expectationForEnteringState = expectation(description: "Wait for entering state")
        expectationForEnteringState.expectedFulfillmentCount = 1
        let onEnteringState = { (state: ProductsViewControllerState) in
            XCTAssertEqual(state, .noResultsPlaceholder)
            expectationForEnteringState.fulfill()
        }
        let stateCoordinator = ProductsViewControllerStateCoordinator(onLeavingState: onLeavingState, onEnteringState: onEnteringState)

        // .results --> .results (no state change)
        stateCoordinator.transitionToResultsUpdatedState(hasData: true)
        // .results --> .noResultsPlaceholder
        stateCoordinator.transitionToResultsUpdatedState(hasData: false)
        waitForExpectations(timeout: 0.1, handler: nil)
    }

}
