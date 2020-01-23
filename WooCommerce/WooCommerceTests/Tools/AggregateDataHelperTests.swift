import XCTest
import Foundation
@testable import WooCommerce
@testable import Networking


/// AggregateOrderItem Tests
///
final class AggregateDataHelperTests: XCTestCase {
    /// Dummy Site ID.
    ///
    private let dummySiteID: Int64 = 9876543210

    /// Order ID.
    ///
    private let orderID: Int64 = 560

    /// Verifies all refunds are loaded
    ///
    func testRefundsCount() {
        let refunds = mapLoadAllRefundsResponse()
        let expected = 3
        let actual = refunds.count

        XCTAssertEqual(expected, actual)
    }

    /// Verifies refunded products are calculated correctly.
    ///
    func testRefundedProductsCount() {
        let refunds = mapLoadAllRefundsResponse()
        let expected = Decimal(6)
        let actual = AggregateDataHelper.refundedProductsCount(from: refunds)

        XCTAssertEqual(expected, actual)
    }

    /// Verifies refunded products are combined and sorted correctly.
    ///
    func testRefundedProductsSortedSuccessfully() {
        let refunds = mapLoadAllRefundsResponse()
        let expectedProducts = expectedRefundedProducts()
        guard let actualProducts = AggregateDataHelper.combineRefundedProducts(from: refunds) else {
            XCTFail("Error: failed to combine products.")
            return
        }

        let count = actualProducts.count
        for index in 0..<count {
            let actual = actualProducts[index]
            let expected = expectedProducts[index]
            XCTAssertEqual(expected.productID, actual.productID)
            XCTAssertEqual(expected.variationID, actual.variationID)
            XCTAssertEqual(expected.name, actual.name)
            XCTAssertEqual(expected.quantity, actual.quantity)
            XCTAssertEqual(expected.total, actual.total)
            XCTAssertEqual(expected.sku, actual.sku)
        }
    }
}


private extension AggregateDataHelperTests {
    /// Returns the OrderListMapper output upon receiving `filename` (Data Encoded)
    ///
    func mapOrders(from filename: String) -> [Order] {
        guard let response = Loader.contentsOf(filename) else {
            return []
        }

        return try! OrderListMapper(siteID: dummySiteID).map(response: response)
    }

    /// Returns the RefundListMapper output upon receiving `filename` (Data Encoded)
    ///
    func mapRefunds(from filename: String) -> [Refund] {
        guard let response = Loader.contentsOf(filename) else {
            return []
        }

        return try! RefundListMapper(siteID: dummySiteID, orderID: orderID).map(response: response)
    }

    /// Returns the OrderListMapper output upon receiving `orders-load-all`
    ///
    func mapLoadAllOrdersResponse() -> [Order] {
        return mapOrders(from: "orders-load-all")
    }

    /// Returns the RefundListMapper output upon receiving `order-560-all-refunds`
    ///
    func mapLoadAllRefundsResponse() -> [Refund] {
        return mapRefunds(from: "order-560-all-refunds")
    }

    /// Returns the sorted, expected array of refunded products
    ///
    func expectedRefundedProducts() -> [AggregateOrderItem] {
        let currencyFormatter = CurrencyFormatter()
        var expectedArray = [AggregateOrderItem]()
        let item1 = AggregateOrderItem(
                        productID: 21,
                        variationID: 70,
                        name: "Ship Your Idea - Blue, XL",
                        price: currencyFormatter.convertToDecimal(from: "-27.00") ?? NSDecimalNumber.zero,
                        quantity: -3,
                        sku: "HOODIE-SHIP-YOUR-IDEA-BLUE-XL",
                        total: currencyFormatter.convertToDecimal(from: "-81.00") ?? NSDecimalNumber.zero
                    )
        expectedArray.append(item1)

        let item2 = AggregateOrderItem(
                        productID: 21,
                        variationID: 71,
                        name: "Ship Your Idea - Black, L",
                        price: currencyFormatter.convertToDecimal(from: "-31.50") ?? NSDecimalNumber.zero,
                        quantity: -1,
                        sku: "HOODIE-SHIP-YOUR-IDEA-BLACK-L",
                        total: currencyFormatter.convertToDecimal(from: "-31.50") ?? NSDecimalNumber.zero
                    )
        expectedArray.append(item2)

        let item3 = AggregateOrderItem(
                        productID: 22,
                        variationID: 0,
                        name: "Ninja Silhouette",
                        price: currencyFormatter.convertToDecimal(from: "-18.00") ?? NSDecimalNumber.zero,
                        quantity: -1,
                        sku: "T-SHIRT-NINJA-SILHOUETTE",
                        total: currencyFormatter.convertToDecimal(from: "-18.00") ?? NSDecimalNumber.zero
                    )
        expectedArray.append(item3)

        let item4 = AggregateOrderItem(
                        productID: 24,
                        variationID: 0,
                        name: "Happy Ninja",
                        price: currencyFormatter.convertToDecimal(from: "-31.50") ?? NSDecimalNumber.zero,
                        quantity: -1,
                        sku: "HOODIE-HAPPY-NINJA",
                        total: currencyFormatter.convertToDecimal(from: "-31.50") ?? NSDecimalNumber.zero
                    )
        expectedArray.append(item4)

        return expectedArray
    }
}
