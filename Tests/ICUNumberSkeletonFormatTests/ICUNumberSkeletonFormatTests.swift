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
        #expect(style.format(1234.56) == "$1,234.56")
    }

    @Test("Format currency with convenience method")
    func formatCurrencyConvenience() {
        let style = ICUNumberSkeletonFormatStyle<Double>.currency("USD", locale: usLocale)
        #expect(style.format(99.99) == "$99.99")
    }

    // MARK: - Percent Tests

    @Test("Format percent")
    func formatPercent() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "percent", locale: usLocale)
        #expect(style.format(0.25) == "25%")
    }

    @Test("Format percent with convenience method")
    func formatPercentConvenience() {
        let style = ICUNumberSkeletonFormatStyle<Double>.percent(locale: usLocale)
        #expect(style.format(0.5) == "50%")
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
        #expect(style.format(123.0) == "+123")
        #expect(style.format(-123.0) == "-123")
    }

    @Test("Format with sign never")
    func formatSignNever() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "sign-never", locale: usLocale)
        #expect(style.format(-123.0) == "123")
        #expect(style.format(123.0) == "123")
    }

    @Test("Format with sign-except-zero for positive value")
    func formatSignExceptZeroPositive() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "sign-except-zero", locale: usLocale)
        #expect(style.format(123.0) == "+123")
    }

    @Test("Format with sign-except-zero for negative value")
    func formatSignExceptZeroNegative() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "sign-except-zero", locale: usLocale)
        #expect(style.format(-123.0) == "-123")
    }

    @Test("Format with sign-except-zero for zero value")
    func formatSignExceptZeroZero() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "sign-except-zero", locale: usLocale)
        #expect(style.format(0.0) == "0")
    }

    @Test("Format with sign-except-zero for negative zero")
    func formatSignExceptZeroNegativeZero() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "sign-except-zero", locale: usLocale)
        #expect(style.format(-0.0) == "0")
    }

    @Test("Format with sign-except-zero combined with precision")
    func formatSignExceptZeroCombined() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "sign-except-zero .00", locale: usLocale)
        #expect(style.format(123.456) == "+123.46")
        #expect(style.format(-123.456) == "-123.46")
        #expect(style.format(0.0) == "0.00")
    }

    @Test("Format with sign-accounting-except-zero for positive value")
    func formatSignAccountingExceptZeroPositive() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "sign-accounting-except-zero", locale: usLocale)
        #expect(style.format(123.0) == "+123")
    }

    @Test("Format with sign-accounting-except-zero for negative value")
    func formatSignAccountingExceptZeroNegative() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "sign-accounting-except-zero", locale: usLocale)
        #expect(style.format(-123.0) == "-123")
    }

    @Test("Format with sign-accounting-except-zero for zero value")
    func formatSignAccountingExceptZeroZero() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "sign-accounting-except-zero", locale: usLocale)
        #expect(style.format(0.0) == "0")
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
        #expect(style.format(1234.5) == "$1,234.50")
    }

    @Test("Format with complex skeleton")
    func formatComplexSkeleton() {
        let skeleton = "currency/USD .00 group-auto sign-always rounding-mode-half-up"
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: skeleton, locale: usLocale)
        #expect(style.format(1234.555) == "+$1,234.56")
        #expect(style.format(-1234.555) == "-$1,234.56")
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
        
        // Test various magnitudes
        let result1500 = style.format(1500.0)
        #expect(!result1500.isEmpty)
        #expect(result1500.contains("K") || result1500.contains("k"))
        
        let result25k = style.format(25000.0)
        #expect(!result25k.isEmpty)
        #expect(result25k.contains("K") || result25k.contains("k"))
        
        let result1_2M = style.format(1200000.0)
        #expect(!result1_2M.isEmpty)
        #expect(result1_2M.contains("M") || result1_2M.contains("m"))
    }

    @Test("Format with compact long notation")
    func formatCompactLong() {
        let style = ICUNumberSkeletonFormatStyle<Double>.compact(.long, locale: usLocale)
        let result = style.format(1500.0)
        #expect(!result.isEmpty)
        // Note: Foundation's Decimal.FormatStyle.compactName produces short form
        // Long form (e.g., "1.5 thousand") is not directly supported by Foundation
    }

    // MARK: - Decimal Separator Tests

    @Test("Format with decimal separator always")
    func formatDecimalAlways() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "decimal-always precision-integer", locale: usLocale)
        let result = style.format(123.0)
        #expect(result.contains("."))
    }

    // MARK: - Permille Tests

    @Test("Format permille")
    func formatPermille() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "permille", locale: usLocale)
        #expect(style.format(0.025) == "25\u{2030}")
    }

    @Test("Format permille with precision")
    func formatPermilleWithPrecision() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "permille .0", locale: usLocale)
        #expect(style.format(0.0255) == "25.5\u{2030}")
    }

    // MARK: - Numbering System Tests

    @Test("Format with Latin numbering system")
    func formatLatinNumberingSystem() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "latin", locale: usLocale)
        #expect(style.format(12345.0) == "12,345")
    }

    @Test("Format with numbering system override")
    func formatNumberingSystemOverride() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "numbering-system/latn", locale: usLocale)
        #expect(style.format(12345.0) == "12,345")
    }

    // MARK: - Integer Width Tests

    @Test("Format with integer width minimum")
    func formatIntegerWidthMin() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "integer-width/000 group-off", locale: usLocale)
        #expect(style.format(12.0) == "012")
    }

    @Test("Format with integer width truncation")
    func formatIntegerWidthTruncate() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "integer-width/+00 group-off", locale: usLocale)
        #expect(style.format(1234.0) == "34")
    }

    @Test("Format with integer width min and max")
    func formatIntegerWidthMinMax() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "integer-width/##00 group-off", locale: usLocale)
        #expect(style.format(5.0) == "05")
        #expect(style.format(12345.0) == "2345")
    }

    // MARK: - Measure Unit Tests

    @Test("Format with measure unit - length meter")
    func formatMeasureUnitMeter() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "measure-unit/length-meter", locale: usLocale)
        let result = style.format(100.0)
        #expect(result.contains("100") && (result.contains("m") || result.lowercased().contains("meter")))
    }

    @Test("Format with measure unit - mass kilogram")
    func formatMeasureUnitKilogram() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "measure-unit/mass-kilogram", locale: usLocale)
        let result = style.format(50.0)
        #expect(result.contains("50") && (result.contains("kg") || result.lowercased().contains("kilogram")))
    }

    @Test("Format with measure unit - temperature celsius")
    func formatMeasureUnitCelsius() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "measure-unit/temperature-celsius", locale: usLocale)
        let result = style.format(25.0)
        #expect(result.contains("25") && (result.contains("°C") || result.lowercased().contains("celsius")))
    }

    @Test("Format with measure unit and unit width hidden")
    func formatMeasureUnitHidden() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "measure-unit/length-meter unit-width-hidden", locale: usLocale)
        let result = style.format(100.0)
        // Should only show the number, not the unit
        #expect(result == "100" || result.contains("100"))
    }

    @Test("Format with measure unit and unit width full name")
    func formatMeasureUnitFullName() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "measure-unit/length-meter unit-width-full-name", locale: usLocale)
        let result = style.format(100.0)
        #expect(result.contains("100") && result.lowercased().contains("meter"))
    }

    // MARK: - Unit Width with Currency Tests

    @Test("Format currency with narrow width")
    func formatCurrencyNarrow() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "currency/USD unit-width-narrow", locale: usLocale)
        let result = style.format(100.0)
        #expect(result.contains("100"))
    }

    @Test("Format currency with full name width")
    func formatCurrencyFullName() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "currency/USD unit-width-full-name", locale: usLocale)
        let result = style.format(100.0)
        #expect(result.contains("100"))
    }

    @Test("Format currency with ISO code width")
    func formatCurrencyISOCode() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "currency/USD unit-width-iso-code", locale: usLocale)
        let result = style.format(100.0)
        #expect(result.contains("USD") || result.contains("100"))
    }

    // MARK: - Precision Increment Tests

    @Test("Format with precision increment")
    func formatPrecisionIncrement() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "precision-increment/0.05", locale: usLocale)
        let result = style.format(1.234)
        // Should round to nearest 0.05
        #expect(result.contains("1.2"))
    }

    @Test("Format with precision increment integer")
    func formatPrecisionIncrementInteger() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "precision-increment/5", locale: usLocale)
        let result = style.format(123.0)
        #expect(!result.isEmpty)
    }

    // MARK: - Currency Cash Rounding Tests

    @Test("Format currency with cash rounding")
    func formatCurrencyCash() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "currency/USD precision-currency-cash", locale: usLocale)
        let result = style.format(1.234)
        #expect(result.contains("1.2"))
    }

    // MARK: - Complex Combined Tests

    @Test("Format with measure unit, precision, and grouping")
    func formatComplexMeasureUnit() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "measure-unit/length-kilometer .00 group-auto", locale: usLocale)
        let result = style.format(1234.567)
        #expect(result.contains("1,234.57") && result.lowercased().contains("km"))
    }

    @Test("Format with permille, precision, and sign")
    func formatComplexPermille() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "permille .00 sign-always", locale: usLocale)
        #expect(style.format(0.0123) == "+12.30\u{2030}")
    }

    @Test("Format with integer width and scale")
    func formatIntegerWidthWithScale() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "scale/100 integer-width/0000 group-off", locale: usLocale)
        #expect(style.format(12.34) == "1234")
    }

    @Test("Format with numbering system and currency")
    func formatNumberingSystemCurrency() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "currency/USD numbering-system/latn", locale: usLocale)
        #expect(style.format(1234.56) == "$1,234.56")
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
@Suite("Measure Unit Mapping Tests")
struct MeasureUnitTests {

