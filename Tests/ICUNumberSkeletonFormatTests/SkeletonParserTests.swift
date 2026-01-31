import XCTest
@testable import ICUNumberSkeletonFormat

final class SkeletonParserTests: XCTestCase {

    let parser = SkeletonParser()

    // MARK: - Notation Tests

    func testParseSimpleNotation() throws {
        let options = try parser.parse("notation-simple")
        XCTAssertEqual(options.notation, .simple)
    }

    func testParseSimpleNotationShort() throws {
        let options = try parser.parse("simple")
        XCTAssertEqual(options.notation, .simple)
    }

    func testParseScientificNotation() throws {
        let options = try parser.parse("scientific")
        XCTAssertEqual(options.notation, .scientific)
    }

    func testParseEngineeringNotation() throws {
        let options = try parser.parse("engineering")
        XCTAssertEqual(options.notation, .engineering)
    }

    func testParseCompactShortNotation() throws {
        let options = try parser.parse("compact-short")
        XCTAssertEqual(options.notation, .compactShort)
    }

    func testParseCompactLongNotation() throws {
        let options = try parser.parse("compact-long")
        XCTAssertEqual(options.notation, .compactLong)
    }

    // MARK: - Unit Tests

    func testParsePercent() throws {
        let options = try parser.parse("percent")
        XCTAssertEqual(options.unit, .percent)
    }

    func testParsePermille() throws {
        let options = try parser.parse("permille")
        XCTAssertEqual(options.unit, .permille)
    }

    func testParseCurrency() throws {
        let options = try parser.parse("currency/USD")
        XCTAssertEqual(options.unit, .currency(code: "USD"))
    }

    func testParseCurrencyEUR() throws {
        let options = try parser.parse("currency/EUR")
        XCTAssertEqual(options.unit, .currency(code: "EUR"))
    }

    func testParseInvalidCurrencyCode() {
        XCTAssertThrowsError(try parser.parse("currency/US")) { error in
            XCTAssertEqual(error as? SkeletonParseError, .invalidCurrencyCode("US"))
        }
    }

    func testParseMeasureUnit() throws {
        let options = try parser.parse("measure-unit/length-meter")
        XCTAssertEqual(options.unit, .measureUnit(type: "length", subtype: "meter"))
    }

    // MARK: - Unit Width Tests

    func testParseUnitWidthNarrow() throws {
        let options = try parser.parse("unit-width-narrow")
        XCTAssertEqual(options.unitWidth, .narrow)
    }

    func testParseUnitWidthShort() throws {
        let options = try parser.parse("unit-width-short")
        XCTAssertEqual(options.unitWidth, .short)
    }

    func testParseUnitWidthFullName() throws {
        let options = try parser.parse("unit-width-full-name")
        XCTAssertEqual(options.unitWidth, .fullName)
    }

    func testParseUnitWidthIsoCode() throws {
        let options = try parser.parse("unit-width-iso-code")
        XCTAssertEqual(options.unitWidth, .isoCode)
    }

    func testParseUnitWidthHidden() throws {
        let options = try parser.parse("unit-width-hidden")
        XCTAssertEqual(options.unitWidth, .hidden)
    }

    // MARK: - Precision Tests

    func testParsePrecisionInteger() throws {
        let options = try parser.parse("precision-integer")
        XCTAssertEqual(options.precision, .integer)
    }

    func testParseFractionDigitsExact() throws {
        let options = try parser.parse(".00")
        XCTAssertEqual(options.precision, .fractionDigits(min: 2, max: 2))
    }

    func testParseFractionDigitsRange() throws {
        let options = try parser.parse(".0#")
        XCTAssertEqual(options.precision, .fractionDigits(min: 1, max: 2))
    }

    func testParseFractionDigitsOptional() throws {
        let options = try parser.parse(".##")
        XCTAssertEqual(options.precision, .fractionDigits(min: 0, max: 2))
    }

    func testParseSignificantDigitsExact() throws {
        let options = try parser.parse("@@@")
        XCTAssertEqual(options.precision, .significantDigits(min: 3, max: 3))
    }

    func testParseSignificantDigitsRange() throws {
        let options = try parser.parse("@@#")
        XCTAssertEqual(options.precision, .significantDigits(min: 2, max: 3))
    }

    func testParsePrecisionUnlimited() throws {
        let options = try parser.parse("precision-unlimited")
        XCTAssertEqual(options.precision, .unlimited)
    }

    func testParsePrecisionCurrencyStandard() throws {
        let options = try parser.parse("precision-currency-standard")
        XCTAssertEqual(options.precision, .currencyStandard)
    }

    func testParsePrecisionIncrement() throws {
        let options = try parser.parse("precision-increment/0.05")
        XCTAssertEqual(options.precision, .increment(value: Decimal(string: "0.05")!))
    }

    // MARK: - Rounding Mode Tests

    func testParseRoundingModeCeiling() throws {
        let options = try parser.parse("rounding-mode-ceiling")
        XCTAssertEqual(options.roundingMode, .ceiling)
    }

    func testParseRoundingModeFloor() throws {
        let options = try parser.parse("rounding-mode-floor")
        XCTAssertEqual(options.roundingMode, .floor)
    }

    func testParseRoundingModeDown() throws {
        let options = try parser.parse("rounding-mode-down")
        XCTAssertEqual(options.roundingMode, .down)
    }

    func testParseRoundingModeUp() throws {
        let options = try parser.parse("rounding-mode-up")
        XCTAssertEqual(options.roundingMode, .up)
    }

