import Testing
import Foundation
@testable import ICUNumberSkeletonFormat

@Suite("SkeletonParser Tests")
struct SkeletonParserTests {

    let parser = SkeletonParser()

    // MARK: - Notation Tests

    @Test("Parse simple notation")
    func parseSimpleNotation() throws {
        let options = try parser.parse("notation-simple")
        #expect(options.notation == .simple)
    }

    @Test("Parse simple notation shorthand")
    func parseSimpleNotationShort() throws {
        let options = try parser.parse("simple")
        #expect(options.notation == .simple)
    }

    @Test("Parse scientific notation")
    func parseScientificNotation() throws {
        let options = try parser.parse("scientific")
        #expect(options.notation == .scientific)
    }

    @Test("Parse engineering notation")
    func parseEngineeringNotation() throws {
        let options = try parser.parse("engineering")
        #expect(options.notation == .engineering)
    }

    @Test("Parse compact short notation")
    func parseCompactShortNotation() throws {
        let options = try parser.parse("compact-short")
        #expect(options.notation == .compactShort)
    }

    @Test("Parse compact long notation")
    func parseCompactLongNotation() throws {
        let options = try parser.parse("compact-long")
        #expect(options.notation == .compactLong)
    }

    // MARK: - Unit Tests

    @Test("Parse percent")
    func parsePercent() throws {
        let options = try parser.parse("percent")
        #expect(options.unit == .percent)
    }

    @Test("Parse permille")
    func parsePermille() throws {
        let options = try parser.parse("permille")
        #expect(options.unit == .permille)
    }

    @Test("Parse currency USD")
    func parseCurrency() throws {
        let options = try parser.parse("currency/USD")
        #expect(options.unit == .currency(code: "USD"))
    }

    @Test("Parse currency EUR")
    func parseCurrencyEUR() throws {
        let options = try parser.parse("currency/EUR")
        #expect(options.unit == .currency(code: "EUR"))
    }

