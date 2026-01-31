import XCTest
@testable import ICUNumberSkeletonFormat

final class ICUNumberSkeletonFormatTests: XCTestCase {

    // Use US locale for consistent test results
    let usLocale = Locale(identifier: "en_US")

    // MARK: - Basic Formatting Tests

    func testFormatInteger() throws {
        let formatter = try ICUNumberSkeletonFormat(skeleton: "precision-integer", locale: usLocale)
        XCTAssertEqual(formatter.format(1234.567), "1,235")
    }

    func testFormatDecimal() throws {
        let formatter = try ICUNumberSkeletonFormat(skeleton: ".00", locale: usLocale)
        XCTAssertEqual(formatter.format(1234.5), "1,234.50")
    }

    func testFormatDecimalVariable() throws {
        let formatter = try ICUNumberSkeletonFormat(skeleton: ".0#", locale: usLocale)
        XCTAssertEqual(formatter.format(1234.5), "1,234.5")
        XCTAssertEqual(formatter.format(1234.56), "1,234.56")
        XCTAssertEqual(formatter.format(1234.0), "1,234.0")
    }

    // MARK: - Currency Tests

    func testFormatCurrencyUSD() throws {
        let formatter = try ICUNumberSkeletonFormat(skeleton: "currency/USD", locale: usLocale)
        let result = formatter.format(1234.56)
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.contains("1,234.56") || result!.contains("1234.56"))
    }

    func testFormatCurrencyConvenience() throws {
        let formatter = try ICUNumberSkeletonFormat.currency("USD", locale: usLocale)
        let result = formatter.format(99.99)
        XCTAssertNotNil(result)
    }

    // MARK: - Percent Tests

    func testFormatPercent() throws {
        let formatter = try ICUNumberSkeletonFormat(skeleton: "percent", locale: usLocale)
        let result = formatter.format(0.25)
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.contains("25") || result!.contains("%"))
    }

    func testFormatPercentConvenience() throws {
        let formatter = try ICUNumberSkeletonFormat.percent(locale: usLocale)
        let result = formatter.format(0.5)
        XCTAssertNotNil(result)
    }

    // MARK: - Scientific Notation Tests

    func testFormatScientific() throws {
        let formatter = try ICUNumberSkeletonFormat(skeleton: "scientific", locale: usLocale)
        let result = formatter.format(12345.0)
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.contains("E") || result!.lowercased().contains("e"))
    }

    func testFormatScientificConvenience() throws {
        let formatter = try ICUNumberSkeletonFormat.scientific(locale: usLocale)
        let result = formatter.format(1000000.0)
        XCTAssertNotNil(result)
    }

    // MARK: - Grouping Tests

    func testFormatGroupOff() throws {
        let formatter = try ICUNumberSkeletonFormat(skeleton: "group-off", locale: usLocale)
        XCTAssertEqual(formatter.format(1234567), "1234567")
    }

    func testFormatGroupAuto() throws {
        let formatter = try ICUNumberSkeletonFormat(skeleton: "group-auto", locale: usLocale)
        XCTAssertEqual(formatter.format(1234567), "1,234,567")
    }

    // MARK: - Sign Display Tests

    func testFormatSignAlways() throws {
        let formatter = try ICUNumberSkeletonFormat(skeleton: "sign-always", locale: usLocale)
        let result = formatter.format(123)
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.contains("+"))
    }

    func testFormatSignNever() throws {
        let formatter = try ICUNumberSkeletonFormat(skeleton: "sign-never", locale: usLocale)
        let result = formatter.format(-123)
        XCTAssertNotNil(result)
        XCTAssertFalse(result!.contains("-"))
    }

    // MARK: - Scale Tests

    func testFormatScale() throws {
        let formatter = try ICUNumberSkeletonFormat(skeleton: "scale/100", locale: usLocale)
        XCTAssertEqual(formatter.format(0.5), "50")
    }

    // MARK: - Integer Width Tests

    func testFormatIntegerWidthMin() throws {
        let formatter = try ICUNumberSkeletonFormat(skeleton: "integer-width/000", locale: usLocale)
        XCTAssertEqual(formatter.format(5), "005")
    }

    // MARK: - Decimal Separator Tests

    func testFormatDecimalAlways() throws {
        let formatter = try ICUNumberSkeletonFormat(skeleton: "decimal-always precision-integer", locale: usLocale)
        let result = formatter.format(123)
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.contains("."))
    }

    // MARK: - Significant Digits Tests

    func testFormatSignificantDigits() throws {
        let formatter = try ICUNumberSkeletonFormat(skeleton: "@@@", locale: usLocale)
        XCTAssertEqual(formatter.format(12345.0), "12,300")
    }

    func testFormatSignificantDigitsRange() throws {
        let formatter = try ICUNumberSkeletonFormat(skeleton: "@@##", locale: usLocale)
        let result1 = formatter.format(1.0)
        let result2 = formatter.format(1.2345)

        XCTAssertNotNil(result1)
        XCTAssertNotNil(result2)
    }

    // MARK: - Rounding Mode Tests

    func testFormatRoundingCeiling() throws {
        let formatter = try ICUNumberSkeletonFormat(skeleton: "precision-integer rounding-mode-ceiling", locale: usLocale)
        XCTAssertEqual(formatter.format(1.1), "2")
    }

    func testFormatRoundingFloor() throws {
        let formatter = try ICUNumberSkeletonFormat(skeleton: "precision-integer rounding-mode-floor", locale: usLocale)
        XCTAssertEqual(formatter.format(1.9), "1")
    }

    func testFormatRoundingHalfUp() throws {
        let formatter = try ICUNumberSkeletonFormat(skeleton: "precision-integer rounding-mode-half-up", locale: usLocale)
        XCTAssertEqual(formatter.format(1.5), "2")
    }

    func testFormatRoundingHalfEven() throws {
        let formatter = try ICUNumberSkeletonFormat(skeleton: "precision-integer rounding-mode-half-even", locale: usLocale)
        XCTAssertEqual(formatter.format(2.5), "2") // rounds to even
        XCTAssertEqual(formatter.format(3.5), "4") // rounds to even
    }

    // MARK: - Combined Options Tests

    func testFormatCombinedCurrencyPrecision() throws {
        let formatter = try ICUNumberSkeletonFormat(skeleton: "currency/USD .00", locale: usLocale)
        let result = formatter.format(1234.5)
        XCTAssertNotNil(result)
    }

    func testFormatComplexSkeleton() throws {
        let skeleton = "currency/USD .00 group-auto sign-always rounding-mode-half-up"
        let formatter = try ICUNumberSkeletonFormat(skeleton: skeleton, locale: usLocale)
        let result = formatter.format(1234.555)
        XCTAssertNotNil(result)
    }

    // MARK: - Type Tests

    func testFormatBinaryInteger() throws {
        let formatter = try ICUNumberSkeletonFormat(skeleton: ".00", locale: usLocale)
        XCTAssertEqual(formatter.format(42 as Int), "42.00")
        XCTAssertEqual(formatter.format(42 as Int64), "42.00")
    }

    func testFormatBinaryFloatingPoint() throws {
        let formatter = try ICUNumberSkeletonFormat(skeleton: ".00", locale: usLocale)
        XCTAssertEqual(formatter.format(42.5 as Float), "42.50")
        XCTAssertEqual(formatter.format(42.5 as Double), "42.50")
    }

    func testFormatDecimalType() throws {
        let formatter = try ICUNumberSkeletonFormat(skeleton: ".00", locale: usLocale)
        let decimal = Decimal(string: "42.5")!
        XCTAssertEqual(formatter.format(decimal), "42.50")
    }

    func testFormatNSNumber() throws {
        let formatter = try ICUNumberSkeletonFormat(skeleton: ".00", locale: usLocale)
        XCTAssertEqual(formatter.format(NSNumber(value: 42.5)), "42.50")
    }

    // MARK: - Options Initialization Tests

    func testInitWithOptions() {
        var options = SkeletonOptions()
        options.precision = .fractionDigits(min: 2, max: 2)
        options.grouping = .off

        let formatter = ICUNumberSkeletonFormat(options: options, locale: usLocale)
        XCTAssertEqual(formatter.format(1234.5), "1234.50")
    }

    // MARK: - Locale Tests

    func testFormatWithGermanLocale() throws {
        let deLocale = Locale(identifier: "de_DE")
        let formatter = try ICUNumberSkeletonFormat(skeleton: ".00", locale: deLocale)
        let result = formatter.format(1234.5)
        XCTAssertNotNil(result)
        // German uses comma as decimal separator
        XCTAssertTrue(result!.contains(","))
    }

    // MARK: - Error Handling Tests

    func testInvalidSkeletonThrows() {
        XCTAssertThrowsError(try ICUNumberSkeletonFormat(skeleton: "invalid-skeleton-token")) { error in
            XCTAssertTrue(error is SkeletonParseError)
        }
    }
}
