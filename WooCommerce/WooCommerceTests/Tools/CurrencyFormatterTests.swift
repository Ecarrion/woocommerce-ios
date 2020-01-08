import XCTest
@testable import WooCommerce
@testable import Networking


/// Currency Formatter Tests - Decimals
///
class CurrencyFormatterTests: XCTestCase {

    /// Sample Site Settings
    ///
    func setUpSampleSiteSettings() -> [SiteSetting] {
        let settings = mapLoadGeneralSiteSettingsResponse()
        var siteSettings = [SiteSetting]()

        siteSettings.append(settings[14])
        siteSettings.append(settings[15])
        siteSettings.append(settings[16])
        siteSettings.append(settings[17])
        siteSettings.append(settings[18])

        return siteSettings
    }

    /// Verifies that the string value returns an accurate decimal value
    ///
    func testStringReturnsDecimal() {
        let stringValue = "9.99"
        let expectedResult = NSDecimalNumber(string: stringValue)

        let converted = CurrencyFormatter().convertToDecimal(from: stringValue)

        // check the formatted decimal exists
        guard let actualResult = converted else {
            XCTFail()
            return
        }

        // check the decimal type
        XCTAssertTrue(actualResult.isKind(of: NSDecimalNumber.self))

        // check the decimal value
        XCTAssertEqual(expectedResult, actualResult)
    }


    /// This is where a float-to-decimal unit test would go.
    /// It's not here because we don't allow using floats for currency.
    /// Be Responsible. Friends don't let friends use `float` or `double` for currency.


    /// Verifies that the formatted decimal value is NOT rounded
    ///
    func testStringValueIsNotRoundedDecimal() {
        let stringValue = "9.9999"
        let expectedResult = NSDecimalNumber(string: stringValue)

        let actualResult = CurrencyFormatter().convertToDecimal(from: stringValue)
        XCTAssertEqual(expectedResult, actualResult)
    }

    /// Verifies that the decimal separator is localized
    ///
    func testDecimalSeparatorIsLocalized() {
        let separator = ","
        let stringValue = "1.17"
        let expectedResult = "1,17"
        let converted = CurrencyFormatter().convertToDecimal(from: stringValue)

        guard let convertedDecimal = converted else {
            XCTFail()
            return
        }

        let actualResult = CurrencyFormatter().localize(convertedDecimal, with: separator)

        XCTAssertEqual(expectedResult, actualResult)
    }

    /// Verifies that bad data doesn't get converted into a decimal
    ///
    func testBadDataInStringDoesNotConvertToDecimal() {
        let badInput = "~HUKh*(&Y3HkJ8"
        let actualResult = CurrencyFormatter().convertToDecimal(from: badInput)

        XCTAssertNil(actualResult)
    }

    /// Verifies that negative numbers are successfully converted into a decimal
    ///
    func testNegativeNumbersSuccessfullyConvertToDecimal() {
        let negativeNumber = "-81346.45"
        let expectedResult = NSDecimalNumber(string: negativeNumber)
        let actualResult = CurrencyFormatter().convertToDecimal(from: negativeNumber)

        XCTAssertEqual(expectedResult, actualResult)
    }


    // MARK: - Thousand Separator Unit Tests


    /// Verifies that the thousand separator is localized to a comma
    ///
    func testThousandSeparatorIsLocalizedToComma() {
        let comma = ","
        let stringValue = "1204.67"
        let expectedResult = "1,204.67"

        let convertedDecimal = CurrencyFormatter().convertToDecimal(from: stringValue)

        guard let decimal = convertedDecimal else {
            XCTFail()
            return
        }

        let formattedString = CurrencyFormatter().localize(decimal, including: comma)
        guard let actualResult = formattedString else {
            XCTFail()
            return
        }

        XCTAssertEqual(expectedResult, actualResult)
    }

    /// Verifies that the result string is accurate when a blank string is entered for the thousand separator
    ///
    func testThousandSeparatorIsLocalizedToBlankString() {
        let decimalSeparator = "."
        let thousandSeparator = ""
        let stringValue = "1204.67"
        let expectedResult = "1204.67"

        let convertedDecimal = CurrencyFormatter().convertToDecimal(from: stringValue)
        guard let decimal = convertedDecimal else {
            XCTFail()
            return
        }

        let localizedAmount = CurrencyFormatter().localize(decimal,
                                                           with: decimalSeparator,
                                                           including: thousandSeparator)

        guard let actualResult = localizedAmount else {
            XCTFail()
            return
        }

        XCTAssertEqual(expectedResult, actualResult)
    }

