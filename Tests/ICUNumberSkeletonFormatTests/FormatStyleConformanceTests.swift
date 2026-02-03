import Testing
import Foundation
@testable import ICUNumberSkeletonFormat

@Suite("ICUNumberSkeletonFormatStyle Codable Tests")
struct FormatStyleCodableTests {
    
    let usLocale = Locale(identifier: "en_US")
    
    @Test("ICUNumberSkeletonFormatStyle can be encoded and decoded")
    func formatStyleCodable() throws {
        let original = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "currency/USD .00",
            locale: usLocale
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ICUNumberSkeletonFormatStyle<Double>.self, from: data)
        
        #expect(decoded.options == original.options)
        #expect(decoded.locale.identifier == original.locale.identifier)
    }
    
    @Test("ICUNumberSkeletonFormatStyle with complex skeleton can be encoded and decoded")
    func formatStyleComplexCodable() throws {
        let original = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "currency/EUR unit-width-narrow .00 rounding-mode-half-up group-auto sign-always",
            locale: Locale(identifier: "de_DE")
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ICUNumberSkeletonFormatStyle<Double>.self, from: data)
        
        #expect(decoded.options == original.options)
        
        // Verify it still formats correctly after decoding
        let result = decoded.format(1234.56)
        #expect(!result.isEmpty)
    }
    
    @Test("ICUNumberSkeletonFormatStyle with pre-parsed options can be encoded and decoded")
    func formatStyleWithOptionsCodable() throws {
        var options = SkeletonOptions()
        options.precision = .fractionDigits(min: 2, max: 2)
        options.grouping = .off
        
        let original = ICUNumberSkeletonFormatStyle<Double>(options: options, locale: usLocale)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ICUNumberSkeletonFormatStyle<Double>.self, from: data)
        
        #expect(decoded.options == original.options)
        #expect(decoded.format(1234.5) == "1234.50")
    }
    
    @Test("ICUNumberSkeletonIntegerFormatStyle can be encoded and decoded")
    func integerFormatStyleCodable() throws {
        let original = ICUNumberSkeletonIntegerFormatStyle<Int>(
            skeleton: "group-off",
            locale: usLocale
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ICUNumberSkeletonIntegerFormatStyle<Int>.self, from: data)
        
        // Verify it formats correctly after decoding
        #expect(decoded.format(1234567) == "1234567")
    }
    
    @Test("ICUNumberSkeletonDecimalFormatStyle can be encoded and decoded")
    func decimalFormatStyleCodable() throws {
        let original = ICUNumberSkeletonDecimalFormatStyle(
            skeleton: ".00",
            locale: usLocale
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ICUNumberSkeletonDecimalFormatStyle.self, from: data)
        
        // Verify it formats correctly after decoding
        let decimal = Decimal(string: "1234.5")!
        #expect(decoded.format(decimal) == "1,234.50")
    }
}

@Suite("ICUNumberSkeletonFormatStyle Hashable Tests")
struct FormatStyleHashableTests {
    
    let usLocale = Locale(identifier: "en_US")
    
    @Test("ICUNumberSkeletonFormatStyle is hashable")
    func formatStyleHashable() {
        let style1 = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".00", locale: usLocale)
        let style2 = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".00", locale: usLocale)
        let style3 = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".0#", locale: usLocale)
        
        let set: Set = [style1, style2, style3]
        
        // style1 and style2 are identical, so set should contain 2 elements
        #expect(set.count == 2)
    }
    
    @Test("ICUNumberSkeletonFormatStyle can be used as Dictionary key")
    func formatStyleAsDictionaryKey() {
        let style1 = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".00", locale: usLocale)
        let style2 = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".0#", locale: usLocale)
        
        var dictionary: [ICUNumberSkeletonFormatStyle<Double>: String] = [:]
        dictionary[style1] = "exact"
        dictionary[style2] = "range"
        
        #expect(dictionary.count == 2)
        #expect(dictionary[style1] == "exact")
        #expect(dictionary[style2] == "range")
    }
    
    @Test("ICUNumberSkeletonIntegerFormatStyle is hashable")
    func integerFormatStyleHashable() {
        let style1 = ICUNumberSkeletonIntegerFormatStyle<Int>(skeleton: "group-off", locale: usLocale)
        let style2 = ICUNumberSkeletonIntegerFormatStyle<Int>(skeleton: "group-off", locale: usLocale)
        let style3 = ICUNumberSkeletonIntegerFormatStyle<Int>(skeleton: "group-auto", locale: usLocale)
        
        let set: Set = [style1, style2, style3]
        
        #expect(set.count == 2)
    }
    
    @Test("ICUNumberSkeletonDecimalFormatStyle is hashable")
    func decimalFormatStyleHashable() {
        let style1 = ICUNumberSkeletonDecimalFormatStyle(skeleton: ".00", locale: usLocale)
        let style2 = ICUNumberSkeletonDecimalFormatStyle(skeleton: ".00", locale: usLocale)
        let style3 = ICUNumberSkeletonDecimalFormatStyle(skeleton: ".0#", locale: usLocale)
        
        let set: Set = [style1, style2, style3]
        
        #expect(set.count == 2)
    }
}

