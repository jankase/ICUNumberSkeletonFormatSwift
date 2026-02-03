import Testing
import Foundation
@testable import ICUNumberSkeletonFormat

@Suite("SkeletonParser Error Handling Tests")
struct SkeletonParserErrorTests {
    
    let parser = SkeletonParser()
    
    // MARK: - Invalid Token Tests
    
    @Test("Parse unknown keyword throws error")
    func parseUnknownKeyword() {
        #expect(throws: SkeletonParseError.self) {
            try parser.parse("unknown-keyword")
        }
    }
    
    @Test("Parse random text throws error")
    func parseRandomText() {
        #expect(throws: SkeletonParseError.self) {
            try parser.parse("this-is-not-valid")
        }
    }
    
    @Test("Parse partial valid token throws error")
    func parsePartialToken() {
        #expect(throws: SkeletonParseError.self) {
            try parser.parse("curren")
        }
    }
    
    // MARK: - Invalid Currency Code Tests
    
    @Test("Parse currency with short code throws error")
    func parseCurrencyShortCode() {
        #expect(throws: SkeletonParseError.invalidCurrencyCode("US")) {
            try parser.parse("currency/US")
        }
    }
    
    @Test("Parse currency with long code throws error")
    func parseCurrencyLongCode() {
        #expect(throws: SkeletonParseError.invalidCurrencyCode("USDA")) {
            try parser.parse("currency/USDA")
        }
    }
    
    @Test("Parse currency with lowercase code throws error")
    func parseCurrencyLowercase() {
        #expect(throws: SkeletonParseError.invalidCurrencyCode("usd")) {
            try parser.parse("currency/usd")
        }
    }
    
    @Test("Parse currency with numbers throws error")
    func parseCurrencyWithNumbers() {
        #expect(throws: SkeletonParseError.invalidCurrencyCode("US1")) {
            try parser.parse("currency/US1")
        }
    }
    
    @Test("Parse currency with special characters throws error")
    func parseCurrencySpecialChars() {
        #expect(throws: SkeletonParseError.invalidCurrencyCode("US$")) {
            try parser.parse("currency/US$")
        }
    }
    
    // MARK: - Invalid Measure Unit Tests
    
    @Test("Parse measure unit without subtype throws error")
    func parseMeasureUnitNoSubtype() {
        #expect(throws: SkeletonParseError.invalidMeasureUnit("length")) {
            try parser.parse("measure-unit/length")
        }
    }
    
    @Test("Parse measure unit with empty subtype throws error")
    func parseMeasureUnitEmptySubtype() {
        #expect(throws: SkeletonParseError.invalidMeasureUnit("length-")) {
            try parser.parse("measure-unit/length-")
        }
    }
    
    @Test("Parse measure unit with empty type throws error")
    func parseMeasureUnitEmptyType() {
        #expect(throws: SkeletonParseError.invalidMeasureUnit("-meter")) {
            try parser.parse("measure-unit/-meter")
        }
    }
    
    // MARK: - Invalid Precision Tests
    
    @Test("Parse precision with invalid characters throws error")
    func parsePrecisionInvalidChars() {
        #expect(throws: SkeletonParseError.invalidPrecision(".a")) {
            try parser.parse(".a")
        }
    }
    
    @Test("Parse significant digits with no @ symbols throws error")
    func parseSignificantDigitsNoSymbols() {
        #expect(throws: SkeletonParseError.invalidIntegerWidth("###")) {
            try parser.parse("###")
        }
    }
    
    @Test("Parse precision with mixed invalid symbols throws error")
    func parsePrecisionMixedInvalid() {
        #expect(throws: SkeletonParseError.invalidPrecision(".0@")) {
            try parser.parse(".0@")
        }
    }
    
    @Test("Parse precision increment with invalid value throws error")
    func parsePrecisionIncrementInvalid() {
        #expect(throws: SkeletonParseError.invalidPrecision("abc")) {
            try parser.parse("precision-increment/abc")
        }
    }
    
    @Test("Parse precision increment with empty value throws error")
    func parsePrecisionIncrementEmpty() {
        #expect(throws: SkeletonParseError.invalidPrecision("")) {
            try parser.parse("precision-increment/")
        }
    }
    
    // MARK: - Invalid Integer Width Tests
    
    @Test("Parse integer width with invalid characters throws error")
    func parseIntegerWidthInvalidChars() {
        #expect(throws: SkeletonParseError.invalidIntegerWidth("0a0")) {
            try parser.parse("integer-width/0a0")
        }
    }
    
    @Test("Parse integer width with hash after zero throws error")
    func parseIntegerWidthHashAfterZero() {
        #expect(throws: SkeletonParseError.invalidIntegerWidth("0#0")) {
            try parser.parse("integer-width/0#0")
        }
    }
    
    @Test("Parse integer width with only hash throws error")
    func parseIntegerWidthOnlyHash() {
        #expect(throws: SkeletonParseError.invalidIntegerWidth("###")) {
            try parser.parse("integer-width/###")
        }
    }
    
    @Test("Parse integer width with empty value throws error")
    func parseIntegerWidthEmpty() {
        #expect(throws: SkeletonParseError.invalidIntegerWidth("")) {
            try parser.parse("integer-width/")
        }
    }
    
    @Test("Parse short integer width with invalid pattern throws error")
    func parseShortIntegerWidthInvalid() {
        #expect(throws: SkeletonParseError.invalidIntegerWidth("0a")) {
            try parser.parse("0a")
        }
    }
    
    // MARK: - Invalid Scale Tests
    
    @Test("Parse scale with invalid value throws error")
    func parseScaleInvalid() {
        #expect(throws: SkeletonParseError.invalidScale("abc")) {
            try parser.parse("scale/abc")
        }
    }
    
    @Test("Parse scale with empty value throws error")
    func parseScaleEmpty() {
        #expect(throws: SkeletonParseError.invalidScale("")) {
            try parser.parse("scale/")
        }
    }
    
    // MARK: - Invalid Numbering System Tests
    
    @Test("Parse numbering system with empty value throws error")
    func parseNumberingSystemEmpty() {
        #expect(throws: SkeletonParseError.invalidNumberingSystem("")) {
            try parser.parse("numbering-system/")
        }
    }
    
    // MARK: - Invalid Token Format Tests
    
    @Test("Parse token with slash but no value throws error")
    func parseTokenSlashNoValue() {
        #expect(throws: SkeletonParseError.self) {
            try parser.parse("currency/")
        }
    }
    
    @Test("Parse token with multiple slashes throws error")
    func parseTokenMultipleSlashes() {
        #expect(throws: SkeletonParseError.self) {
            try parser.parse("currency/USD/extra")
        }
    }
    
    @Test("Parse token with only slash throws error")
    func parseTokenOnlySlash() {
        #expect(throws: SkeletonParseError.self) {
            try parser.parse("/")
        }
    }
    
    // MARK: - Mixed Valid and Invalid Tokens Tests
    
    @Test("Parse valid followed by invalid token throws error")
    func parseValidThenInvalid() {
        #expect(throws: SkeletonParseError.self) {
            try parser.parse("currency/USD invalid-token")
        }
    }
    
    @Test("Parse invalid followed by valid token throws error")
    func parseInvalidThenValid() {
        #expect(throws: SkeletonParseError.self) {
            try parser.parse("invalid-token currency/USD")
        }
    }
    
    @Test("Parse complex skeleton with one invalid token throws error")
    func parseComplexWithOneInvalid() {
        #expect(throws: SkeletonParseError.self) {
            try parser.parse("currency/USD .00 group-auto invalid-token sign-always")
        }
    }
}

