import Testing
import Foundation
@testable import ICUNumberSkeletonFormat

@Suite("ICUNumberSkeletonFormatStyle Tests")
struct ICUNumberSkeletonFormatStyleTests {

    // Use US locale for consistent test results
    let usLocale = Locale(identifier: "en_US")

    // MARK: - Basic Formatting Tests

    @Test("Format integer precision")
    func formatInteger() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "precision-integer", locale: usLocale)
        #expect(style.format(1234.567) == "1,235")
    }

    @Test("Format with exact fraction digits")
    func formatDecimal() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".00", locale: usLocale)
        #expect(style.format(1234.5) == "1,234.50")
    }

    @Test("Format with variable fraction digits")
    func formatDecimalVariable() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".0#", locale: usLocale)
        #expect(style.format(1234.5) == "1,234.5")
        #expect(style.format(1234.56) == "1,234.56")
        #expect(style.format(1234.0) == "1,234.0")
    }

    // MARK: - Currency Tests

    @Test("Format currency USD")
    func formatCurrencyUSD() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "currency/USD", locale: usLocale)
        let result = style.format(1234.56)
        #expect(result.contains("1,234.56") || result.contains("$"))
    }

    @Test("Format currency with convenience method")
    func formatCurrencyConvenience() {
        let style = ICUNumberSkeletonFormatStyle<Double>.currency("USD", locale: usLocale)
        let result = style.format(99.99)
        #expect(result.contains("99.99") || result.contains("$"))
    }

    // MARK: - Percent Tests

    @Test("Format percent")
    func formatPercent() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "percent", locale: usLocale)
        let result = style.format(0.25)
        #expect(result.contains("25") || result.contains("%"))
    }

    @Test("Format percent with convenience method")
    func formatPercentConvenience() {
        let style = ICUNumberSkeletonFormatStyle<Double>.percent(locale: usLocale)
        let result = style.format(0.5)
        #expect(result.contains("50") || result.contains("%"))
    }

    // MARK: - Scientific Notation Tests

    @Test("Format scientific notation")
    func formatScientific() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "scientific", locale: usLocale)
        let result = style.format(12345.0)
        #expect(result.lowercased().contains("e"))
    }

    @Test("Format scientific with convenience method")
    func formatScientificConvenience() {
        let style = ICUNumberSkeletonFormatStyle<Double>.scientific(locale: usLocale)
        let result = style.format(1000000.0)
        #expect(result.lowercased().contains("e"))
    }

    // MARK: - Grouping Tests

    @Test("Format with grouping off")
    func formatGroupOff() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "group-off", locale: usLocale)
        #expect(style.format(1234567.0) == "1234567")
    }

    @Test("Format with automatic grouping")
    func formatGroupAuto() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "group-auto", locale: usLocale)
        #expect(style.format(1234567.0) == "1,234,567")
    }

    // MARK: - Sign Display Tests

    @Test("Format with sign always")
    func formatSignAlways() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "sign-always", locale: usLocale)
        let result = style.format(123.0)
        #expect(result.contains("+"))
    }

    @Test("Format with sign never")
    func formatSignNever() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "sign-never", locale: usLocale)
        let result = style.format(-123.0)
        #expect(!result.contains("-"))
    }

    // MARK: - Scale Tests

    @Test("Format with scale")
    func formatScale() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "scale/100 precision-integer", locale: usLocale)
        #expect(style.format(0.5) == "50")
    }

    // MARK: - Significant Digits Tests

    @Test("Format with significant digits")
    func formatSignificantDigits() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "@@@", locale: usLocale)
        #expect(style.format(12345.0) == "12,300")
    }

    // MARK: - Rounding Mode Tests

    @Test("Format with ceiling rounding")
    func formatRoundingCeiling() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "precision-integer rounding-mode-ceiling", locale: usLocale)
        #expect(style.format(1.1) == "2")
    }

    @Test("Format with floor rounding")
    func formatRoundingFloor() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "precision-integer rounding-mode-floor", locale: usLocale)
        #expect(style.format(1.9) == "1")
    }

    @Test("Format with half-up rounding")
    func formatRoundingHalfUp() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "precision-integer rounding-mode-half-up", locale: usLocale)
        #expect(style.format(1.5) == "2")
    }

    @Test("Format with half-even (banker's) rounding")
    func formatRoundingHalfEven() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "precision-integer rounding-mode-half-even", locale: usLocale)
        #expect(style.format(2.5) == "2") // rounds to even
        #expect(style.format(3.5) == "4") // rounds to even
    }

    // MARK: - Combined Options Tests

    @Test("Format with combined currency and precision")
    func formatCombinedCurrencyPrecision() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "currency/USD .00", locale: usLocale)
        let result = style.format(1234.5)
        #expect(result.contains("1,234.50") || result.contains("$"))
    }

    @Test("Format with complex skeleton")
    func formatComplexSkeleton() {
        let skeleton = "currency/USD .00 group-auto sign-always rounding-mode-half-up"
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: skeleton, locale: usLocale)
        let result = style.format(1234.555)
        #expect(result.contains("+") || result.contains("$"))
    }

    // MARK: - Extension Tests

    @Test("Format using BinaryFloatingPoint extension")
    func formatFloatingPointExtension() {
        let result = 1234.5.formatted(icuSkeleton: ".00", locale: usLocale)
        #expect(result == "1,234.50")
    }

    @Test("Format using BinaryInteger extension")
    func formatIntegerExtension() {
        let result = 1234567.formatted(icuSkeleton: "group-off", locale: usLocale)
        #expect(result == "1234567")
    }

    @Test("Format using Decimal extension")
    func formatDecimalExtension() {
        let decimal = Decimal(string: "1234.5")!
        let result = decimal.formatted(icuSkeleton: ".00", locale: usLocale)
        #expect(result == "1,234.50")
    }

    // MARK: - Options Initialization Tests

    @Test("Initialize with pre-parsed options")
    func initWithOptions() {
        var options = SkeletonOptions()
        options.precision = .fractionDigits(min: 2, max: 2)
        options.grouping = .off

        let style = ICUNumberSkeletonFormatStyle<Double>(options: options, locale: usLocale)
        #expect(style.format(1234.5) == "1234.50")
    }

    // MARK: - Locale Tests

    @Test("Format with German locale")
    func formatWithGermanLocale() {
        let deLocale = Locale(identifier: "de_DE")
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".00", locale: deLocale)
        let result = style.format(1234.5)
        // German uses comma as decimal separator
        #expect(result.contains(","))
    }

    // MARK: - Integer Style Tests

    @Test("Format integer with ICUNumberSkeletonIntegerFormatStyle")
    func formatWithIntegerStyle() {
        let style = ICUNumberSkeletonIntegerFormatStyle<Int>(skeleton: "group-off", locale: usLocale)
        #expect(style.format(1234567) == "1234567")
    }

    // MARK: - Decimal Style Tests

    @Test("Format Decimal with ICUNumberSkeletonDecimalFormatStyle")
    func formatWithDecimalStyle() {
        let style = ICUNumberSkeletonDecimalFormatStyle(skeleton: ".00", locale: usLocale)
        let decimal = Decimal(string: "1234.5")!
        #expect(style.format(decimal) == "1,234.50")
    }

    // MARK: - Compact Notation Tests

    @Test("Format with compact short notation")
    func formatCompactShort() {
        let style = ICUNumberSkeletonFormatStyle<Double>.compact(.short, locale: usLocale)
        let result = style.format(1500.0)
        // Should contain abbreviated form
        #expect(result.count < 10)
    }

    @Test("Format with compact long notation")
    func formatCompactLong() {
        let style = ICUNumberSkeletonFormatStyle<Double>.compact(.long, locale: usLocale)
        let result = style.format(1500.0)
        #expect(!result.isEmpty)
    }

    // MARK: - Decimal Separator Tests

    @Test("Format with decimal separator always")
    func formatDecimalAlways() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "decimal-always precision-integer", locale: usLocale)
        let result = style.format(123.0)
        #expect(result.contains("."))
    }
}

@Suite("FormatStyle Protocol Conformance Tests")
struct FormatStyleProtocolTests {

    let usLocale = Locale(identifier: "en_US")

    @Test("ICUNumberSkeletonFormatStyle conforms to FormatStyle")
    func formatStyleConformance() {
        // Test that ICUNumberSkeletonFormatStyle can be used where FormatStyle is expected
        func testFormatStyle<F: FormatStyle>(_ style: F, value: F.FormatInput) -> F.FormatOutput {
            return style.format(value)
        }
        
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".00", locale: usLocale)
        let result = testFormatStyle(style, value: 123.45)
        #expect(result == "123.45")
    }

    @Test("Use .icuSkeleton static method")
    func useIcuSkeletonStaticMethod() {
        let result = 1234.5.formatted(.icuSkeleton(".00", locale: usLocale))
        #expect(result == "1,234.50")
    }
}
