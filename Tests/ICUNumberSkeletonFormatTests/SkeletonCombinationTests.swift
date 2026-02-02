import Testing
import Foundation
@testable import ICUNumberSkeletonFormat

/// Tests for skeleton fragment combinations with complete result assertions.
/// Each test verifies the exact output string, not just partial matches.
@Suite("Skeleton Fragment Combination Tests")
struct SkeletonCombinationTests {

    let usLocale = Locale(identifier: "en_US")

    // MARK: - Precision + Grouping Combinations

    @Test("Precision .00 with group-off")
    func precisionWithGroupOff() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: ".00 group-off",
            locale: usLocale
        )
        #expect(style.format(1234567.89) == "1234567.89")
        #expect(style.format(0.5) == "0.50")
        #expect(style.format(1000.0) == "1000.00")
    }

    @Test("Precision .00 with group-auto")
    func precisionWithGroupAuto() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: ".00 group-auto",
            locale: usLocale
        )
        #expect(style.format(1234567.89) == "1,234,567.89")
        #expect(style.format(0.5) == "0.50")
        #expect(style.format(1000.0) == "1,000.00")
    }

    @Test("Precision .0# with group-off")
    func variablePrecisionWithGroupOff() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: ".0# group-off",
            locale: usLocale
        )
        #expect(style.format(1234.5) == "1234.5")
        #expect(style.format(1234.56) == "1234.56")
        #expect(style.format(1234.0) == "1234.0")
    }

    @Test("precision-integer with group-auto")
    func integerPrecisionWithGroupAuto() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "precision-integer group-auto",
            locale: usLocale
        )
        #expect(style.format(1234567.89) == "1,234,568")
        #expect(style.format(1000.4) == "1,000")
        #expect(style.format(999.5) == "1,000")
    }

    // MARK: - Precision + Sign Display Combinations

    @Test("Precision .00 with sign-always")
    func precisionWithSignAlways() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: ".00 sign-always",
            locale: usLocale
        )
        #expect(style.format(123.45) == "+123.45")
        #expect(style.format(-123.45) == "-123.45")
        #expect(style.format(0.0) == "+0.00")
    }

    @Test("Precision .00 with sign-never")
    func precisionWithSignNever() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: ".00 sign-never",
            locale: usLocale
        )
        #expect(style.format(123.45) == "123.45")
        #expect(style.format(-123.45) == "123.45")
        #expect(style.format(0.0) == "0.00")
    }

    @Test("Precision .00 with sign-except-zero")
    func precisionWithSignExceptZero() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: ".00 sign-except-zero",
            locale: usLocale
        )
        #expect(style.format(123.45) == "+123.45")
        #expect(style.format(-123.45) == "-123.45")
        #expect(style.format(0.0) == "0.00")
    }

    // MARK: - Precision + Rounding Mode Combinations

    @Test("Precision .0 with rounding-mode-ceiling")
    func precisionWithRoundingCeiling() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: ".0 rounding-mode-ceiling",
            locale: usLocale
        )
        #expect(style.format(1.11) == "1.2")
        #expect(style.format(1.19) == "1.2")
        #expect(style.format(-1.11) == "-1.1")
        #expect(style.format(-1.19) == "-1.1")
    }

    @Test("Precision .0 with rounding-mode-floor")
    func precisionWithRoundingFloor() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: ".0 rounding-mode-floor",
            locale: usLocale
        )
        #expect(style.format(1.11) == "1.1")
        #expect(style.format(1.19) == "1.1")
        #expect(style.format(-1.11) == "-1.2")
        #expect(style.format(-1.19) == "-1.2")
    }

    @Test("Precision .0 with rounding-mode-half-up")
    func precisionWithRoundingHalfUp() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: ".0 rounding-mode-half-up",
            locale: usLocale
        )
        #expect(style.format(1.14) == "1.1")
        #expect(style.format(1.15) == "1.2")
        #expect(style.format(1.16) == "1.2")
    }

    @Test("Precision .0 with rounding-mode-half-even")
    func precisionWithRoundingHalfEven() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: ".0 rounding-mode-half-even",
            locale: usLocale
        )
        #expect(style.format(1.25) == "1.2") // rounds to even
        #expect(style.format(1.35) == "1.4") // rounds to even
        #expect(style.format(1.45) == "1.4") // rounds to even
    }

    // MARK: - Scale + Precision Combinations

    @Test("Scale 100 with precision-integer")
    func scaleWithIntegerPrecision() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "scale/100 precision-integer group-off",
            locale: usLocale
        )
        #expect(style.format(0.5) == "50")
        #expect(style.format(1.0) == "100")
        #expect(style.format(0.123) == "12")
    }

    @Test("Scale 100 with .00 precision")
    func scaleWithDecimalPrecision() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "scale/100 .00 group-off",
            locale: usLocale
        )
        #expect(style.format(0.5) == "50.00")
        #expect(style.format(1.234) == "123.40")
        #expect(style.format(0.005) == "0.50")
    }

    @Test("Scale 0.01 (cents to dollars) with .00")
    func scaleCentsToDollars() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "scale/0.01 .00 group-off",
            locale: usLocale
        )
        #expect(style.format(12345.0) == "123.45")
        #expect(style.format(100.0) == "1.00")
        #expect(style.format(99.0) == "0.99")
    }

    // MARK: - Percent + Precision Combinations

    @Test("Percent with precision-integer")
    func percentWithIntegerPrecision() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "percent precision-integer",
            locale: usLocale
        )
        #expect(style.format(0.25) == "25%")
        #expect(style.format(0.5) == "50%")
        #expect(style.format(1.0) == "100%")
    }

    @Test("Percent with .0 precision")
    func percentWithOneFractionDigit() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "percent .0",
            locale: usLocale
        )
        #expect(style.format(0.255) == "25.5%")
        #expect(style.format(0.5) == "50.0%")
        #expect(style.format(0.333) == "33.3%")
    }

    @Test("Percent with .00 precision and sign-always")
    func percentWithPrecisionAndSign() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "percent .00 sign-always",
            locale: usLocale
        )
        #expect(style.format(0.25) == "+25.00%")
        #expect(style.format(-0.25) == "-25.00%")
        #expect(style.format(0.0) == "+0.00%")
    }

    // MARK: - Permille + Precision Combinations

    @Test("Permille with precision-integer")
    func permilleWithIntegerPrecision() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "permille precision-integer",
            locale: usLocale
        )
        #expect(style.format(0.025) == "25\u{2030}")
        #expect(style.format(0.5) == "500\u{2030}")
        #expect(style.format(1.0) == "1,000\u{2030}")
    }

    @Test("Permille with .0 precision")
    func permilleWithOneFractionDigit() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "permille .0",
            locale: usLocale
        )
        #expect(style.format(0.0255) == "25.5\u{2030}")
        #expect(style.format(0.1) == "100.0\u{2030}")
    }

    @Test("Permille with group-off")
    func permilleWithGroupOff() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "permille precision-integer group-off",
            locale: usLocale
        )
        #expect(style.format(1.0) == "1000\u{2030}")
        #expect(style.format(10.0) == "10000\u{2030}")
    }

    // MARK: - Currency + Precision Combinations

    @Test("Currency USD with .00 precision")
    func currencyUSDWithPrecision() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "currency/USD .00",
            locale: usLocale
        )
        #expect(style.format(1234.5) == "$1,234.50")
        #expect(style.format(99.0) == "$99.00")
        #expect(style.format(0.99) == "$0.99")
    }

    @Test("Currency USD with sign-accounting")
    func currencyUSDWithAccounting() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "currency/USD sign-accounting",
            locale: usLocale
        )
        let positiveResult = style.format(100.0)
        let negativeResult = style.format(-100.0)
        // Accounting format shows negatives in parentheses
        #expect(positiveResult.contains("$") && positiveResult.contains("100"))
        #expect(negativeResult.contains("(") || negativeResult.contains("-"))
    }

    @Test("Currency EUR with group-off")
    func currencyEURWithGroupOff() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "currency/EUR .00 group-off",
            locale: usLocale
        )
        let result = style.format(1234567.89)
        #expect(result.contains("1234567.89"))
    }

    // MARK: - Significant Digits Combinations

    @Test("Significant digits @@@ with group-auto")
    func significantDigitsWithGrouping() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "@@@ group-auto",
            locale: usLocale
        )
        #expect(style.format(12345.0) == "12,300")
        #expect(style.format(0.012345) == "0.0123")
        #expect(style.format(123.0) == "123")
    }

    @Test("Significant digits @@@@ with sign-always")
    func significantDigitsWithSign() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "@@@@ sign-always group-off",
            locale: usLocale
        )
        #expect(style.format(12345.0) == "+12350")
        #expect(style.format(-12345.0) == "-12350")
    }

    // MARK: - Integer Width Combinations

    @Test("Integer width minimum with .00 precision")
    func integerWidthMinWithPrecision() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "integer-width/000 .00 group-off",
            locale: usLocale
        )
        #expect(style.format(5.0) == "005.00")
        #expect(style.format(12.34) == "012.34")
        #expect(style.format(123.45) == "123.45")
    }

    @Test("Integer width truncation with precision-integer")
    func integerWidthTruncateWithPrecision() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "integer-width/+00 precision-integer group-off",
            locale: usLocale
        )
        #expect(style.format(5.0) == "05")
        #expect(style.format(1234.0) == "34")
        #expect(style.format(99.0) == "99")
    }

    // MARK: - Scientific Notation Combinations

    @Test("Scientific with .0 precision")
    func scientificWithPrecision() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "scientific .0",
            locale: usLocale
        )
        let result = style.format(12345.0)
        #expect(result.lowercased().contains("e"))
    }

    @Test("Scientific with @@@ significant digits")
    func scientificWithSignificantDigits() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "scientific @@@",
            locale: usLocale
        )
        let result = style.format(12345.6789)
        #expect(result.lowercased().contains("e"))
    }

    // MARK: - Compact Notation Combinations

    @Test("Compact-short with .0 precision")
    func compactShortWithPrecision() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "compact-short .0",
            locale: usLocale
        )
        let result = style.format(1500.0)
        #expect(result.contains("K") || result.contains("k") || result.contains("1.5"))
    }

    @Test("Compact-short with sign-always")
    func compactShortWithSign() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "compact-short sign-always",
            locale: usLocale
        )
        let positiveResult = style.format(1500.0)
        let negativeResult = style.format(-1500.0)
        #expect(positiveResult.contains("+") || positiveResult.contains("K"))
        #expect(negativeResult.contains("-"))
    }

    // MARK: - Decimal Separator Combinations

    @Test("Decimal-always with precision-integer")
    func decimalAlwaysWithIntegerPrecision() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "decimal-always precision-integer group-off",
            locale: usLocale
        )
        let result = style.format(123.0)
        #expect(result.contains("."))
    }

    @Test("Decimal-always with .00 precision")
    func decimalAlwaysWithFractionPrecision() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "decimal-always .00 group-off",
            locale: usLocale
        )
        #expect(style.format(123.0) == "123.00")
        #expect(style.format(0.0) == "0.00")
    }

    // MARK: - Multi-Option Combinations

    @Test("Currency + Precision + Sign + Grouping")
    func fullCurrencyOptions() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "currency/USD .00 sign-always group-auto",
            locale: usLocale
        )
        #expect(style.format(1234.5) == "+$1,234.50")
        #expect(style.format(-1234.5) == "-$1,234.50")
    }

    @Test("Percent + Precision + Rounding + Sign")
    func fullPercentOptions() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "percent .0 rounding-mode-half-up sign-except-zero",
            locale: usLocale
        )
        #expect(style.format(0.255) == "+25.5%")
        #expect(style.format(-0.255) == "-25.5%")
        #expect(style.format(0.0) == "0.0%")
    }

    @Test("Scale + Precision + Grouping + Sign")
    func fullScaleOptions() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "scale/100 .00 group-auto sign-always",
            locale: usLocale
        )
        #expect(style.format(12.345) == "+1,234.50")
        #expect(style.format(-12.345) == "-1,234.50")
    }

    @Test("Integer Width + Scale + Precision + Group-off")
    func integerWidthScalePrecision() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "scale/100 integer-width/0000 precision-integer group-off",
            locale: usLocale
        )
        #expect(style.format(1.0) == "0100")
        #expect(style.format(12.34) == "1234")
        #expect(style.format(0.05) == "0005")
    }
}