@Suite("ICUNumberSkeletonFormatStyle Equatable Tests")
struct FormatStyleEquatableTests {
    
    let usLocale = Locale(identifier: "en_US")
    let deLocale = Locale(identifier: "de_DE")
    
    @Test("ICUNumberSkeletonFormatStyle equality with identical skeletons")
    func formatStyleEquality() {
        let style1 = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".00", locale: usLocale)
        let style2 = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".00", locale: usLocale)
        
        #expect(style1 == style2)
    }
    
    @Test("ICUNumberSkeletonFormatStyle inequality with different skeletons")
    func formatStyleInequalitySkeleton() {
        let style1 = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".00", locale: usLocale)
        let style2 = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".0#", locale: usLocale)
        
        #expect(style1 != style2)
    }
    
    @Test("ICUNumberSkeletonFormatStyle inequality with different locales")
    func formatStyleInequalityLocale() {
        let style1 = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".00", locale: usLocale)
        let style2 = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".00", locale: deLocale)
        
        #expect(style1 != style2)
    }
    
    @Test("ICUNumberSkeletonFormatStyle equality with pre-parsed options")
    func formatStyleEqualityOptions() {
        var options = SkeletonOptions()
        options.precision = .fractionDigits(min: 2, max: 2)
        
        let style1 = ICUNumberSkeletonFormatStyle<Double>(options: options, locale: usLocale)
        let style2 = ICUNumberSkeletonFormatStyle<Double>(options: options, locale: usLocale)
        
        #expect(style1 == style2)
    }
    
    @Test("ICUNumberSkeletonIntegerFormatStyle equality")
    func integerFormatStyleEquality() {
        let style1 = ICUNumberSkeletonIntegerFormatStyle<Int>(skeleton: "group-off", locale: usLocale)
        let style2 = ICUNumberSkeletonIntegerFormatStyle<Int>(skeleton: "group-off", locale: usLocale)
        
        #expect(style1 == style2)
    }
    
    @Test("ICUNumberSkeletonIntegerFormatStyle inequality")
    func integerFormatStyleInequality() {
        let style1 = ICUNumberSkeletonIntegerFormatStyle<Int>(skeleton: "group-off", locale: usLocale)
        let style2 = ICUNumberSkeletonIntegerFormatStyle<Int>(skeleton: "group-auto", locale: usLocale)
        
        #expect(style1 != style2)
    }
    
    @Test("ICUNumberSkeletonDecimalFormatStyle equality")
    func decimalFormatStyleEquality() {
        let style1 = ICUNumberSkeletonDecimalFormatStyle(skeleton: ".00", locale: usLocale)
        let style2 = ICUNumberSkeletonDecimalFormatStyle(skeleton: ".00", locale: usLocale)
        
        #expect(style1 == style2)
    }
    
    @Test("ICUNumberSkeletonDecimalFormatStyle inequality")
    func decimalFormatStyleInequality() {
        let style1 = ICUNumberSkeletonDecimalFormatStyle(skeleton: ".00", locale: usLocale)
        let style2 = ICUNumberSkeletonDecimalFormatStyle(skeleton: ".0#", locale: usLocale)
        
        #expect(style1 != style2)
    }
}

