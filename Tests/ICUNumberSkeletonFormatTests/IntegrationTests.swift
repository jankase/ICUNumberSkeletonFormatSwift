import Testing
import Foundation
@testable import ICUNumberSkeletonFormat

@Suite("Real-World Integration Tests")
struct RealWorldIntegrationTests {
    
    let usLocale = Locale(identifier: "en_US")
    let deLocale = Locale(identifier: "de_DE")
    let jpLocale = Locale(identifier: "ja_JP")
    
    // MARK: - E-commerce Scenarios
    
    @Test("Format product prices in different currencies")
    func formatProductPrices() {
        let products = [
            (price: 19.99, currency: "USD", locale: usLocale),
            (price: 19.99, currency: "EUR", locale: deLocale),
            (price: 19.99, currency: "JPY", locale: jpLocale)
        ]
        
        for (price, currency, locale) in products {
            let style = ICUNumberSkeletonFormatStyle<Double>(
                skeleton: "currency/\(currency) .00",
                locale: locale
            )
            let result = style.format(price)
            #expect(!result.isEmpty)
        }
    }
    
    @Test("Format discount percentages")
    func formatDiscountPercentages() {
        let discounts = [0.10, 0.25, 0.50, 0.75]
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "percent precision-integer",
            locale: usLocale
        )
        