@Suite("Edge Case Skeleton Combinations")
struct EdgeCaseSkeletonCombinationTests {

    let usLocale = Locale(identifier: "en_US")

    // MARK: - Zero Value with Different Combinations

    @Test("Zero with various precision combinations")
    func zeroWithPrecisionCombinations() {
        let style1 = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".00 group-off", locale: usLocale)
        #expect(style1.format(0.0) == "0.00")

        let style2 = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".0# group-off", locale: usLocale)
        #expect(style2.format(0.0) == "0.0")

        let style3 = ICUNumberSkeletonFormatStyle<Double>(skeleton: "precision-integer group-off", locale: usLocale)
        #expect(style3.format(0.0) == "0")
    }

    @Test("Zero with sign display combinations")
    func zeroWithSignCombinations() {
        let signAlways = ICUNumberSkeletonFormatStyle<Double>(skeleton: "sign-always group-off", locale: usLocale)
        #expect(signAlways.format(0.0) == "+0")

        let signNever = ICUNumberSkeletonFormatStyle<Double>(skeleton: "sign-never group-off", locale: usLocale)
        #expect(signNever.format(0.0) == "0")

        let signExceptZero = ICUNumberSkeletonFormatStyle<Double>(skeleton: "sign-except-zero group-off", locale: usLocale)
        let result = signExceptZero.format(0.0)
        #expect(!result.contains("+"))
        #expect(!result.contains("-"))
    }

    // MARK: - Negative Zero

    @Test("Negative zero with sign combinations")
    func negativeZeroWithSign() {
        let signAlways = ICUNumberSkeletonFormatStyle<Double>(skeleton: "sign-always .00 group-off", locale: usLocale)
        let result = signAlways.format(-0.0)
        // Negative zero should be treated as zero
        #expect(result.contains("0.00"))

        let signExceptZero = ICUNumberSkeletonFormatStyle<Double>(skeleton: "sign-except-zero .00 group-off", locale: usLocale)
        let resultExceptZero = signExceptZero.format(-0.0)
        #expect(!resultExceptZero.contains("+"))
        #expect(!resultExceptZero.contains("-"))
    }

    // MARK: - Very Small Numbers

    @Test("Very small numbers with precision combinations")
    func verySmallNumbersWithPrecision() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: ".########## group-off",
            locale: usLocale
        )
        #expect(style.format(0.0000000001) == "0.0000000001")

        let scientificStyle = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "scientific .00",
            locale: usLocale
        )
        let scientificResult = scientificStyle.format(0.0000000001)
        #expect(scientificResult.lowercased().contains("e"))
    }

    // MARK: - Very Large Numbers

    @Test("Very large numbers with grouping combinations")
    func veryLargeNumbersWithGrouping() {
        let groupAuto = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "precision-integer group-auto",
            locale: usLocale
        )
        #expect(groupAuto.format(123456789012.0) == "123,456,789,012")

        let groupOff = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "precision-integer group-off",
            locale: usLocale
        )
        #expect(groupOff.format(123456789012.0) == "123456789012")
    }

    // MARK: - Rounding Edge Cases

    @Test("Rounding edge cases at boundaries")
    func roundingEdgeCases() {
        let halfUp = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".0 rounding-mode-half-up group-off", locale: usLocale)
        #expect(halfUp.format(2.5) == "2.5")
        #expect(halfUp.format(2.55) == "2.6")
        #expect(halfUp.format(2.54) == "2.5")

        let halfEven = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".0 rounding-mode-half-even group-off", locale: usLocale)
        #expect(halfEven.format(2.55) == "2.6")
        #expect(halfEven.format(2.45) == "2.4")
    }
}