    /// Verifies that the decimal separator is properly applied after thousands separator
    ///
    func testCommaDecimalSeparatorAfterCommaThousandSeparatorWasApplied() {
        let separator = ","
        let stringValue = "45958320.97"
        let expectedResult = "45,958,320,97"

        let converted = CurrencyFormatter().convertToDecimal(from: stringValue)
        guard let convertedDecimal = converted else {
            XCTFail()
            return
        }

        let position = 2
        let localizedAmount = CurrencyFormatter().localize(convertedDecimal,
                                                           with: separator,
                                                           in: position,
                                                           including: separator)
        guard let actualResult = localizedAmount else {
            XCTFail()
            return
        }

        XCTAssertEqual(expectedResult, actualResult)
    }

    /// Verifies decimal places are correct after localize methods have been applied
    ///
    func testDecimalPlacesAfterLocalizeThousandAndLocalizeDecimalFormattingWasApplied() {
        let position = 3
        let separator = ","
        let stringValue = "45958320.97"
        let expectedResult = "45,958,320,970"

        let converted = CurrencyFormatter().convertToDecimal(from: stringValue)
        guard let convertedDecimal = converted else {
            XCTFail()
            return
        }

        let formattedAmount = CurrencyFormatter().localize(convertedDecimal,
                                                           with: separator,
                                                           in: position,
                                                           including: separator)

        guard let actualResult = formattedAmount else {
            XCTFail()
            return
        }

        XCTAssertEqual(expectedResult, actualResult)
    }


    // MARK: - Currency Formatting Unit Tests


    /// Verifies that user's full currency preferences are applied using a string as the raw value
    ///
    func testCompleteCurrencyFormattingRespectsUserRulesUsingStringValue() {
        let decimalSeparator = ","
        let thousandSeparator = "."
        let decimalPosition = 3
        let currencyPosition = CurrencySettings.CurrencyPosition.rightSpace
        let currencyCode = CurrencySettings.CurrencyCode.GBP
        let stringAmount = "-7867818684.64"
        let expectedResult = "-7.867.818.684,640 £"

        let decimal = CurrencyFormatter().convertToDecimal(from: stringAmount)
        guard let decimalAmount = decimal else {
            XCTFail("Error: invalid string amount. Cannot convert to decimal.")
            return
        }

        let amount = CurrencyFormatter().localize(decimalAmount,
                                                  with: decimalSeparator,
                                                  in: decimalPosition,
                                                  including: thousandSeparator)

        guard let localizedAmount = amount else {
            XCTFail()
            return
        }

        let symbol = CurrencySettings.shared.symbol(from: currencyCode)
        let isNegative = decimalAmount.isNegative()
        let actualResult = CurrencyFormatter().formatCurrency(using: localizedAmount,
                                                              at: currencyPosition,
                                                              with: symbol,
                                                              isNegative: isNegative)

        XCTAssertEqual(expectedResult, actualResult)
    }

    /// Verifies that user's full currency preferences are applied using a NSDecimalNumber as the raw value
    ///
    func testCompleteCurrencyFormattingRespectsUserRulesUsingDecimalValue() {
        let decimalSeparator = ","
        let thousandSeparator = "."
        let decimalPosition = 3
        let currencyPosition = CurrencySettings.CurrencyPosition.rightSpace
        let currencyCode = CurrencySettings.CurrencyCode.GBP
        let decimalAmount = NSDecimalNumber(floatLiteral: -7867818684.64)
        let expectedResult = "-7.867.818.684,640 £"

        let amount = CurrencyFormatter().localize(decimalAmount,
                                                  with: decimalSeparator,
                                                  in: decimalPosition,
                                                  including: thousandSeparator)

        guard let localizedAmount = amount else {
            XCTFail()
            return
        }

        let symbol = CurrencySettings.shared.symbol(from: currencyCode)
        let isNegative = decimalAmount.isNegative()
        let actualResult = CurrencyFormatter().formatCurrency(using: localizedAmount,
                                                              at: currencyPosition,
                                                              with: symbol,
                                                              isNegative: isNegative)

        XCTAssertEqual(expectedResult, actualResult)
    }


    // MARK: - Human readable formatter tests


    func testFormatHumanReadableWithRoundingWorksUsingSmallDecimalValue() {
        // Create a "standard" set of currency settings for the human readable formatter tests
        _ = CurrencySettings(siteSettings: setUpSampleSiteSettings())
        let formatter = CurrencyFormatter()

        let inputValue = "97.64"
        let expectedResult = "$97"
        let amount = formatter.formatHumanReadableAmount(inputValue, with: "USD")
        XCTAssertEqual(amount, expectedResult)
    }

    func testFormatHumanReadableWorksUsingSmallDecimalValue() {
        let inputValue = "97.64"
        let expectedResult = "$97.64"
        let amount = CurrencyFormatter().formatHumanReadableAmount(inputValue, roundSmallNumbers: false)
        XCTAssertEqual(amount, expectedResult)
    }