@Suite("SkeletonParser Edge Cases Tests")
struct SkeletonParserEdgeCaseTests {
    
    let parser = SkeletonParser()
    
    @Test("Parse skeleton with leading spaces")
    func parseLeadingSpaces() throws {
        let options = try parser.parse("   currency/USD")
        #expect(options.unit == .currency(code: "USD"))
    }
    
    @Test("Parse skeleton with trailing spaces")
    func parseTrailingSpaces() throws {
        let options = try parser.parse("currency/USD   ")
        #expect(options.unit == .currency(code: "USD"))
    }
    
    @Test("Parse skeleton with multiple spaces between tokens")
    func parseMultipleSpaces() throws {
        let options = try parser.parse("currency/USD    .00    group-off")
        #expect(options.unit == .currency(code: "USD"))
        #expect(options.precision == .fractionDigits(min: 2, max: 2))
        #expect(options.grouping == .off)
    }
    
    @Test("Parse skeleton with tabs treats tab as part of token")
    func parseTabs() {
        // Tabs are not valid token separators per ICU spec, only spaces are
        #expect(throws: SkeletonParseError.self) {
            try parser.parse("currency/USD\t.00")
        }
    }
    
    @Test("Parse skeleton with newlines treats newline as part of token")
    func parseNewlines() {
        // Newlines are not valid token separators per ICU spec, only spaces are
        #expect(throws: SkeletonParseError.self) {
            try parser.parse("currency/USD\n.00")
        }
    }
    
    @Test("Parse very long skeleton with many tokens")
    func parseLongSkeleton() throws {
        let skeleton = "currency/USD unit-width-narrow .00 rounding-mode-half-up group-auto sign-always decimal-always numbering-system/latn"
        let options = try parser.parse(skeleton)
        
        #expect(options.unit == .currency(code: "USD"))
        #expect(options.unitWidth == .narrow)
        #expect(options.precision == .fractionDigits(min: 2, max: 2))
        #expect(options.roundingMode == .halfUp)
        #expect(options.grouping == .auto)
        #expect(options.signDisplay == .always)
        #expect(options.decimalSeparator == .always)
        #expect(options.numberingSystem == "latn")
    }
    
    @Test("Parse skeleton with duplicate compatible tokens")
    func parseDuplicateCompatibleTokens() throws {
        // Last one should win for conflicting options
        let options = try parser.parse("group-off group-auto")
        #expect(options.grouping == .auto)
    }
    
    @Test("Parse skeleton with only precision token")
    func parseOnlyPrecision() throws {
        let options = try parser.parse(".00")
        #expect(options.precision == .fractionDigits(min: 2, max: 2))
        #expect(options.notation == nil)
        #expect(options.unit == nil)
    }
    
    @Test("Parse skeleton with only notation token")
    func parseOnlyNotation() throws {
        let options = try parser.parse("scientific")
        #expect(options.notation == .scientific)
        #expect(options.precision == nil)
    }
    
    @Test("Parse single token skeletons")
    func parseSingleTokens() throws {
        let singleTokens: [(String, (SkeletonOptions) -> Bool)] = [
            ("percent", { $0.unit == .percent }),
            ("permille", { $0.unit == .permille }),
            ("latin", { $0.latinDigits == true }),
            ("group-off", { $0.grouping == .off }),
            ("sign-never", { $0.signDisplay == .never }),
            ("decimal-always", { $0.decimalSeparator == .always }),
            ("precision-integer", { $0.precision == .integer })
        ]
        
        for (skeleton, validation) in singleTokens {
            let options = try parser.parse(skeleton)
            #expect(validation(options))
        }
    }
}