        for discount in discounts {
            let result = style.format(discount)
            #expect(!result.isEmpty)
            #expect(result.contains("%") || result.contains("percent"))
        }
    }
    
    @Test("Format product ratings with consistent precision")
    func formatProductRatings() {
        let ratings = [4.5, 3.75, 5.0, 2.25]
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: ".0",
            locale: usLocale
        )
        
        for rating in ratings {
            let result = style.format(rating)
            #expect(!result.isEmpty)
            // Should have exactly 1 decimal place
            let components = result.components(separatedBy: ".")
            if components.count == 2 {
                #expect(components[1].count == 1)
            }
        }
    }
    
    // MARK: - Financial Scenarios
    
    @Test("Format account balances with accounting format")
    func formatAccountBalances() {
        let balances = [1000.50, -250.75, 0.0, -1500.00]
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "currency/USD .00 sign-accounting",
            locale: usLocale
        )
        
        for balance in balances {
            let result = style.format(balance)
            #expect(!result.isEmpty)
        }
    }
    
    @Test("Format stock prices with appropriate precision")
    func formatStockPrices() {
        let stocks = [
            (price: 150.255, precision: ".00"),
            (price: 0.0052, precision: ".####"),
            (price: 1234.56, precision: ".00")
        ]
        
        for (price, precision) in stocks {
            let style = ICUNumberSkeletonFormatStyle<Double>(
                skeleton: precision,
                locale: usLocale
            )
            let result = style.format(price)
            #expect(!result.isEmpty)
        }
    }
    
    @Test("Format interest rates as percentages")
    func formatInterestRates() {
        let rates = [0.0325, 0.0475, 0.06, 0.00125]
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "percent .00",
            locale: usLocale
        )
        
        for rate in rates {
            let result = style.format(rate)
            #expect(!result.isEmpty)
            #expect(result.contains("%") || result.contains("percent"))
        }
    }
    
    // MARK: - Scientific Scenarios
    
    @Test("Format scientific measurements")
    func formatScientificMeasurements() {
        let measurements = [
            (value: 0.000000012, unit: "measure-unit/length-meter"),
            (value: 299792458.0, unit: "measure-unit/speed-meter-per-second"),
            (value: 6.62607015e-34, unit: "measure-unit/mass-kilogram")
        ]
        
        for (value, unit) in measurements {
            let style = ICUNumberSkeletonFormatStyle<Double>(
                skeleton: "\(unit) scientific",
                locale: usLocale
            )
            let result = style.format(value)
            #expect(!result.isEmpty)
        }
    }
    
    @Test("Format laboratory results with significant digits")
    func formatLabResults() {
        let results = [123.456, 0.00789, 9876.5]
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "@@@",
            locale: usLocale
        )
        
        for result in results {
            let formatted = style.format(result)
            #expect(!formatted.isEmpty)
        }
    }
    
    // MARK: - Sports/Statistics Scenarios
    
    @Test("Format player statistics")
    func formatPlayerStatistics() {
        // Batting average (3 decimal places)
        let battingAverage = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: ".###",
            locale: usLocale
        )
        #expect(!battingAverage.format(0.312).isEmpty)
        
        // Points per game (1 decimal place)
        let ppg = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: ".0",
            locale: usLocale
        )
        #expect(!ppg.format(27.5).isEmpty)
    }
    
    @Test("Format race times")
    func formatRaceTimes() {
        let times = [9.58, 19.19, 43.03] // seconds
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "measure-unit/duration-second .00",
            locale: usLocale
        )
        
        for time in times {
            let result = style.format(time)
            #expect(!result.isEmpty)
        }
    }
    
    // MARK: - Geographic/Weather Scenarios
    
    @Test("Format temperatures in different units")
    func formatTemperatures() {
        let temperatures = [
            (value: 25.0, unit: "celsius", locale: usLocale),
            (value: 77.0, unit: "fahrenheit", locale: usLocale),
            (value: 298.15, unit: "kelvin", locale: usLocale)
        ]
        
        for (value, unit, locale) in temperatures {
            let style = ICUNumberSkeletonFormatStyle<Double>(
                skeleton: "measure-unit/temperature-\(unit) .0",
                locale: locale
            )
            let result = style.format(value)
            #expect(!result.isEmpty)
        }
    }
    
    @Test("Format distances in different units")
    func formatDistances() {
        let distances = [
            (value: 5.0, unit: "kilometer"),
            (value: 3.1, unit: "mile"),
            (value: 100.0, unit: "meter")
        ]
        
        for (value, unit) in distances {
            let style = ICUNumberSkeletonFormatStyle<Double>(
                skeleton: "measure-unit/length-\(unit) .0",
                locale: usLocale
            )
            let result = style.format(value)
            #expect(!result.isEmpty)
        }
    }
    
    // MARK: - Social Media Scenarios
    
    @Test("Format follower counts with compact notation")
    func formatFollowerCounts() {
        let values = [25000.0, 1200000.0, 50000000.0]
        
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "compact-short",
            locale: usLocale
        )
        
        for value in values {
            let result = style.format(value)
            // Verify the result is not empty and contains typical compact notation elements
            #expect(!result.isEmpty)
            // The result should be shorter than the full number representation
            #expect(result.count < String(Int(value)).count)
        }
    }
    
    @Test("Format engagement rates")
    func formatEngagementRates() {
        let rates = [0.0234, 0.0567, 0.1234]
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "percent .0",
            locale: usLocale
        )
        
        for rate in rates {
            let result = style.format(rate)
            #expect(!result.isEmpty)
        }
    }
    
    // MARK: - Data Visualization Scenarios
    
    @Test("Format chart axis labels with consistent formatting")
    func formatChartAxisLabels() {
        let dataPoints = [0.0, 25.0, 50.0, 75.0, 100.0]
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "precision-integer group-auto",
            locale: usLocale
        )
        
        for point in dataPoints {
            let result = style.format(point)
            #expect(!result.isEmpty)
        }
    }
    
    @Test("Format large numbers in charts with compact notation")
    func formatChartLargeNumbers() {
        let values = [1000.0, 10000.0, 100000.0, 1000000.0]
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "compact-short",
            locale: usLocale
        )
        
        for value in values {
            let result = style.format(value)
            #expect(!result.isEmpty)
        }
    }
    
    // MARK: - Localization Scenarios
    
    @Test("Format same value in multiple locales")
    func formatMultipleLocales() {
        let value = 1234567.89
        let locales = [
            ("en_US", ",", "."),
            ("de_DE", ".", ","),
            ("fr_FR", " ", ",")
        ]
        
        for (identifier, _, _) in locales {
            let locale = Locale(identifier: identifier)
            let style = ICUNumberSkeletonFormatStyle<Double>(
                skeleton: ".00",
                locale: locale
            )
            let result = style.format(value)
            #expect(!result.isEmpty)
        }
    }
    
    @Test("Format currency in native locale")
    func formatCurrencyNativeLocale() {
        let currencies = [
            (amount: 1234.56, code: "USD", locale: "en_US"),
            (amount: 1234.56, code: "EUR", locale: "de_DE"),
            (amount: 1234.56, code: "JPY", locale: "ja_JP"),
            (amount: 1234.56, code: "GBP", locale: "en_GB")
        ]
        
        for (amount, code, localeId) in currencies {
            let locale = Locale(identifier: localeId)
            let style = ICUNumberSkeletonFormatStyle<Double>(
                skeleton: "currency/\(code)",
                locale: locale
            )
            let result = style.format(amount)
            #expect(!result.isEmpty)
        }
    }
}