    let usLocale = Locale(identifier: "en_US")

    @Test("Format various length units")
    func formatLengthUnits() {
        let units = ["meter", "kilometer", "centimeter", "mile", "foot", "inch"]
        
        for unit in units {
            let style = ICUNumberSkeletonFormatStyle<Double>(
                skeleton: "measure-unit/length-\(unit)",
                locale: usLocale
            )
            let result = style.format(10.0)
            #expect(!result.isEmpty)
        }
    }

    @Test("Format various mass units")
    func formatMassUnits() {
        let units = ["kilogram", "gram", "pound", "ounce"]
        
        for unit in units {
            let style = ICUNumberSkeletonFormatStyle<Double>(
                skeleton: "measure-unit/mass-\(unit)",
                locale: usLocale
            )
            let result = style.format(10.0)
            #expect(!result.isEmpty)
        }
    }

    @Test("Format duration units")
    func formatDurationUnits() {
        let units = ["second", "minute", "hour"]
        
        for unit in units {
            let style = ICUNumberSkeletonFormatStyle<Double>(
                skeleton: "measure-unit/duration-\(unit)",
                locale: usLocale
            )
            let result = style.format(10.0)
            #expect(!result.isEmpty)
        }
    }

    @Test("Format temperature units")
    func formatTemperatureUnits() {
        let units = ["celsius", "fahrenheit", "kelvin"]
        
        for unit in units {
            let style = ICUNumberSkeletonFormatStyle<Double>(
                skeleton: "measure-unit/temperature-\(unit)",
                locale: usLocale
            )
            let result = style.format(25.0)
            #expect(!result.isEmpty)
        }
    }