@Suite("SkeletonParser Precision Edge Cases Tests")
struct SkeletonParserPrecisionEdgeTests {
    
    let parser = SkeletonParser()
    
    @Test("Parse fraction digits with many zeros")
    func parseFractionManyZeros() throws {
        let options = try parser.parse(".00000")
        #expect(options.precision == .fractionDigits(min: 5, max: 5))
    }
    
    @Test("Parse fraction digits with many hashes")
    func parseFractionManyHashes() throws {
        let options = try parser.parse(".######")
        #expect(options.precision == .fractionDigits(min: 0, max: 6))
    }
    
    @Test("Parse significant digits with many @ symbols")
    func parseSignificantManyAt() throws {
        let options = try parser.parse("@@@@@@")
        #expect(options.precision == .significantDigits(min: 6, max: 6))
    }
    
    @Test("Parse mixed significant digits")
    func parseMixedSignificant() throws {
        let options = try parser.parse("@@####")
        #expect(options.precision == .significantDigits(min: 2, max: 6))
    }
    
    @Test("Parse only dot for zero fraction digits")
    func parseOnlyDot() throws {
        let options = try parser.parse(".")
        #expect(options.precision == .fractionDigits(min: 0, max: 0))
    }
    
    @Test("Parse precision increment with decimal")
    func parsePrecisionIncrementDecimal() throws {
        let options = try parser.parse("precision-increment/0.25")
        #expect(options.precision == .increment(value: Decimal(string: "0.25")!))
    }
    
    @Test("Parse precision increment with integer")
    func parsePrecisionIncrementInteger() throws {
        let options = try parser.parse("precision-increment/10")
        #expect(options.precision == .increment(value: Decimal(10)))
    }
    
    @Test("Parse precision increment with very small value")
    func parsePrecisionIncrementSmall() throws {
        let options = try parser.parse("precision-increment/0.001")
        #expect(options.precision == .increment(value: Decimal(string: "0.001")!))
    }
}

@Suite("SkeletonParser Integer Width Edge Cases Tests")
struct SkeletonParserIntegerWidthEdgeTests {
    
    let parser = SkeletonParser()
    
    @Test("Parse integer width with many zeros")
    func parseIntegerWidthManyZeros() throws {
        let options = try parser.parse("integer-width/000000")
        #expect(options.integerWidth?.minDigits == 6)
        #expect(options.integerWidth?.maxDigits == nil)
    }
    
    @Test("Parse integer width with truncation and many zeros")
    func parseIntegerWidthTruncateManyZeros() throws {
        let options = try parser.parse("integer-width/+0000")
        #expect(options.integerWidth?.minDigits == 4)
        #expect(options.integerWidth?.maxDigits == 4)
    }
    
    @Test("Parse integer width with many hashes")
    func parseIntegerWidthManyHashes() throws {
        let options = try parser.parse("integer-width/######00")
        #expect(options.integerWidth?.minDigits == 2)
        #expect(options.integerWidth?.maxDigits == 8)
    }
    