    func testParseRoundingModeHalfEven() throws {
        let options = try parser.parse("rounding-mode-half-even")
        XCTAssertEqual(options.roundingMode, .halfEven)
    }

    func testParseRoundingModeHalfDown() throws {
        let options = try parser.parse("rounding-mode-half-down")
        XCTAssertEqual(options.roundingMode, .halfDown)
    }

    func testParseRoundingModeHalfUp() throws {
        let options = try parser.parse("rounding-mode-half-up")
        XCTAssertEqual(options.roundingMode, .halfUp)
    }

    // MARK: - Integer Width Tests

    func testParseIntegerWidthMin() throws {
        let options = try parser.parse("integer-width/+000")
        XCTAssertEqual(options.integerWidth?.minDigits, 3)
        XCTAssertEqual(options.integerWidth?.maxDigits, 3)
    }

    func testParseIntegerWidthMinOnly() throws {
        let options = try parser.parse("integer-width/000")
        XCTAssertEqual(options.integerWidth?.minDigits, 3)
        XCTAssertNil(options.integerWidth?.maxDigits)
    }

    func testParseIntegerWidthRange() throws {
        let options = try parser.parse("integer-width/##00")
        XCTAssertEqual(options.integerWidth?.minDigits, 2)
        XCTAssertEqual(options.integerWidth?.maxDigits, 4)
    }

    // MARK: - Scale Tests

    func testParseScale() throws {
        let options = try parser.parse("scale/100")
        XCTAssertEqual(options.scale, 100)
    }

    func testParseScaleDecimal() throws {
        let options = try parser.parse("scale/0.01")
        XCTAssertEqual(options.scale, Decimal(string: "0.01"))
    }

    // MARK: - Grouping Tests

    func testParseGroupAuto() throws {
        let options = try parser.parse("group-auto")
        XCTAssertEqual(options.grouping, .auto)
    }

    func testParseGroupOff() throws {
        let options = try parser.parse("group-off")
        XCTAssertEqual(options.grouping, .off)
    }

    func testParseGroupMin2() throws {
        let options = try parser.parse("group-min2")
        XCTAssertEqual(options.grouping, .min2)
    }

    func testParseGroupOnAligned() throws {
        let options = try parser.parse("group-on-aligned")
        XCTAssertEqual(options.grouping, .onAligned)
    }

    // MARK: - Sign Display Tests

    func testParseSignAuto() throws {
        let options = try parser.parse("sign-auto")
        XCTAssertEqual(options.signDisplay, .auto)
    }

    func testParseSignAlways() throws {
        let options = try parser.parse("sign-always")
        XCTAssertEqual(options.signDisplay, .always)
    }

    func testParseSignNever() throws {
        let options = try parser.parse("sign-never")
        XCTAssertEqual(options.signDisplay, .never)
    }

    func testParseSignAccounting() throws {
        let options = try parser.parse("sign-accounting")
        XCTAssertEqual(options.signDisplay, .accounting)
    }

    func testParseSignAccountingAlways() throws {
        let options = try parser.parse("sign-accounting-always")
        XCTAssertEqual(options.signDisplay, .accountingAlways)
    }

    func testParseSignExceptZero() throws {
        let options = try parser.parse("sign-except-zero")
        XCTAssertEqual(options.signDisplay, .exceptZero)
    }

    // MARK: - Decimal Separator Tests

    func testParseDecimalAuto() throws {
        let options = try parser.parse("decimal-auto")
        XCTAssertEqual(options.decimalSeparator, .auto)
    }

    func testParseDecimalAlways() throws {
        let options = try parser.parse("decimal-always")
        XCTAssertEqual(options.decimalSeparator, .always)
    }

    // MARK: - Numbering System Tests

    func testParseNumberingSystem() throws {
        let options = try parser.parse("numbering-system/latn")
        XCTAssertEqual(options.numberingSystem, "latn")
    }

    func testParseLatin() throws {
        let options = try parser.parse("latin")
        XCTAssertTrue(options.latinDigits)
    }

    // MARK: - Combined Token Tests

    func testParseCombinedTokens() throws {
        let options = try parser.parse("currency/USD .00 group-off sign-always")

        XCTAssertEqual(options.unit, .currency(code: "USD"))
        XCTAssertEqual(options.precision, .fractionDigits(min: 2, max: 2))
        XCTAssertEqual(options.grouping, .off)
        XCTAssertEqual(options.signDisplay, .always)
    }

    func testParseComplexSkeleton() throws {
        let skeleton = "currency/EUR unit-width-narrow .00 rounding-mode-half-up group-auto"
        let options = try parser.parse(skeleton)

        XCTAssertEqual(options.unit, .currency(code: "EUR"))
        XCTAssertEqual(options.unitWidth, .narrow)
        XCTAssertEqual(options.precision, .fractionDigits(min: 2, max: 2))
        XCTAssertEqual(options.roundingMode, .halfUp)
        XCTAssertEqual(options.grouping, .auto)
    }

    // MARK: - Error Tests

    func testParseInvalidToken() {
        XCTAssertThrowsError(try parser.parse("invalid-token")) { error in
            XCTAssertEqual(error as? SkeletonParseError, .invalidToken("invalid-token"))
        }
    }

    func testParseEmptySkeleton() throws {
        let options = try parser.parse("")
        XCTAssertNil(options.notation)
        XCTAssertNil(options.unit)
    }

    func testParseWhitespaceOnly() throws {
        let options = try parser.parse("   ")
        XCTAssertNil(options.notation)
    }
}