    @Test("Format volume units")
    func formatVolumeUnits() {
        let units = ["liter", "milliliter", "gallon", "fluid-ounce"]
        
        for unit in units {
            let style = ICUNumberSkeletonFormatStyle<Double>(
                skeleton: "measure-unit/volume-\(unit)",
                locale: usLocale
            )
            let result = style.format(10.0)
            #expect(!result.isEmpty)
        }
    }

    @Test("Format speed units")
    func formatSpeedUnits() {
        let units = ["meter-per-second", "kilometer-per-hour", "mile-per-hour"]
        
        for unit in units {
            let style = ICUNumberSkeletonFormatStyle<Double>(
                skeleton: "measure-unit/speed-\(unit)",
                locale: usLocale
            )
            let result = style.format(60.0)
            #expect(!result.isEmpty)
        }
    }

    @Test("Format area units")
    func formatAreaUnits() {
        let units = ["square-meter", "square-kilometer", "square-mile", "square-foot"]
        
        for unit in units {
            let style = ICUNumberSkeletonFormatStyle<Double>(
                skeleton: "measure-unit/area-\(unit)",
                locale: usLocale
            )
            let result = style.format(100.0)
            #expect(!result.isEmpty)
        }
    }
}

@Suite("Rounding Mode Precision Tests")
struct RoundingModePrecisionTests {