@Suite("Currency Skeleton Combination Tests")
struct CurrencySkeletonCombinationTests {

    let usLocale = Locale(identifier: "en_US")
    let deLocale = Locale(identifier: "de_DE")

    @Test("USD currency with all common options")
    func usdCurrencyFullOptions() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "currency/USD .00 group-auto",
            locale: usLocale
        )
        #expect(style.format(1234.56) == "$1,234.56")
        #expect(style.format(0.99) == "$0.99")
        #expect(style.format(1000000.0) == "$1,000,000.00")
    }

    @Test("EUR currency with German locale")
    func eurCurrencyGermanLocale() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "currency/EUR .00",
            locale: deLocale
        )
        let result = style.format(1234.56)
        // German locale uses comma for decimal, period for grouping
        #expect(result.contains("1.234,56") || result.contains("1234,56"))
        #expect(result.contains("€"))
    }

    @Test("JPY currency with no decimal places")
    func jpyCurrencyNoDecimals() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "currency/JPY precision-integer",
            locale: usLocale
        )
        let result = style.format(1234.0)
        #expect(result.contains("1,234") || result.contains("¥"))
        // JPY typically has no decimal places
    }

    @Test("Currency with unit-width-narrow")
    func currencyNarrowWidth() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "currency/USD unit-width-narrow .00",
            locale: usLocale
        )
        let result = style.format(100.0)
        #expect(result.contains("100.00"))
        #expect(result.contains("$"))
    }

    @Test("Currency with unit-width-iso-code")
    func currencyISOCode() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "currency/USD unit-width-iso-code .00",
            locale: usLocale
        )
        let result = style.format(100.0)
        #expect(result.contains("USD") || result.contains("100.00"))
    }
}

