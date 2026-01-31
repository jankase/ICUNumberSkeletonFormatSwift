import Foundation

/// A FormatStyle that uses ICU number skeleton strings for configuration.
///
/// ICU Number Skeleton is a compact, locale-independent syntax for specifying number
/// formatting options. This format style parses skeleton strings and applies them to
/// format numbers appropriately.
///
/// ## Example Usage
///
/// ```swift
/// // Using the format style directly
/// let formatted = 1234.5.formatted(.icuSkeleton("currency/USD .00"))
///
/// // Creating a reusable format style
/// let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "currency/USD .00")
/// let result = style.format(1234.5) // "$1,234.50"
///
/// // With custom locale
/// let euroStyle = ICUNumberSkeletonFormatStyle<Double>(
///     skeleton: "currency/EUR .00",
///     locale: Locale(identifier: "de_DE")
/// )
/// let euroFormatted = euroStyle.format(1234.5) // "1.234,50 €"
/// ```
///
/// ## Supported Skeleton Tokens
///
/// ### Notation
/// - `notation-simple` or `simple`: Standard decimal notation
/// - `scientific`: Scientific notation (e.g., 1.23E4)
/// - `engineering`: Engineering notation (exponents are multiples of 3)
/// - `compact-short`: Compact notation with short form (e.g., 1K, 1M)
/// - `compact-long`: Compact notation with long form (e.g., 1 thousand)
///
/// ### Units
/// - `percent`: Format as percentage
/// - `permille`: Format as permille (‰)
/// - `currency/XXX`: Format as currency with ISO code (e.g., `currency/USD`)
/// - `measure-unit/type-subtype`: Format with measure unit (e.g., `measure-unit/length-meter`)
///
/// ### Unit Width
/// - `unit-width-narrow`: Narrowest representation
/// - `unit-width-short`: Short representation
/// - `unit-width-full-name`: Full name (e.g., "US dollars")
/// - `unit-width-iso-code`: ISO code (e.g., "USD")
/// - `unit-width-hidden`: Hide the unit
///
/// ### Precision
/// - `.00`: Exactly 2 fraction digits
/// - `.0#`: 1-2 fraction digits
/// - `.##`: 0-2 fraction digits
/// - `@@@`: 3 significant digits
/// - `@@#`: 2-3 significant digits
/// - `precision-integer`: No fraction digits
/// - `precision-unlimited`: Maximum precision
/// - `precision-currency-standard`: Standard currency precision
/// - `precision-increment/0.05`: Round to increment
///
/// ### Rounding Mode
/// - `rounding-mode-ceiling`: Round toward positive infinity
/// - `rounding-mode-floor`: Round toward negative infinity
/// - `rounding-mode-down`: Round toward zero
/// - `rounding-mode-up`: Round away from zero
/// - `rounding-mode-half-even`: Round to nearest, ties to even (banker's rounding)
/// - `rounding-mode-half-down`: Round to nearest, ties toward zero
/// - `rounding-mode-half-up`: Round to nearest, ties away from zero
///
/// ### Integer Width
/// - `integer-width/+000`: Minimum 3 integer digits, truncate if necessary
/// - `integer-width/##00`: Minimum 2 integer digits, maximum 4
///
/// ### Scale
/// - `scale/100`: Multiply by 100 before formatting
///
/// ### Grouping
/// - `group-auto`: Locale-dependent grouping
/// - `group-off`: No grouping separators
/// - `group-min2`: Only group if 2+ digits in group
/// - `group-on-aligned`: Grouping for alignment
///
/// ### Sign Display
/// - `sign-auto`: Show minus sign for negative only
/// - `sign-always`: Always show sign
/// - `sign-never`: Never show sign
/// - `sign-accounting`: Use accounting format for negatives
/// - `sign-accounting-always`: Accounting format, always show sign
/// - `sign-except-zero`: Show sign except for zero
///
/// ### Decimal Separator
/// - `decimal-auto`: Show decimal separator only if needed
/// - `decimal-always`: Always show decimal separator
///
/// ### Numbering System
/// - `numbering-system/latn`: Use Latin digits
/// - `numbering-system/arab`: Use Arabic-Indic digits
/// - `latin`: Shorthand for Latin digits
///
public struct ICUNumberSkeletonFormatStyle<Value: BinaryFloatingPoint>: FormatStyle, Sendable {