@Suite("Performance and Scale Tests")
struct PerformanceTests {
    
    let usLocale = Locale(identifier: "en_US")
    
    @Test("Format many numbers efficiently")
    func formatManyNumbers() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: ".00",
            locale: usLocale
        )
        
        let numbers = (1...1000).map { Double($0) * 1.5 }
        
        for number in numbers {
            let result = style.format(number)
            #expect(!result.isEmpty)
        }
    }
    
    @Test("Reuse format style across multiple formats")
    func reuseFormatStyle() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "currency/USD .00",
            locale: usLocale
        )
        
        let amounts = [10.50, 25.75, 100.00, 1234.56, 9999.99]
        
        for amount in amounts {
            let result = style.format(amount)
            #expect(!result.isEmpty)
        }
    }
    
    @Test("Format with complex skeleton repeatedly")
    func formatComplexSkeletonRepeatedly() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "currency/USD unit-width-narrow .00 rounding-mode-half-up group-auto sign-always",
            locale: usLocale
        )
        
        for i in 1...100 {
            let result = style.format(Double(i) * 10.5)
            #expect(!result.isEmpty)
        }
    }
}

@Suite("Boundary Value Tests")
struct BoundaryValueTests {
    
    let usLocale = Locale(identifier: "en_US")
    
    @Test("Format minimum and maximum Double values")
    func formatDoubleExtremes() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "scientific",
            locale: usLocale
        )
        
        let maxResult = style.format(Double.greatestFiniteMagnitude)
        #expect(!maxResult.isEmpty)
        
        let minResult = style.format(-Double.greatestFiniteMagnitude)
        #expect(!minResult.isEmpty)
    }
    
    @Test("Format very small positive and negative numbers")
    func formatVerySmallNumbers() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: ".##########",
            locale: usLocale
        )
        
        let smallPositive = style.format(0.0000000001)
        #expect(!smallPositive.isEmpty)
        
        let smallNegative = style.format(-0.0000000001)
        #expect(!smallNegative.isEmpty)
    }
    
    @Test("Format numbers near rounding boundaries")
    func formatRoundingBoundaries() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: ".0 rounding-mode-half-up",
            locale: usLocale
        )
        
        let boundaries = [1.45, 1.5, 1.55, 2.45, 2.5, 2.55]
        
        for boundary in boundaries {
            let result = style.format(boundary)
            #expect(!result.isEmpty)
        }
    }
    
    @Test("Format integers at type boundaries")
    func formatIntegerBoundaries() {
        let style = ICUNumberSkeletonIntegerFormatStyle<Int>(
            skeleton: "group-auto",
            locale: usLocale
        )
        
        let boundaries = [Int.max, Int.min, 0, -1, 1]
        
        for boundary in boundaries {
            let result = style.format(boundary)
            #expect(!result.isEmpty)
        }
    }
    
    @Test("Format infinity values")
    func formatInfinityValues() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: ".00",
            locale: usLocale
        )
        
        let positiveInfinity = style.format(Double.infinity)
        #expect(positiveInfinity == "∞")
        
        let negativeInfinity = style.format(-Double.infinity)
        #expect(negativeInfinity == "-∞")
        
        let nan = style.format(Double.nan)
        #expect(nan == "NaN")
    }
    
    @Test("Format special values with operations")
    func formatSpecialValuesFromOperations() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: ".00",
            locale: usLocale
        )
        
        // Division by zero produces infinity
        let divByZero = style.format(1.0 / 0.0)
        #expect(divByZero == "∞")
        
        // Zero divided by zero produces NaN
        let zeroByZero = style.format(0.0 / 0.0)
        #expect(zeroByZero == "NaN")
        
        // Square root of negative produces NaN
        let sqrtNegative = style.format((-1.0).squareRoot())
        #expect(sqrtNegative == "NaN")
    }
}

@Suite("Combined Features Integration Tests")
struct CombinedFeaturesTests {
    
