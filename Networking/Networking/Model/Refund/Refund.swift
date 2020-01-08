import Foundation


/// Represents a decoded Refund entity.
///
public struct Refund: Codable {
    public let refundID: Int64
    public let orderID: Int64
    public let siteID: Int64
    public let dateCreated: Date // gmt
    public let amount: String
    public let reason: String
    public let refundedByUserID: Int64

    /// If true, the automatic refund was used.
    /// When false, manual refund process was used.
    ///
    public let isAutomated: Bool?

    /// If true, the automated refund for a payment gateway is used.
    /// When false, the manual refund process is used.
    ///
    public let createAutomated: Bool?

    public let items: [OrderItemRefund]

    /// Refund struct initializer
    ///
    public init(refundID: Int64,
                orderID: Int64,
                siteID: Int64,
                dateCreated: Date,
                amount: String,
                reason: String,
                refundedByUserID: Int64,
                isAutomated: Bool?,
                createAutomated: Bool?,
                items: [OrderItemRefund]) {
        self.refundID = refundID
        self.orderID = orderID
        self.siteID = siteID
        self.dateCreated = dateCreated
        self.amount = amount
        self.reason = reason
        self.refundedByUserID = refundedByUserID
        self.isAutomated = isAutomated
        self.createAutomated = createAutomated
        self.items = items
    }

    // The public initializer for a Refund
    ///
    public init(from decoder: Decoder) throws {
        guard let orderID = decoder.userInfo[.orderID] as? Int64 else {
            throw RefundDecodingError.missingOrderID
        }

        guard let siteID = decoder.userInfo[.siteID] as? Int64 else {
            throw RefundDecodingError.missingSiteID
        }

        let container = try decoder.container(keyedBy: DecodingKeys.self)

        let refundID = try container.decode(Int64.self, forKey: .refundID)
        let dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated) ?? Date()
        let amount = try container.decode(String.self, forKey: .amount)
        let reason = try container.decode(String.self, forKey: .reason)
        let refundedByUserID = try container.decode(Int64.self, forKey: .refundedByUserID)
        let isAutomated = try container.decode(Bool.self, forKey: .automatedRefund)
        let items = try container.decode([OrderItemRefund].self, forKey: .items)

        self.init(refundID: refundID,
                  orderID: orderID,
                  siteID: siteID,
                  dateCreated: dateCreated,
                  amount: amount,
                  reason: reason,
                  refundedByUserID: refundedByUserID,
                  isAutomated: isAutomated,
                  createAutomated: nil,
                  items: items)
    }

    // The public initializer for an encodable Refund
    ///
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)

        try container.encode(amount, forKey: .amount)
        try container.encode(reason, forKey: .reason)

        // FIXME: What happens when you encode a struct that has a nested struct?
        // `items` contains `taxes: [OrderItemTaxRefund]`.
        try container.encode(items, forKey: .items)

        try container.encode(createAutomated, forKey: .createAutomatedRefund)
    }
}


/// Defines all of the Refund CodingKeys
///
private extension Refund {

    enum DecodingKeys: String, CodingKey {
        case refundID               = "id"
        case dateCreated            = "date_created_gmt"
        case amount
        case reason
        case refundedByUserID       = "refunded_by"
        case automatedRefund        = "refunded_payment"    // read-only
        case items                  = "line_items"
    }

    enum EncodingKeys: String, CodingKey {
        case refundID               = "id"
        case dateCreated            = "date_created_gmt"
        case amount
        case reason
        case refundedByUserID       = "refunded_by"
        case createAutomatedRefund  = "api_refund"          // write-only
        case items                  = "line_items"
    }
}


// MARK: - Comparable Conformance
//
extension Refund: Comparable {
    public static func == (lhs: Refund, rhs: Refund) -> Bool {
        return lhs.refundID == rhs.refundID &&
            lhs.orderID == rhs.orderID &&
            lhs.siteID == rhs.siteID &&
            lhs.dateCreated == rhs.dateCreated &&
            lhs.amount == rhs.amount &&
            lhs.reason == rhs.reason &&
            lhs.refundedByUserID == rhs.refundedByUserID &&
            lhs.isAutomated == rhs.isAutomated &&
            lhs.items.sorted() == rhs.items.sorted()
    }

    public static func < (lhs: Refund, rhs: Refund) -> Bool {
        return lhs.orderID == rhs.orderID ||
            (lhs.orderID == rhs.orderID && lhs.refundID < rhs.refundID) ||
            (lhs.orderID == rhs.orderID && lhs.refundID == rhs.refundID &&
                lhs.dateCreated < rhs.dateCreated) ||
            (lhs.orderID == rhs.orderID && lhs.refundID == rhs.refundID &&
                lhs.dateCreated == rhs.dateCreated  &&
                lhs.amount < rhs.amount) ||
            (lhs.orderID == rhs.orderID && lhs.refundID == rhs.refundID &&
                lhs.dateCreated == rhs.dateCreated  &&
                lhs.amount == rhs.amount &&
                rhs.items.count < rhs.items.count) ||
            (lhs.orderID == rhs.orderID && lhs.refundID == rhs.refundID &&
                lhs.dateCreated == rhs.dateCreated &&
                lhs.amount == rhs.amount &&
                rhs.items.count == rhs.items.count)
    }
}


// MARK: - Decoding Errors
//
enum RefundDecodingError: Error {
    case missingOrderID
    case missingSiteID
}