    @Test("Parse invalid currency code throws error")
    func parseInvalidCurrencyCode() {
        #expect(throws: SkeletonParseError.invalidCurrencyCode("US")) {
            try parser.parse("currency/US")
        }
    }

    @Test("Parse measure unit")
    func parseMeasureUnit() throws {
        let options = try parser.parse("measure-unit/length-meter")
        #expect(options.unit == .measureUnit(type: "length", subtype: "meter"))
    }

    // MARK: - Unit Width Tests

    @Test("Parse unit width narrow")
    func parseUnitWidthNarrow() throws {
        let options = try parser.parse("unit-width-narrow")
        #expect(options.unitWidth == .narrow)
    }

    @Test("Parse unit width short")
    func parseUnitWidthShort() throws {
        let options = try parser.parse("unit-width-short")
        #expect(options.unitWidth == .short)
    }

    @Test("Parse unit width full name")
    func parseUnitWidthFullName() throws {
        let options = try parser.parse("unit-width-full-name")
        #expect(options.unitWidth == .fullName)
    }

    @Test("Parse unit width ISO code")
    func parseUnitWidthIsoCode() throws {
        let options = try parser.parse("unit-width-iso-code")
        #expect(options.unitWidth == .isoCode)
    }

    @Test("Parse unit width hidden")
    func parseUnitWidthHidden() throws {
        let options = try parser.parse("unit-width-hidden")
        #expect(options.unitWidth == .hidden)
    }

    // MARK: - Precision Tests

    @Test("Parse precision integer")
    func parsePrecisionInteger() throws {
        let options = try parser.parse("precision-integer")
        #expect(options.precision == .integer)
    }

    @Test("Parse exact fraction digits")
    func parseFractionDigitsExact() throws {
        let options = try parser.parse(".00")
        #expect(options.precision == .fractionDigits(min: 2, max: 2))
    }

    @Test("Parse fraction digits range")
    func parseFractionDigitsRange() throws {
        let options = try parser.parse(".0#")
        #expect(options.precision == .fractionDigits(min: 1, max: 2))
    }

    @Test("Parse optional fraction digits")
    func parseFractionDigitsOptional() throws {
        let options = try parser.parse(".##")
        #expect(options.precision == .fractionDigits(min: 0, max: 2))
    }

    @Test("Parse exact significant digits")
    func parseSignificantDigitsExact() throws {
        let options = try parser.parse("@@@")
        #expect(options.precision == .significantDigits(min: 3, max: 3))
    }

    @Test("Parse significant digits range")
    func parseSignificantDigitsRange() throws {
        let options = try parser.parse("@@#")
        #expect(options.precision == .significantDigits(min: 2, max: 3))
    }

    @Test("Parse precision unlimited")
    func parsePrecisionUnlimited() throws {
        let options = try parser.parse("precision-unlimited")
        #expect(options.precision == .unlimited)
    }

    @Test("Parse precision currency standard")
    func parsePrecisionCurrencyStandard() throws {
        let options = try parser.parse("precision-currency-standard")
        #expect(options.precision == .currencyStandard)
    }

    @Test("Parse precision increment")
    func parsePrecisionIncrement() throws {
        let options = try parser.parse("precision-increment/0.05")
        #expect(options.precision == .increment(value: Decimal(string: "0.05")!))
    }

    // MARK: - Rounding Mode Tests

    @Test("Parse rounding mode ceiling")
    func parseRoundingModeCeiling() throws {
        let options = try parser.parse("rounding-mode-ceiling")
        #expect(options.roundingMode == .ceiling)
    }

    @Test("Parse rounding mode floor")
    func parseRoundingModeFloor() throws {
        let options = try parser.parse("rounding-mode-floor")
        #expect(options.roundingMode == .floor)
    }

    @Test("Parse rounding mode down")
    func parseRoundingModeDown() throws {
        let options = try parser.parse("rounding-mode-down")
        #expect(options.roundingMode == .down)
    }

    @Test("Parse rounding mode up")
    func parseRoundingModeUp() throws {
        let options = try parser.parse("rounding-mode-up")
        #expect(options.roundingMode == .up)
    }

    @Test("Parse rounding mode half-even")
    func parseRoundingModeHalfEven() throws {
        let options = try parser.parse("rounding-mode-half-even")
        #expect(options.roundingMode == .halfEven)
    }

    @Test("Parse rounding mode half-down")
    func parseRoundingModeHalfDown() throws {
        let options = try parser.parse("rounding-mode-half-down")
        #expect(options.roundingMode == .halfDown)
    }

    @Test("Parse rounding mode half-up")
    func parseRoundingModeHalfUp() throws {
        let options = try parser.parse("rounding-mode-half-up")
        #expect(options.roundingMode == .halfUp)
    }

    // MARK: - Integer Width Tests

    @Test("Parse integer width with truncation")
    func parseIntegerWidthMin() throws {
        let options = try parser.parse("integer-width/+000")
        #expect(options.integerWidth?.minDigits == 3)
        #expect(options.integerWidth?.maxDigits == 3)
    }

    @Test("Parse integer width minimum only")
    func parseIntegerWidthMinOnly() throws {
        let options = try parser.parse("integer-width/000")
        #expect(options.integerWidth?.minDigits == 3)
        #expect(options.integerWidth?.maxDigits == nil)
    }

    @Test("Parse integer width range")
    func parseIntegerWidthRange() throws {
        let options = try parser.parse("integer-width/##00")
        #expect(options.integerWidth?.minDigits == 2)
        #expect(options.integerWidth?.maxDigits == 4)
    }

    // MARK: - Scale Tests

    @Test("Parse scale integer")
    func parseScale() throws {
        let options = try parser.parse("scale/100")
        #expect(options.scale == 100)
    }

    @Test("Parse scale decimal")
    func parseScaleDecimal() throws {
        let options = try parser.parse("scale/0.01")
        #expect(options.scale == Decimal(string: "0.01"))
    }

    // MARK: - Grouping Tests

    @Test("Parse group auto")
    func parseGroupAuto() throws {
        let options = try parser.parse("group-auto")
        #expect(options.grouping == .auto)
    }

    @Test("Parse group off")
    func parseGroupOff() throws {
        let options = try parser.parse("group-off")
        #expect(options.grouping == .off)
    }

    @Test("Parse group min2")
    func parseGroupMin2() throws {
        let options = try parser.parse("group-min2")
        #expect(options.grouping == .min2)
    }

    @Test("Parse group on-aligned")
    func parseGroupOnAligned() throws {
        let options = try parser.parse("group-on-aligned")
        #expect(options.grouping == .onAligned)
    }

    // MARK: - Sign Display Tests

    @Test("Parse sign auto")
    func parseSignAuto() throws {
        let options = try parser.parse("sign-auto")
        #expect(options.signDisplay == .auto)
    }

    @Test("Parse sign always")
    func parseSignAlways() throws {
        let options = try parser.parse("sign-always")
        #expect(options.signDisplay == .always)
    }

    @Test("Parse sign never")
    func parseSignNever() throws {
        let options = try parser.parse("sign-never")
        #expect(options.signDisplay == .never)
    }

    @Test("Parse sign accounting")
    func parseSignAccounting() throws {
        let options = try parser.parse("sign-accounting")
        #expect(options.signDisplay == .accounting)
    }

    @Test("Parse sign accounting always")
    func parseSignAccountingAlways() throws {
        let options = try parser.parse("sign-accounting-always")
        #expect(options.signDisplay == .accountingAlways)
    }

    @Test("Parse sign except zero")
    func parseSignExceptZero() throws {
        let options = try parser.parse("sign-except-zero")
        #expect(options.signDisplay == .exceptZero)
    }

    // MARK: - Decimal Separator Tests

    @Test("Parse decimal auto")
    func parseDecimalAuto() throws {
        let options = try parser.parse("decimal-auto")
        #expect(options.decimalSeparator == .auto)
    }

    @Test("Parse decimal always")
    func parseDecimalAlways() throws {
        let options = try parser.parse("decimal-always")
        #expect(options.decimalSeparator == .always)
    }

    // MARK: - Numbering System Tests

    @Test("Parse numbering system")
    func parseNumberingSystem() throws {
        let options = try parser.parse("numbering-system/latn")
        #expect(options.numberingSystem == "latn")
    }

    @Test("Parse latin shorthand")
    func parseLatin() throws {
        let options = try parser.parse("latin")
        #expect(options.latinDigits == true)
    }

    // MARK: - Combined Token Tests

    @Test("Parse combined tokens")
    func parseCombinedTokens() throws {
        let options = try parser.parse("currency/USD .00 group-off sign-always")

        #expect(options.unit == .currency(code: "USD"))
        #expect(options.precision == .fractionDigits(min: 2, max: 2))
        #expect(options.grouping == .off)
        #expect(options.signDisplay == .always)
    }

    @Test("Parse complex skeleton")
    func parseComplexSkeleton() throws {
        let skeleton = "currency/EUR unit-width-narrow .00 rounding-mode-half-up group-auto"
        let options = try parser.parse(skeleton)

        #expect(options.unit == .currency(code: "EUR"))
        #expect(options.unitWidth == .narrow)
        #expect(options.precision == .fractionDigits(min: 2, max: 2))
        #expect(options.roundingMode == .halfUp)
        #expect(options.grouping == .auto)
    }

    // MARK: - Error Tests

    @Test("Parse invalid token throws error")
    func parseInvalidToken() {
        #expect(throws: SkeletonParseError.invalidToken("invalid-token")) {
            try parser.parse("invalid-token")
        }
    }

    @Test("Parse empty skeleton returns default options")
    func parseEmptySkeleton() throws {
        let options = try parser.parse("")
        #expect(options.notation == nil)
        #expect(options.unit == nil)
    }

    @Test("Parse whitespace only returns default options")
    func parseWhitespaceOnly() throws {
        let options = try parser.parse("   ")
        #expect(options.notation == nil)
    }
}

@Suite("SkeletonParseError Tests")
struct SkeletonParseErrorTests {

    @Test("Error descriptions are localized")
    func errorDescriptions() {
        let errors: [SkeletonParseError] = [
            .invalidToken("test"),
            .invalidPrecision("test"),
            .invalidIntegerWidth("test"),
            .invalidScale("test"),
            .invalidCurrencyCode("test"),
            .invalidMeasureUnit("test"),
            .invalidNumberingSystem("test"),
            .unexpectedOption("test"),
            .duplicateOption("test")
        ]

        for error in errors {
            #expect(error.errorDescription != nil)
            #expect(error.errorDescription!.contains("test"))
        }
    }

    @Test("Errors are equatable")
    func errorsAreEquatable() {
        let error1 = SkeletonParseError.invalidToken("test")
        let error2 = SkeletonParseError.invalidToken("test")
        let error3 = SkeletonParseError.invalidToken("other")

        #expect(error1 == error2)
        #expect(error1 != error3)
    }
}