@Suite("FormatStyle Protocol Usage Tests")
struct FormatStyleProtocolUsageTests {
    
    let usLocale = Locale(identifier: "en_US")
    
    @Test("Use format style in generic function")
    func genericFormatStyleFunction() {
        func formatValue<F: FormatStyle>(_ value: F.FormatInput, with style: F) -> F.FormatOutput {
            return style.format(value)
        }
        
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".00", locale: usLocale)
        let result = formatValue(1234.5, with: style)
        
        #expect(result == "1,234.50")
    }
    
    @Test("Store format styles in array")
    func formatStyleArray() {
        let styles: [any FormatStyle<Double, String>] = [
            ICUNumberSkeletonFormatStyle<Double>(skeleton: ".00", locale: usLocale),
            ICUNumberSkeletonFormatStyle<Double>(skeleton: ".0#", locale: usLocale),
            ICUNumberSkeletonFormatStyle<Double>(skeleton: "scientific", locale: usLocale)
        ]
        
        #expect(styles.count == 3)
        
        for style in styles {
            let result = style.format(1234.5)
            #expect(!result.isEmpty)
        }
    }
    
    @Test("Type-erase format style")
    func typeErasedFormatStyle() {
        let style: any FormatStyle<Double, String> = ICUNumberSkeletonFormatStyle<Double>(
            skeleton: "currency/USD",
            locale: usLocale
        )
        
        let result = style.format(1234.56)
        #expect(!result.isEmpty)
    }
    
    @Test("Use Integer format style with protocol")
    func integerFormatStyleProtocol() {
        func formatInteger<F: FormatStyle>(_ value: F.FormatInput, with style: F) -> F.FormatOutput 
            where F.FormatInput == Int, F.FormatOutput == String {
            return style.format(value)
        }
        
        let style = ICUNumberSkeletonIntegerFormatStyle<Int>(skeleton: "group-off", locale: usLocale)
        let result = formatInteger(1234567, with: style)
        
        #expect(result == "1234567")
    }
    
    @Test("Use Decimal format style with protocol")
    func decimalFormatStyleProtocol() {
        func formatDecimal<F: FormatStyle>(_ value: F.FormatInput, with style: F) -> F.FormatOutput 
            where F.FormatInput == Decimal, F.FormatOutput == String {
            return style.format(value)
        }
        
        let style = ICUNumberSkeletonDecimalFormatStyle(skeleton: ".00", locale: usLocale)
        let decimal = Decimal(string: "1234.5")!
        let result = formatDecimal(decimal, with: style)
        
        #expect(result == "1,234.50")
    }
}

@Suite("Format Style Sendable Conformance Tests")
struct FormatStyleSendableTests {
    
    let usLocale = Locale(identifier: "en_US")
    
    @Test("ICUNumberSkeletonFormatStyle is Sendable")
    func formatStyleSendable() async {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".00", locale: usLocale)
        
        // Use the style in an async context
        let result = await Task.detached {
            return style.format(1234.5)
        }.value
        
        #expect(result == "1,234.50")
    }
    
    @Test("ICUNumberSkeletonIntegerFormatStyle is Sendable")
    func integerFormatStyleSendable() async {
        let style = ICUNumberSkeletonIntegerFormatStyle<Int>(skeleton: "group-off", locale: usLocale)
        
        let result = await Task.detached {
            return style.format(1234567)
        }.value
        
        #expect(result == "1234567")
    }
    
    @Test("ICUNumberSkeletonDecimalFormatStyle is Sendable")
    func decimalFormatStyleSendable() async {
        let style = ICUNumberSkeletonDecimalFormatStyle(skeleton: ".00", locale: usLocale)
        let decimal = Decimal(string: "1234.5")!
        
        let result = await Task.detached {
            return style.format(decimal)
        }.value
        
        #expect(result == "1,234.50")
    }
    
    @Test("Multiple format styles can be used concurrently")
    func concurrentFormatting() async {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".00", locale: usLocale)
        
        async let result1 = Task.detached { style.format(100.5) }.value
        async let result2 = Task.detached { style.format(200.75) }.value
        async let result3 = Task.detached { style.format(300.25) }.value
        
        let results = await [result1, result2, result3]
        
        #expect(results == ["100.50", "200.75", "300.25"])
    }
}