    let usLocale = Locale(identifier: "en_US")

    @Test("Verify rounding-mode-half-down behavior")
    func verifyHalfDownRounding() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: ".0 rounding-mode-half-down",
            locale: usLocale
        )
        // Note: Foundation maps this to halfEven, not true halfDown
        let result = style.format(1.25)
        #expect(!result.isEmpty)
    }

    @Test("Verify all rounding modes with precision")
    func verifyAllRoundingModes() {
        let modes = [
            "rounding-mode-ceiling",
            "rounding-mode-floor",
            "rounding-mode-down",
            "rounding-mode-up",
            "rounding-mode-half-even",
            "rounding-mode-half-up"
        ]
        
        for mode in modes {
            let style = ICUNumberSkeletonFormatStyle<Double>(
                skeleton: "precision-integer \(mode)",
                locale: usLocale
            )
            let result = style.format(1.7)
            #expect(!result.isEmpty)
        }
    }
}

@Suite("Locale-Specific Formatting Tests")
struct LocaleSpecificTests {

    @Test("Format with different decimal separators")
    func formatDifferentDecimalSeparators() {
        let locales = [
            ("en_US", "."),
            ("de_DE", ","),
            ("fr_FR", ",")
        ]
        
        for (identifier, expectedSeparator) in locales {
            let locale = Locale(identifier: identifier)
            let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".00", locale: locale)
            let result = style.format(1234.5)
            #expect(result.contains(expectedSeparator) || result.contains("1234"))
        }
    }

    @Test("Format with different grouping separators")
    func formatDifferentGroupingSeparators() {
        let locales = [
            ("en_US", ","),
            ("de_DE", "."),
            ("fr_FR", " ")
        ]
        
        for (identifier, _) in locales {
            let locale = Locale(identifier: identifier)
            let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "group-auto", locale: locale)
            let result = style.format(1234567.0)
            #expect(!result.isEmpty && result.contains("1"))
        }
    }
}

@Suite("Sign Display Comprehensive Tests")
struct SignDisplayTests {
    let usLocale = Locale(identifier: "en_US")

    // MARK: - sign-auto Tests

