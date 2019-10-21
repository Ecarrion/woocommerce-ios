import CoreData
import Foundation

extension OrderItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OrderItem> {
        return NSFetchRequest<OrderItem>(entityName: "OrderItem")
    }

    @NSManaged public var itemID: Int64
    @NSManaged public var name: String?
    @NSManaged public var price: NSDecimalNumber?
    @NSManaged public var productID: Int64
    @NSManaged public var quantity: NSDecimalNumber
    @NSManaged public var sku: String?
    @NSManaged public var subtotal: String?
    @NSManaged public var subtotalTax: String?
    @NSManaged public var taxClass: String?
    @NSManaged public var total: String?
    @NSManaged public var totalTax: String?
    @NSManaged public var variationID: Int64
    @NSManaged public var order: Order
    @NSManaged public var taxes: Set<OrderItemTax>?

}

// MARK: Generated accessors for tax
extension OrderItem {

    @objc(addTaxObject:)
    @NSManaged public func addToTaxes(_ value: OrderItemTax)

    @objc(removeTaxObject:)
    @NSManaged public func removeFromTaxes(_ value: OrderItemTax)

    @objc(addTax:)
    @NSManaged public func addToTaxes(_ values: NSSet)

    @objc(removeTax:)
    @NSManaged public func removeFromTaxes(_ values: NSSet)

}