@Suite("Format Style Edge Cases Tests")
struct FormatStyleEdgeCaseTests {
    
    let usLocale = Locale(identifier: "en_US")
    
    @Test("Format with invalid skeleton falls back gracefully")
    func invalidSkeletonFallback() {
        // The initializer doesn't throw, so invalid skeletons should result in default formatting
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "invalid-token-xyz", locale: usLocale)
        let result = style.format(1234.5)
        
        // Should still produce some output (fallback to default formatting)
        #expect(!result.isEmpty)
    }
    
    @Test("Format with empty skeleton")
    func emptySkeletonFormatting() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "", locale: usLocale)
        let result = style.format(1234.5)
        
        #expect(!result.isEmpty)
    }
    
    @Test("Format very large numbers")
    func formatVeryLargeNumbers() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".00", locale: usLocale)
        let result = style.format(1234567890123456.0)
        
        #expect(!result.isEmpty)
        #expect(result.contains(",") || result.count > 10)
    }
    
    @Test("Format very small numbers")
    func formatVerySmallNumbers() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".######", locale: usLocale)
        let result = style.format(0.000001)
        
        #expect(!result.isEmpty)
    }
    
    @Test("Format zero with various styles")
    func formatZeroVariousStyles() {
        let styles = [
            ICUNumberSkeletonFormatStyle<Double>(skeleton: ".00", locale: usLocale),
            ICUNumberSkeletonFormatStyle<Double>(skeleton: "scientific", locale: usLocale),
            ICUNumberSkeletonFormatStyle<Double>(skeleton: "percent", locale: usLocale),
            ICUNumberSkeletonFormatStyle<Double>(skeleton: "currency/USD", locale: usLocale)
        ]
        
        for style in styles {
            let result = style.format(0.0)
            #expect(!result.isEmpty)
        }
    }
    
    @Test("Format negative zero")
    func formatNegativeZero() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".00 sign-always", locale: usLocale)
        let result = style.format(-0.0)
        
        #expect(!result.isEmpty)
        // Negative zero should be treated as zero
    }
    
    @Test("Format infinity")
    func formatInfinity() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".00", locale: usLocale)
        let positiveInfinity = style.format(Double.infinity)
        let negativeInfinity = style.format(-Double.infinity)
        
        #expect(!positiveInfinity.isEmpty)
        #expect(!negativeInfinity.isEmpty)
    }
    
    @Test("Format NaN")
    func formatNaN() {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".00", locale: usLocale)
        let result = style.format(Double.nan)
        
        #expect(!result.isEmpty)
    }
    
    @Test("Format with multiple BinaryFloatingPoint types")
    func formatDifferentFloatingPointTypes() {
        let skeleton = ".00"
        
        let doubleStyle = ICUNumberSkeletonFormatStyle<Double>(skeleton: skeleton, locale: usLocale)
        let floatStyle = ICUNumberSkeletonFormatStyle<Float>(skeleton: skeleton, locale: usLocale)
        
        let doubleResult = doubleStyle.format(123.456)
        let floatResult = floatStyle.format(Float(123.456))
        
        #expect(doubleResult == "123.46")
        #expect(floatResult == "123.46")
    }
    
    @Test("Format with multiple BinaryInteger types")
    func formatDifferentIntegerTypes() {
        let skeleton = "group-off"
        
        let intStyle = ICUNumberSkeletonIntegerFormatStyle<Int>(skeleton: skeleton, locale: usLocale)
        let int64Style = ICUNumberSkeletonIntegerFormatStyle<Int64>(skeleton: skeleton, locale: usLocale)
        let int32Style = ICUNumberSkeletonIntegerFormatStyle<Int32>(skeleton: skeleton, locale: usLocale)
        
        #expect(intStyle.format(12345) == "12345")
        #expect(int64Style.format(12345) == "12345")
        #expect(int32Style.format(12345) == "12345")
    }
}