    public typealias FormatInput = Value
    public typealias FormatOutput = String

    /// The parsed skeleton options.
    public let options: SkeletonOptions

    /// The locale used for formatting.
    public let locale: Locale

    private let skeleton: String
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case options
        case locale
        case skeleton
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.options = try container.decode(SkeletonOptions.self, forKey: .options)
        self.locale = try container.decode(Locale.self, forKey: .locale)
        self.skeleton = try container.decode(String.self, forKey: .skeleton)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(options, forKey: .options)
        try container.encode(locale, forKey: .locale)
        try container.encode(skeleton, forKey: .skeleton)
    }
    
    // MARK: - Hashable
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(options)
        hasher.combine(locale)
        hasher.combine(skeleton)
    }
    
    public static func == (lhs: ICUNumberSkeletonFormatStyle, rhs: ICUNumberSkeletonFormatStyle) -> Bool {
        lhs.options == rhs.options && lhs.locale == rhs.locale && lhs.skeleton == rhs.skeleton
    }

    /// Creates a new format style with the given skeleton string.
    ///
    /// - Parameters:
    ///   - skeleton: The ICU number skeleton string.
    ///   - locale: The locale to use for formatting. Defaults to the current locale.
    /// - Note: If the skeleton is invalid, formatting will fall back to default number formatting.
    public init(skeleton: String, locale: Locale = .current) {
        self.skeleton = skeleton
        self.locale = locale
        let parser = SkeletonParser()
        self.options = (try? parser.parse(skeleton)) ?? SkeletonOptions()
    }

    /// Creates a new format style with pre-parsed skeleton options.
    ///
    /// - Parameters:
    ///   - options: The skeleton options to use.
    ///   - locale: The locale to use for formatting. Defaults to the current locale.
    public init(options: SkeletonOptions, locale: Locale = .current) {
        self.options = options
        self.locale = locale
        self.skeleton = ""
    }

    public func format(_ value: Value) -> String {
        let doubleValue = Double(value)

        // Apply scale if specified
        let scaledValue: Double
        if let scale = options.scale {
            scaledValue = doubleValue * NSDecimalNumber(decimal: scale).doubleValue
        } else {
            scaledValue = doubleValue
        }

        // Build and apply the appropriate format style
        return formatValue(scaledValue)
    }

    private func formatValue(_ value: Double) -> String {
        // Handle currency formatting
        if case .currency(let code) = options.unit {
            return formatCurrency(value, code: code)
        }

        // Handle percent formatting
        if case .percent = options.unit {
            return formatPercent(value)
        }

        // Handle decimal/other formatting
        return formatDecimal(value)
    }

    private func formatCurrency(_ value: Double, code: String) -> String {
        var format = Decimal.FormatStyle.Currency(code: code, locale: locale)

        // Apply precision
        format = applyCurrencyPrecision(to: format)

        // Apply grouping
        format = applyCurrencyGrouping(to: format)

        // Apply sign display
        format = applyCurrencySign(to: format)

        // Apply decimal separator
        format = applyCurrencyDecimalSeparator(to: format)

        // Apply rounding
        format = applyCurrencyRounding(to: format)

        return Decimal(value).formatted(format)
    }

    private func formatPercent(_ value: Double) -> String {
        var format = Decimal.FormatStyle.Percent(locale: locale)

        // Apply precision
        format = applyPercentPrecision(to: format)

        // Apply grouping
        format = applyPercentGrouping(to: format)

        // Apply sign display
        format = applyPercentSign(to: format)

        // Apply rounding
        format = applyPercentRounding(to: format)

        return Decimal(value).formatted(format)
    }

    private func formatDecimal(_ value: Double) -> String {
        var format = Decimal.FormatStyle(locale: locale)

        // Apply notation
        format = applyNotation(to: format)

        // Apply precision
        format = applyDecimalPrecision(to: format)

        // Apply grouping
        format = applyDecimalGrouping(to: format)

        // Apply sign display
        format = applyDecimalSign(to: format)

        // Apply decimal separator
        format = applyDecimalDecimalSeparator(to: format)

        // Apply rounding
        format = applyDecimalRounding(to: format)

        return Decimal(value).formatted(format)
    }

    // MARK: - Decimal Format Modifiers

    private func applyNotation(to format: Decimal.FormatStyle) -> Decimal.FormatStyle {
        guard let notation = options.notation else { return format }

        switch notation {
        case .simple:
            return format.notation(.automatic)
        case .scientific:
            return format.notation(.scientific)
        case .compactShort:
            return format.notation(.compactName)
        case .compactLong:
            return format.notation(.compactName)
        case .engineering:
            return format.notation(.scientific)
        }
    }

    private func applyDecimalPrecision(to format: Decimal.FormatStyle) -> Decimal.FormatStyle {
        guard let precision = options.precision else { return format }

        switch precision {
        case .integer:
            return format.precision(.fractionLength(0))
        case .fractionDigits(let min, let max):
            return format.precision(.fractionLength(min...max))
        case .significantDigits(let min, let max):
            return format.precision(.significantDigits(min...max))
        case .fractionSignificant(let minFrac, let maxFrac, _, _):
            return format.precision(.fractionLength(minFrac...maxFrac))
        case .currencyStandard, .currencyCash:
            return format
        case .increment(let value):
            let intValue = NSDecimalNumber(decimal: value).intValue
            if intValue > 0 {
                return format.precision(.fractionLength(0))
            }
            return format
        case .unlimited:
            return format.precision(.fractionLength(0...15))
        }
    }

    private func applyDecimalGrouping(to format: Decimal.FormatStyle) -> Decimal.FormatStyle {
        guard let grouping = options.grouping else { return format }

        switch grouping {
        case .auto:
            return format.grouping(.automatic)
        case .off:
            return format.grouping(.never)
        case .min2, .onAligned:
            return format.grouping(.automatic)
        }
    }

    private func applyDecimalSign(to format: Decimal.FormatStyle) -> Decimal.FormatStyle {
        guard let signDisplay = options.signDisplay else { return format }

        switch signDisplay {
        case .auto:
            return format.sign(strategy: .automatic)
        case .always, .accountingAlways:
            return format.sign(strategy: .always())
        case .never:
            return format.sign(strategy: .never)
        case .exceptZero, .accountingExceptZero:
            return format.sign(strategy: .always())
        case .accounting:
            return format.sign(strategy: .automatic)
        case .negative:
            return format.sign(strategy: .automatic)
        }
    }

    private func applyDecimalDecimalSeparator(to format: Decimal.FormatStyle) -> Decimal.FormatStyle {
        guard let separator = options.decimalSeparator else { return format }

        switch separator {
        case .auto:
            return format.decimalSeparator(strategy: .automatic)
        case .always:
            return format.decimalSeparator(strategy: .always)
        }
    }

    private func applyDecimalRounding(to format: Decimal.FormatStyle) -> Decimal.FormatStyle {
        guard let roundingMode = options.roundingMode else { return format }

        let rule: FloatingPointRoundingRule = switch roundingMode {
        case .ceiling: .up
        case .floor: .down
        case .down: .towardZero
        case .up: .awayFromZero
        case .halfEven: .toNearestOrEven
        case .halfDown: .toNearestOrEven
        case .halfUp: .toNearestOrAwayFromZero
        case .unnecessary: .toNearestOrEven
        }

        return format.rounded(rule: rule)
    }

    // MARK: - Currency Format Modifiers

    private func applyCurrencyPrecision(to format: Decimal.FormatStyle.Currency) -> Decimal.FormatStyle.Currency {
        guard let precision = options.precision else { return format }

        switch precision {
        case .integer:
            return format.precision(.fractionLength(0))
        case .fractionDigits(let min, let max):
            return format.precision(.fractionLength(min...max))
        case .significantDigits(let min, let max):
            return format.precision(.significantDigits(min...max))
        case .fractionSignificant(let minFrac, let maxFrac, _, _):
            return format.precision(.fractionLength(minFrac...maxFrac))
        case .currencyStandard, .currencyCash:
            return format
        case .increment:
            return format
        case .unlimited:
            return format.precision(.fractionLength(0...15))
        }
    }

    private func applyCurrencyGrouping(to format: Decimal.FormatStyle.Currency) -> Decimal.FormatStyle.Currency {
        guard let grouping = options.grouping else { return format }

        switch grouping {
        case .auto:
            return format.grouping(.automatic)
        case .off:
            return format.grouping(.never)
        case .min2, .onAligned:
            return format.grouping(.automatic)
        }
    }

    private func applyCurrencySign(to format: Decimal.FormatStyle.Currency) -> Decimal.FormatStyle.Currency {
        guard let signDisplay = options.signDisplay else { return format }

        switch signDisplay {
        case .auto:
            return format.sign(strategy: .automatic)
        case .always:
            return format.sign(strategy: .always())
        case .never:
            return format.sign(strategy: .never)
        case .accounting:
            return format.sign(strategy: .accounting)
        case .accountingAlways:
            return format.sign(strategy: .accountingAlways())
        case .exceptZero:
            return format.sign(strategy: .always())
        case .accountingExceptZero:
            return format.sign(strategy: .accountingAlways())
        case .negative:
            return format.sign(strategy: .automatic)
        }
    }

    private func applyCurrencyDecimalSeparator(to format: Decimal.FormatStyle.Currency) -> Decimal.FormatStyle.Currency {
        guard let separator = options.decimalSeparator else { return format }

        switch separator {
        case .auto:
            return format.decimalSeparator(strategy: .automatic)
        case .always:
            return format.decimalSeparator(strategy: .always)
        }
    }

    private func applyCurrencyRounding(to format: Decimal.FormatStyle.Currency) -> Decimal.FormatStyle.Currency {
        guard let roundingMode = options.roundingMode else { return format }

        let rule: FloatingPointRoundingRule = switch roundingMode {
        case .ceiling: .up
        case .floor: .down
        case .down: .towardZero
        case .up: .awayFromZero
        case .halfEven: .toNearestOrEven
        case .halfDown: .toNearestOrEven
        case .halfUp: .toNearestOrAwayFromZero
        case .unnecessary: .toNearestOrEven
        }

        return format.rounded(rule: rule)
    }

    // MARK: - Percent Format Modifiers

    private func applyPercentPrecision(to format: Decimal.FormatStyle.Percent) -> Decimal.FormatStyle.Percent {
        guard let precision = options.precision else { return format }

        switch precision {
        case .integer:
            return format.precision(.fractionLength(0))
        case .fractionDigits(let min, let max):
            return format.precision(.fractionLength(min...max))
        case .significantDigits(let min, let max):
            return format.precision(.significantDigits(min...max))
        case .fractionSignificant(let minFrac, let maxFrac, _, _):
            return format.precision(.fractionLength(minFrac...maxFrac))
        case .currencyStandard, .currencyCash, .increment:
            return format
        case .unlimited:
            return format.precision(.fractionLength(0...15))
        }
    }

    private func applyPercentGrouping(to format: Decimal.FormatStyle.Percent) -> Decimal.FormatStyle.Percent {
        guard let grouping = options.grouping else { return format }

        switch grouping {
        case .auto:
            return format.grouping(.automatic)
        case .off:
            return format.grouping(.never)
        case .min2, .onAligned:
            return format.grouping(.automatic)
        }
    }

    private func applyPercentSign(to format: Decimal.FormatStyle.Percent) -> Decimal.FormatStyle.Percent {
        guard let signDisplay = options.signDisplay else { return format }

        switch signDisplay {
        case .auto:
            return format.sign(strategy: .automatic)
        case .always, .accountingAlways:
            return format.sign(strategy: .always())
        case .never:
            return format.sign(strategy: .never)
        case .exceptZero, .accountingExceptZero:
            return format.sign(strategy: .always())
        case .accounting, .negative:
            return format.sign(strategy: .automatic)
        }
    }

    private func applyPercentRounding(to format: Decimal.FormatStyle.Percent) -> Decimal.FormatStyle.Percent {
        guard let roundingMode = options.roundingMode else { return format }

        let rule: FloatingPointRoundingRule = switch roundingMode {
        case .ceiling: .up
        case .floor: .down
        case .down: .towardZero
        case .up: .awayFromZero
        case .halfEven: .toNearestOrEven
        case .halfDown: .toNearestOrEven
        case .halfUp: .toNearestOrAwayFromZero
        case .unnecessary: .toNearestOrEven
        }

        return format.rounded(rule: rule)
    }
}