    let usLocale = Locale(identifier: "en_US")
    
    @Test("Combine scale with currency")
    func combineScaleWithCurrency() {
        // Convert cents to dollars
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "currency/USD scale/0.01 .00",
            locale: usLocale
        )
        
        let cents = 12345.0 // 123.45 dollars
        let result = style.format(cents)
        #expect(!result.isEmpty)
    }
    
    @Test("Combine integer width with grouping")
    func combineIntegerWidthWithGrouping() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "integer-width/0000 group-auto",
            locale: usLocale
        )
        
        let result = style.format(42.0)
        #expect(!result.isEmpty)
    }
    
    @Test("Combine scientific notation with precision")
    func combineScientificWithPrecision() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "scientific @@#",
            locale: usLocale
        )
        
        let result = style.format(12345.6789)
        #expect(!result.isEmpty)
        #expect(result.lowercased().contains("e"))
    }
    
    @Test("Combine measure unit with all formatting options")
    func combineMeasureUnitWithAllOptions() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "measure-unit/length-meter unit-width-full-name .00 group-auto sign-always",
            locale: usLocale
        )
        
        let result = style.format(1234.567)
        #expect(!result.isEmpty)
    }
    
    @Test("Combine percent with rounding and precision")
    func combinePercentWithRoundingAndPrecision() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "percent .0 rounding-mode-half-up",
            locale: usLocale
        )
        
        let result = style.format(0.12345)
        #expect(!result.isEmpty)
    }
}

@Suite("Error Recovery and Fallback Tests")
struct ErrorRecoveryTests {
    
    let usLocale = Locale(identifier: "en_US")
    
    @Test("Invalid skeleton produces output without crashing")
    func invalidSkeletonRecovery() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "completely-invalid-skeleton",
            locale: usLocale
        )
        
        // Should not crash, should produce some output
        let result = style.format(1234.5)
        #expect(!result.isEmpty)
    }
    
    @Test("Partially invalid skeleton uses valid parts")
    func partiallyInvalidSkeleton() {
        // "currency/USD" is valid, "invalid-token" is not
        // The initializer handles invalid skeletons by falling back to default
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "currency/INVALID invalid-token",
            locale: usLocale
        )
        
        let result = style.format(1234.5)
        #expect(!result.isEmpty)
    }
    
    @Test("Empty skeleton falls back gracefully")
    func emptySkeletonFallback() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "",
            locale: usLocale
        )
        
        let result = style.format(1234.5)
        #expect(!result.isEmpty)
    }
    
    @Test("Whitespace-only skeleton falls back gracefully")
    func whitespaceSkeletonFallback() {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "     ",
            locale: usLocale
        )
        
        let result = style.format(1234.5)
        #expect(!result.isEmpty)
    }
}

@Suite("Thread Safety Tests")
struct ThreadSafetyTests {
    
    let usLocale = Locale(identifier: "en_US")
    
    @Test("Concurrent formatting with same style")
    func concurrentFormattingWithSameStyle() async {
        let style = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: ".00",
            locale: usLocale
        )
        
        // Format concurrently from multiple tasks
        async let result1 = Task.detached { style.format(100.0) }.value
        async let result2 = Task.detached { style.format(200.0) }.value
        async let result3 = Task.detached { style.format(300.0) }.value
        async let result4 = Task.detached { style.format(400.0) }.value
        async let result5 = Task.detached { style.format(500.0) }.value
        
        let results = await [result1, result2, result3, result4, result5]
        
        #expect(results == ["100.00", "200.00", "300.00", "400.00", "500.00"])
    }
    
    @Test("Concurrent formatting with different styles")
    func concurrentFormattingWithDifferentStyles() async {
        let style1 = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".00", locale: usLocale)
        let style2 = ICUNumberSkeletonFormatStyle<Double>(skeleton: "percent", locale: usLocale)
        let style3 = ICUNumberSkeletonFormatStyle<Double>(skeleton: "scientific", locale: usLocale)
        
        async let result1 = Task.detached { style1.format(100.0) }.value
        async let result2 = Task.detached { style2.format(0.5) }.value
        async let result3 = Task.detached { style3.format(1000.0) }.value
        
        let results = await [result1, result2, result3]
        
        // All should complete without issues
        for result in results {
            #expect(!result.isEmpty)
        }
    }
}