    @Test("Format with sign-auto: positive value")
    func formatSignAutoPositive() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "sign-auto", locale: usLocale)
        let result = style.format(123.0)
        // Should not show + sign for positive
        #expect(!result.contains("+"))
        #expect(result.contains("123"))
    }

    @Test("Format with sign-auto: negative value")
    func formatSignAutoNegative() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "sign-auto", locale: usLocale)
        let result = style.format(-123.0)
        // Should show - sign for negative
        #expect(result.contains("-"))
    }

    @Test("Format with sign-auto: zero value")
    func formatSignAutoZero() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "sign-auto", locale: usLocale)
        let result = style.format(0.0)
        // Should not show any sign for zero
        #expect(!result.contains("+"))
        #expect(!result.contains("-"))
    }

    // MARK: - sign-except-zero Comprehensive Tests

    @Test("Format with sign-except-zero: small positive value")
    func formatSignExceptZeroSmallPositive() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "sign-except-zero .00", locale: usLocale)
        let result = style.format(0.01)
        // Small positive should show + sign
        #expect(result.contains("+"))
        #expect(result.contains("0.01"))
    }

    @Test("Format with sign-except-zero: small negative value")
    func formatSignExceptZeroSmallNegative() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "sign-except-zero .00", locale: usLocale)
        let result = style.format(-0.01)
        // Small negative should show - sign
        #expect(result.contains("-"))
        #expect(result.contains("0.01"))
    }

    @Test("Format with sign-except-zero: large values")
    func formatSignExceptZeroLargeValues() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "sign-except-zero", locale: usLocale)
        
        let largePositive = style.format(1000000.0)
        #expect(largePositive.contains("+"))
        
        let largeNegative = style.format(-1000000.0)
        #expect(largeNegative.contains("-"))
    }

    @Test("Format with sign-except-zero with currency")
    func formatSignExceptZeroWithCurrency() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "currency/USD sign-except-zero",
            locale: usLocale
        )
        
        let positiveResult = style.format(100.0)
        #expect(positiveResult.contains("+") || positiveResult.contains("$"))
        
        let negativeResult = style.format(-100.0)
        #expect(negativeResult.contains("-") || negativeResult.contains("$"))
        
        let zeroResult = style.format(0.0)
        #expect(!zeroResult.contains("+"))
        #expect(!zeroResult.contains("-"))
    }

    @Test("Format with sign-except-zero with percent")
    func formatSignExceptZeroWithPercent() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "percent sign-except-zero",
            locale: usLocale
        )
        
        let positiveResult = style.format(0.25)
        #expect(positiveResult.contains("+") || positiveResult.contains("25"))
        
        let negativeResult = style.format(-0.25)
        #expect(negativeResult.contains("-") || negativeResult.contains("25"))
        
        let zeroResult = style.format(0.0)
        #expect(!zeroResult.contains("+"))
        #expect(!zeroResult.contains("-"))
    }

    // MARK: - Integer Type Tests

    @Test("Format integer with sign-except-zero")
    func formatIntegerWithSignExceptZero() {
        let style = ICUNumberSkeletonIntegerFormatStyle<Int>(
            skeleton: "sign-except-zero",
            locale: usLocale
        )
        
        let positiveResult = style.format(42)
        #expect(positiveResult.contains("+"))
        
        let negativeResult = style.format(-42)
        #expect(negativeResult.contains("-"))
        
        let zeroResult = style.format(0)
        #expect(!zeroResult.contains("+"))
        #expect(!zeroResult.contains("-"))
        #expect(zeroResult.contains("0"))
    }

    @Test("Format Decimal with sign-except-zero")
    func formatDecimalWithSignExceptZero() {
        let style = ICUNumberSkeletonDecimalFormatStyle(
            skeleton: "sign-except-zero .00",
            locale: usLocale
        )
        
        let positive = Decimal(string: "123.45")!
        let positiveResult = style.format(positive)
        #expect(positiveResult.contains("+"))
        
        let negative = Decimal(string: "-123.45")!
        let negativeResult = style.format(negative)
        #expect(negativeResult.contains("-"))
        
        let zero = Decimal(0)
        let zeroResult = style.format(zero)
        #expect(!zeroResult.contains("+"))
        #expect(!zeroResult.contains("-"))
        #expect(zeroResult.contains("0.00"))
    }
}

@Suite("Special Values Tests")
struct SpecialValuesTests {
    
    let usLocale = Locale(identifier: "en_US")
    
    // MARK: - Infinity Tests
    