// MARK: - FormatStyle Extensions

public extension FormatStyle where Self == ICUNumberSkeletonFormatStyle<Double> {
    /// Creates a format style using an ICU number skeleton.
    ///
    /// - Parameters:
    ///   - skeleton: The ICU number skeleton string.
    ///   - locale: The locale to use for formatting.
    /// - Returns: A format style configured with the skeleton.
    static func icuSkeleton(_ skeleton: String, locale: Locale = .current) -> ICUNumberSkeletonFormatStyle<Double> {
        ICUNumberSkeletonFormatStyle(skeleton: skeleton, locale: locale)
    }
}

// MARK: - BinaryFloatingPoint Extension

public extension BinaryFloatingPoint {
    /// Formats the number using an ICU number skeleton string.
    ///
    /// - Parameters:
    ///   - skeleton: The ICU number skeleton string.
    ///   - locale: The locale to use for formatting.
    /// - Returns: The formatted string.
    func formatted(icuSkeleton skeleton: String, locale: Locale = .current) -> String {
        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: skeleton, locale: locale)
        return style.format(Double(self))
    }
}

// MARK: - Integer FormatStyle

/// A FormatStyle for formatting integers using ICU number skeleton strings.
public struct ICUNumberSkeletonIntegerFormatStyle<Value: BinaryInteger>: FormatStyle, Sendable {