    func testFormatHumanReadableWithRoundingWorksUsingSmallDecimalValueAndSpecificCountryCode() {
        let inputValue = "97.64"
        let expectedResult = "£97"
        let amount = CurrencyFormatter().formatHumanReadableAmount(inputValue, with: "GBP")
        XCTAssertEqual(amount, expectedResult)
    }

    func testFormatHumanReadableWorksUsingSmallDecimalValueAndSpecificCountryCode() {
        let inputValue = "97.64"
        let expectedResult = "£97.64"
        let amount = CurrencyFormatter().formatHumanReadableAmount(inputValue, with: "GBP", roundSmallNumbers: false)
        XCTAssertEqual(amount, expectedResult)
    }

    func testFormatHumanReadableWithRoundingWorksUsingSmallNegativeDecimalValue() {
        let inputValue = "-7.64"
        let expectedResult = "-$7"
        let amount = CurrencyFormatter().formatHumanReadableAmount(inputValue)
        XCTAssertEqual(amount, expectedResult)
    }

    func testFormatHumanReadableWorksUsingSmallNegativeDecimalValue() {
        let inputValue = "-7.64"
        let expectedResult = "-$7.64"
        let amount = CurrencyFormatter().formatHumanReadableAmount(inputValue, roundSmallNumbers: false)
        XCTAssertEqual(amount, expectedResult)
    }

    func testFormatHumanReadableWithRoundingWorksUsingSmallNegativeDecimalValueAndSpecificCountryCode() {
        let inputValue = "-7.64"
        let expectedResult = "-£7"
        let amount = CurrencyFormatter().formatHumanReadableAmount(inputValue, with: "GBP")
        XCTAssertEqual(amount, expectedResult)
    }

    func testFormatHumanReadableWorksUsingSmallNegativeDecimalValueAndSpecificCountryCode() {
        let inputValue = "-7.64"
        let expectedResult = "-£7.64"
        let amount = CurrencyFormatter().formatHumanReadableAmount(inputValue, with: "GBP", roundSmallNumbers: false)
        XCTAssertEqual(amount, expectedResult)
    }

    func testFormatHumanReadableWorksUsingLargeDecimalValue() {
        let inputValue = "7867818684.64"
        let expectedResult = "$7.9b"
        let amount = CurrencyFormatter().formatHumanReadableAmount(inputValue)
        XCTAssertEqual(amount, expectedResult)
    }

    func testFormatHumanReadableWorksUsingLargeNegativeDecimalValue() {
        let inputValue = "-7867818684.64"
        let expectedResult = "-$7.9b"
        let amount = CurrencyFormatter().formatHumanReadableAmount(inputValue, with: "USD")
        XCTAssertEqual(amount, expectedResult)
    }

    func testFormatHumanReadableWorksUsingLargeDecimalValueAndSpecificCountryCode() {
        let inputValue = "7867818684.64"
        let expectedResult = "£7.9b"
        let amount = CurrencyFormatter().formatHumanReadableAmount(inputValue, with: "GBP")
        XCTAssertEqual(amount, expectedResult)
    }

    func testFormatHumanReadableWorksUsingLargeNegativeDecimalValueAndSpecificCountryCode() {
        let inputValue = "-7867818684.64"
        let expectedResult = "-£7.9b"
        let amount = CurrencyFormatter().formatHumanReadableAmount(inputValue, with: "GBP")
        XCTAssertEqual(amount, expectedResult)
    }

    // MARK: - Format Amount tests

    func testFormatAmountUsingDecimalValueWithPointSeparator() {
        let inputValue = "13.21"
        let expectedResult = "$13" + CurrencySettings.shared.decimalSeparator + "21"

        let amount = CurrencyFormatter().formatAmount(inputValue, with: "USD")
        XCTAssertEqual(amount, expectedResult)
    }

    func testFormatAmountUsingDecimalValueWithCommaSeparator() {
        let inputValue = "13,21"
        let expectedResult = "$13" + CurrencySettings.shared.decimalSeparator + "21"

        let amount = CurrencyFormatter().formatAmount(inputValue, with: "USD")
        XCTAssertEqual(amount, expectedResult)
    }
}

extension CurrencyFormatterTests {
    /// Returns the SiteSettings output upon receiving `filename` (Data Encoded)
    ///
    func mapGeneralSettings(from filename: String) -> [SiteSetting] {
        guard let response = Loader.contentsOf(filename) else {
            return []
        }

        return try! SiteSettingsMapper(siteID: 123, settingsGroup: SiteSettingGroup.general).map(response: response)
    }

    /// Returns the OrderNotesMapper output upon receiving `settings-general`
    ///
    func mapLoadGeneralSiteSettingsResponse() -> [SiteSetting] {
        return mapGeneralSettings(from: "settings-general")
    }
}