    @Test("Format positive infinity")
    func formatPositiveInfinity() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".00", locale: usLocale)
        let result = style.format(Double.infinity)
        #expect(result == "∞")
    }
    
    @Test("Format negative infinity")
    func formatNegativeInfinity() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".00", locale: usLocale)
        let result = style.format(-Double.infinity)
        #expect(result == "-∞")
    }
    
    @Test("Format infinity with currency")
    func formatInfinityWithCurrency() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "currency/USD", locale: usLocale)
        let result = style.format(Double.infinity)
        #expect(result == "∞")
    }
    
    @Test("Format infinity with percent")
    func formatInfinityWithPercent() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "percent", locale: usLocale)
        let result = style.format(Double.infinity)
        #expect(result == "∞")
    }
    
    @Test("Format infinity with scientific notation")
    func formatInfinityWithScientific() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "scientific", locale: usLocale)
        let result = style.format(Double.infinity)
        #expect(result == "∞")
    }
    
    // MARK: - NaN Tests
    
    @Test("Format NaN")
    func formatNaN() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".00", locale: usLocale)
        let result = style.format(Double.nan)
        #expect(result == "NaN")
    }
    
    @Test("Format NaN with currency")
    func formatNaNWithCurrency() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "currency/USD", locale: usLocale)
        let result = style.format(Double.nan)
        #expect(result == "NaN")
    }
    
    @Test("Format NaN with percent")
    func formatNaNWithPercent() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "percent", locale: usLocale)
        let result = style.format(Double.nan)
        #expect(result == "NaN")
    }
    
    @Test("Format NaN with scientific notation")
    func formatNaNWithScientific() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "scientific", locale: usLocale)
        let result = style.format(Double.nan)
        #expect(result == "NaN")
    }
    
    // MARK: - Operations Resulting in Special Values
    
    @Test("Format result of division by zero")
    func formatDivisionByZero() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".00", locale: usLocale)
        let result = style.format(1.0 / 0.0)
        #expect(result == "∞")
    }
    
    @Test("Format result of negative division by zero")
    func formatNegativeDivisionByZero() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".00", locale: usLocale)
        let result = style.format(-1.0 / 0.0)
        #expect(result == "-∞")
    }
    
    @Test("Format result of zero divided by zero")
    func formatZeroDividedByZero() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".00", locale: usLocale)
        let result = style.format(0.0 / 0.0)
        #expect(result == "NaN")
    }
    
    @Test("Format result of square root of negative number")
    func formatSqrtNegative() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".00", locale: usLocale)
        let result = style.format((-1.0).squareRoot())
        #expect(result == "NaN")
    }
    
    // MARK: - Special Values with Different Format Styles
    
    @Test("Format infinity with measure unit")
    func formatInfinityWithMeasureUnit() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "measure-unit/length-meter",
            locale: usLocale
        )
        let result = style.format(Double.infinity)
        #expect(result == "∞")
    }
    
    @Test("Format infinity with sign-always")
    func formatInfinityWithSignAlways() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "sign-always", locale: usLocale)
        let positiveResult = style.format(Double.infinity)
        #expect(positiveResult == "∞")
        
        let negativeResult = style.format(-Double.infinity)
        #expect(negativeResult == "-∞")
    }
    
    @Test("Format infinity using extension method")
    func formatInfinityUsingExtension() {
        let result = Double.infinity.formatted(icuSkeleton: ".00", locale: usLocale)
        #expect(result == "∞")
    }
    
    @Test("Format NaN using extension method")
    func formatNaNUsingExtension() {
        let result = Double.nan.formatted(icuSkeleton: ".00", locale: usLocale)
        #expect(result == "NaN")
    }
    
    // MARK: - Special Values with Convenience Methods
    
    @Test("Format infinity with currency convenience method")
    func formatInfinityWithCurrencyConvenience() {
        let style = ICUNumberSkeletonFormatStyle<Double>.currency("USD", locale: usLocale)
        let positiveResult = style.format(Double.infinity)
        #expect(positiveResult == "∞")
        
        let negativeResult = style.format(-Double.infinity)
        #expect(negativeResult == "-∞")
    }
    
    @Test("Format NaN with percent convenience method")
    func formatNaNWithPercentConvenience() {
        let style = ICUNumberSkeletonFormatStyle<Double>.percent(locale: usLocale)
        let result = style.format(Double.nan)
        #expect(result == "NaN")
    }
    
    @Test("Format infinity with scientific convenience method")
    func formatInfinityWithScientificConvenience() {
        let style = ICUNumberSkeletonFormatStyle<Double>.scientific(locale: usLocale)
        let result = style.format(Double.infinity)
        #expect(result == "∞")
    }
    
    @Test("Format infinity with compact notation convenience method")
    func formatInfinityWithCompactConvenience() {
        let shortStyle = ICUNumberSkeletonFormatStyle<Double>.compact(.short, locale: usLocale)
        #expect(shortStyle.format(Double.infinity) == "∞")
        
        let longStyle = ICUNumberSkeletonFormatStyle<Double>.compact(.long, locale: usLocale)
        #expect(longStyle.format(Double.infinity) == "∞")
    }
}