    public typealias FormatInput = Value
    public typealias FormatOutput = String

    private let doubleStyle: ICUNumberSkeletonFormatStyle<Double>
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case doubleStyle
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.doubleStyle = try container.decode(ICUNumberSkeletonFormatStyle<Double>.self, forKey: .doubleStyle)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(doubleStyle, forKey: .doubleStyle)
    }
    
    // MARK: - Hashable
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(doubleStyle)
    }
    
    public static func == (lhs: ICUNumberSkeletonIntegerFormatStyle, rhs: ICUNumberSkeletonIntegerFormatStyle) -> Bool {
        lhs.doubleStyle == rhs.doubleStyle
    }

    /// Creates a new format style with the given skeleton string.
    ///
    /// - Parameters:
    ///   - skeleton: The ICU number skeleton string.
    ///   - locale: The locale to use for formatting. Defaults to the current locale.
    public init(skeleton: String, locale: Locale = .current) {
        self.doubleStyle = ICUNumberSkeletonFormatStyle(skeleton: skeleton, locale: locale)
    }

    /// Creates a new format style with pre-parsed skeleton options.
    ///
    /// - Parameters:
    ///   - options: The skeleton options to use.
    ///   - locale: The locale to use for formatting. Defaults to the current locale.
    public init(options: SkeletonOptions, locale: Locale = .current) {
        self.doubleStyle = ICUNumberSkeletonFormatStyle(options: options, locale: locale)
    }

    public func format(_ value: Value) -> String {
        doubleStyle.format(Double(value))
    }
}