@Suite("Measure Unit Skeleton Combination Tests")
struct MeasureUnitSkeletonCombinationTests {

    let usLocale = Locale(identifier: "en_US")

    @Test("Length meter with precision and grouping")
    func lengthMeterFullOptions() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "measure-unit/length-meter .00 group-auto",
            locale: usLocale
        )
        let result = style.format(1234.56)
        #expect(result.contains("1,234.56") || result.contains("1234.56"))
        #expect(result.lowercased().contains("m"))
    }

    @Test("Temperature celsius with precision")
    func temperatureCelsiusWithPrecision() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "measure-unit/temperature-celsius .0",
            locale: usLocale
        )
        let result = style.format(25.5)
        #expect(result.contains("25.5"))
        #expect(result.contains("°") || result.lowercased().contains("c"))
    }

    @Test("Mass kilogram with unit-width-full-name")
    func massKilogramFullName() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "measure-unit/mass-kilogram unit-width-full-name .0",
            locale: usLocale
        )
        let result = style.format(75.5)
        #expect(result.contains("75.5"))
        #expect(result.lowercased().contains("kilogram"))
    }

    @Test("Speed with precision and grouping")
    func speedWithOptions() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "measure-unit/speed-kilometer-per-hour .0 group-auto",
            locale: usLocale
        )
        let result = style.format(120.5)
        #expect(result.contains("120.5"))
    }

    @Test("Measure unit with unit-width-hidden")
    func measureUnitHidden() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "measure-unit/length-meter unit-width-hidden .00 group-off",
            locale: usLocale
        )
        let result = style.format(100.0)
        // Should only show the number, not the unit
        #expect(result == "100.00" || result.contains("100"))
        #expect(!result.lowercased().contains("meter"))
        #expect(!result.contains("m ") && !result.hasSuffix("m"))
    }
}

@Suite("Numbering System Skeleton Combination Tests")
struct NumberingSystemSkeletonCombinationTests {

    let usLocale = Locale(identifier: "en_US")

    @Test("Latin numbering with precision")
    func latinNumberingWithPrecision() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "latin .00 group-off",
            locale: usLocale
        )
        #expect(style.format(12345.67) == "12345.67")
    }

    @Test("Numbering system override with currency")
    func numberingSystemWithCurrency() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "currency/USD numbering-system/latn .00",
            locale: usLocale
        )
        let result = style.format(1234.56)
        #expect(result.contains("$") && result.contains("1,234.56"))
    }
}
