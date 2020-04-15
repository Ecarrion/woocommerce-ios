import Foundation

/// Represents a row in the ProductCategoryList screen
///
struct ProductCategoryViewModel {
    /// Category Identifier
    ///
    let categoryID: Int64
    
    /// Category name
    ///
    let name: String

    /// Category selected status
    ///
    let isSelected: Bool

    /// Level of indentation as a subcategory
    ///
    let indentationLevel: Int
}