public extension FormatStyle where Self == ICUNumberSkeletonIntegerFormatStyle<Int> {
    /// Creates a format style using an ICU number skeleton for integers.
    ///
    /// - Parameters:
    ///   - skeleton: The ICU number skeleton string.
    ///   - locale: The locale to use for formatting.
    /// - Returns: A format style configured with the skeleton.
    static func icuSkeleton(_ skeleton: String, locale: Locale = .current) -> ICUNumberSkeletonIntegerFormatStyle<Int> {
        ICUNumberSkeletonIntegerFormatStyle(skeleton: skeleton, locale: locale)
    }
}

// MARK: - BinaryInteger Extension

public extension BinaryInteger {
    /// Formats the integer using an ICU number skeleton string.
    ///
    /// - Parameters:
    ///   - skeleton: The ICU number skeleton string.
    ///   - locale: The locale to use for formatting.
    /// - Returns: The formatted string.
    func formatted(icuSkeleton skeleton: String, locale: Locale = .current) -> String {
        let style = ICUNumberSkeletonIntegerFormatStyle<Int>(skeleton: skeleton, locale: locale)
        return style.format(Int(self))
    }
}

// MARK: - Decimal FormatStyle

/// A FormatStyle for formatting Decimal values using ICU number skeleton strings.
public struct ICUNumberSkeletonDecimalFormatStyle: FormatStyle, Sendable {

    public typealias FormatInput = Decimal
    public typealias FormatOutput = String