    @Test("Parse short integer width with single zero")
    func parseShortIntegerWidthSingle() throws {
        let options = try parser.parse("0")
        #expect(options.integerWidth?.minDigits == 1)
        #expect(options.integerWidth?.maxDigits == nil)
    }
    
    @Test("Parse short integer width with hash and zero")
    func parseShortIntegerWidthHashZero() throws {
        let options = try parser.parse("#0")
        #expect(options.integerWidth?.minDigits == 1)
        #expect(options.integerWidth?.maxDigits == 2)
    }
}

@Suite("SkeletonParser Scale Edge Cases Tests")
struct SkeletonParserScaleEdgeTests {
    
    let parser = SkeletonParser()
    
    @Test("Parse scale with negative value")
    func parseScaleNegative() throws {
        let options = try parser.parse("scale/-10")
        #expect(options.scale == Decimal(-10))
    }
    
    @Test("Parse scale with very large value")
    func parseScaleLarge() throws {
        let options = try parser.parse("scale/1000000")
        #expect(options.scale == Decimal(1000000))
    }
    
    @Test("Parse scale with very small decimal")
    func parseScaleSmallDecimal() throws {
        let options = try parser.parse("scale/0.000001")
        #expect(options.scale == Decimal(string: "0.000001"))
    }
    
    @Test("Parse scale with zero")
    func parseScaleZero() throws {
        let options = try parser.parse("scale/0")
        #expect(options.scale == Decimal(0))
    }
}

@Suite("SkeletonParser All Rounding Modes Tests")
struct SkeletonParserRoundingModesTests {
    
    let parser = SkeletonParser()
    
    @Test("Parse all rounding modes")
    func parseAllRoundingModes() throws {
        let modes: [(String, SkeletonOptions.RoundingMode)] = [
            ("rounding-mode-ceiling", .ceiling),
            ("rounding-mode-floor", .floor),
            ("rounding-mode-down", .down),
            ("rounding-mode-up", .up),
            ("rounding-mode-half-even", .halfEven),
            ("rounding-mode-half-down", .halfDown),
            ("rounding-mode-half-up", .halfUp),
            ("rounding-mode-unnecessary", .unnecessary)
        ]
        
        for (skeleton, expectedMode) in modes {
            let options = try parser.parse(skeleton)
            #expect(options.roundingMode == expectedMode)
        }
    }
}

@Suite("SkeletonParser All Notations Tests")
struct SkeletonParserAllNotationsTests {
    
    let parser = SkeletonParser()
    
    @Test("Parse all notation types")
    func parseAllNotations() throws {
        let notations: [(String, SkeletonOptions.Notation)] = [
            ("notation-simple", .simple),
            ("simple", .simple),
            ("scientific", .scientific),
            ("engineering", .engineering),
            ("compact-short", .compactShort),
            ("compact-long", .compactLong)
        ]
        
        for (skeleton, expectedNotation) in notations {
            let options = try parser.parse(skeleton)
            #expect(options.notation == expectedNotation)
        }
    }
}

@Suite("SkeletonParser All Sign Display Options Tests")
struct SkeletonParserAllSignDisplayTests {
    
    let parser = SkeletonParser()
    
    @Test("Parse all sign display options")
    func parseAllSignDisplays() throws {
        let signDisplays: [(String, SkeletonOptions.SignDisplay)] = [
            ("sign-auto", .auto),
            ("sign-always", .always),
            ("sign-never", .never),
            ("sign-accounting", .accounting),
            ("sign-accounting-always", .accountingAlways),
            ("sign-except-zero", .exceptZero),
            ("sign-accounting-except-zero", .accountingExceptZero),
            ("sign-negative", .negative)
        ]
        
        for (skeleton, expectedSignDisplay) in signDisplays {
            let options = try parser.parse(skeleton)
            #expect(options.signDisplay == expectedSignDisplay)
        }
    }
}

@Suite("SkeletonParser All Unit Widths Tests")
struct SkeletonParserAllUnitWidthsTests {
    
    let parser = SkeletonParser()
    
    @Test("Parse all unit width options")
    func parseAllUnitWidths() throws {
        let unitWidths: [(String, SkeletonOptions.UnitWidth)] = [
            ("unit-width-narrow", .narrow),
            ("unit-width-short", .short),
            ("unit-width-full-name", .fullName),
            ("unit-width-iso-code", .isoCode),
            ("unit-width-formal", .formal),
            ("unit-width-variant", .variant),
            ("unit-width-hidden", .hidden)
        ]
        
        for (skeleton, expectedWidth) in unitWidths {
            let options = try parser.parse(skeleton)
            #expect(options.unitWidth == expectedWidth)
        }
    }
}