    private let doubleStyle: ICUNumberSkeletonFormatStyle<Double>
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case doubleStyle
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.doubleStyle = try container.decode(ICUNumberSkeletonFormatStyle<Double>.self, forKey: .doubleStyle)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(doubleStyle, forKey: .doubleStyle)
    }
    
    // MARK: - Hashable
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(doubleStyle)
    }
    
    public static func == (lhs: ICUNumberSkeletonDecimalFormatStyle, rhs: ICUNumberSkeletonDecimalFormatStyle) -> Bool {
        lhs.doubleStyle == rhs.doubleStyle
    }

    /// Creates a new format style with the given skeleton string.
    ///
    /// - Parameters:
    ///   - skeleton: The ICU number skeleton string.
    ///   - locale: The locale to use for formatting. Defaults to the current locale.
    public init(skeleton: String, locale: Locale = .current) {
        self.doubleStyle = ICUNumberSkeletonFormatStyle(skeleton: skeleton, locale: locale)
    }

    /// Creates a new format style with pre-parsed skeleton options.
    ///
    /// - Parameters:
    ///   - options: The skeleton options to use.
    ///   - locale: The locale to use for formatting. Defaults to the current locale.
    public init(options: SkeletonOptions, locale: Locale = .current) {
        self.doubleStyle = ICUNumberSkeletonFormatStyle(options: options, locale: locale)
    }

    public func format(_ value: Decimal) -> String {
        doubleStyle.format(NSDecimalNumber(decimal: value).doubleValue)
    }
}

public extension FormatStyle where Self == ICUNumberSkeletonDecimalFormatStyle {
    /// Creates a format style using an ICU number skeleton for Decimal values.
    ///
    /// - Parameters:
    ///   - skeleton: The ICU number skeleton string.
    ///   - locale: The locale to use for formatting.
    /// - Returns: A format style configured with the skeleton.
    static func icuSkeleton(_ skeleton: String, locale: Locale = .current) -> ICUNumberSkeletonDecimalFormatStyle {
        ICUNumberSkeletonDecimalFormatStyle(skeleton: skeleton, locale: locale)
    }
}

// MARK: - Decimal Extension

public extension Decimal {
    /// Formats the Decimal using an ICU number skeleton string.
    ///
    /// - Parameters:
    ///   - skeleton: The ICU number skeleton string.
    ///   - locale: The locale to use for formatting.
    /// - Returns: The formatted string.
    func formatted(icuSkeleton skeleton: String, locale: Locale = .current) -> String {
        let style = ICUNumberSkeletonDecimalFormatStyle(skeleton: skeleton, locale: locale)
        return style.format(self)
    }
}

// MARK: - Convenience Factory Methods

public extension ICUNumberSkeletonFormatStyle {

    /// Creates a currency format style.
    ///
    /// - Parameters:
    ///   - currencyCode: The ISO 4217 currency code (e.g., "USD", "EUR").
    ///   - locale: The locale to use for formatting.
    /// - Returns: A format style configured for currency formatting.
    static func currency(_ currencyCode: String, locale: Locale = .current) -> ICUNumberSkeletonFormatStyle {
        ICUNumberSkeletonFormatStyle(skeleton: "currency/\(currencyCode)", locale: locale)
    }

    /// Creates a percent format style.
    ///
    /// - Parameter locale: The locale to use for formatting.
    /// - Returns: A format style configured for percent formatting.
    static func percent(locale: Locale = .current) -> ICUNumberSkeletonFormatStyle {
        ICUNumberSkeletonFormatStyle(skeleton: "percent", locale: locale)
    }

    /// Creates a scientific notation format style.
    ///
    /// - Parameter locale: The locale to use for formatting.
    /// - Returns: A format style configured for scientific notation.
    static func scientific(locale: Locale = .current) -> ICUNumberSkeletonFormatStyle {
        ICUNumberSkeletonFormatStyle(skeleton: "scientific", locale: locale)
    }

    /// Creates a compact notation format style.
    ///
    /// - Parameters:
    ///   - style: The compact style (`.short` or `.long`).
    ///   - locale: The locale to use for formatting.
    /// - Returns: A format style configured for compact notation.
    static func compact(_ style: CompactStyle, locale: Locale = .current) -> ICUNumberSkeletonFormatStyle {
        let skeleton = style == .short ? "compact-short" : "compact-long"
        return ICUNumberSkeletonFormatStyle(skeleton: skeleton, locale: locale)
    }

    /// Compact notation style.
    enum CompactStyle: Sendable {
        case short
        case long
    }
}
