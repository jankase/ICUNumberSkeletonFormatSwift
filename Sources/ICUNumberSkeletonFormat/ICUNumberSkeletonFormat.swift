import Foundation

// MARK: - ICUNumberSkeletonFormatStyle

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
/// - `percent`: Add percent symbol (does NOT multiply by 100; use `scale/100` for that)
/// - `permille`: Add permille symbol (‰) (does NOT multiply by 1000; use `scale/1000` for that)
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

    // MARK: - Initialization

    /// Creates a new format style with the given skeleton string.
    ///
    /// The skeleton string is parsed according to ICU Number Skeleton specification.
    /// Tokens are separated by spaces and can be combined to create complex formatting rules.
    ///
    /// ## Example
    /// ```swift
    /// // Currency with precision
    /// let style = ICUNumberSkeletonFormatStyle<Double>(
    ///     skeleton: "currency/USD .00"
    /// )
    /// style.format(1234.56) // "$1,234.56"
    ///
    /// // Multiple options combined
    /// let complex = ICUNumberSkeletonFormatStyle<Double>(
    ///     skeleton: "currency/EUR .00 sign-accounting",
    ///     locale: Locale(identifier: "de_DE")
    /// )
    /// complex.format(-100) // "(100,00 €)"
    /// ```
    ///
    /// - Parameters:
    ///   - skeleton: The ICU number skeleton string. Tokens are space-separated per ICU specification.
    ///   - locale: The locale to use for formatting. Defaults to the current locale.
    ///
    /// - Note: If the skeleton is invalid, formatting will fall back to default number formatting
    ///         without throwing an error. Use `SkeletonParser` directly if you need error handling.
    public init(skeleton: String, locale: Locale = .current) {
        self.skeleton = skeleton
        self.locale = locale
        let parser = SkeletonParser()
        self.options = (try? parser.parse(skeleton)) ?? SkeletonOptions()
    }

    /// Creates a new format style with pre-parsed skeleton options.
    ///
    /// Use this initializer when you've already parsed a skeleton string or want to
    /// programmatically construct formatting options without using skeleton syntax.
    ///
    /// ## Example
    /// ```swift
    /// var options = SkeletonOptions()
    /// options.unit = .currency(code: "USD")
    /// options.precision = .fractionDigits(min: 2, max: 2)
    /// options.signDisplay = .accounting
    ///
    /// let style = ICUNumberSkeletonFormatStyle<Double>(options: options)
    /// style.format(-100) // "($100.00)"
    /// ```
    ///
    /// - Parameters:
    ///   - options: The skeleton options to use for formatting.
    ///   - locale: The locale to use for formatting. Defaults to the current locale.
    public init(options: SkeletonOptions, locale: Locale = .current) {
        self.options = options
        self.locale = locale
        self.skeleton = ""
    }

    // MARK: - Formatting

    /// Formats the given value according to the skeleton options.
    ///
    /// This method applies all formatting rules specified in the skeleton, including:
    /// - Notation (scientific, compact, etc.)
    /// - Units (currency, percent, measure units)
    /// - Precision (fraction digits, significant digits)
    /// - Rounding modes
    /// - Sign display
    /// - Grouping separators
    /// - And all other skeleton options
    ///
    /// Special floating-point values are handled as follows:
    /// - `NaN` → "NaN"
    /// - `+Infinity` → "∞"
    /// - `-Infinity` → "-∞"
    ///
    /// ## Example
    /// ```swift
    /// let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "currency/USD .00")
    /// style.format(1234.56) // "$1,234.56"
    /// style.format(.infinity) // "∞"
    /// style.format(.nan) // "NaN"
    /// ```
    ///
    /// - Parameter value: The numeric value to format.
    /// - Returns: A formatted string representation of the value.
    public func format(_ value: Value) -> String {
        let doubleValue = Double(value)

        // Handle special floating-point values
        if doubleValue.isNaN {
            return "NaN"
        }
        if doubleValue.isInfinite {
            return doubleValue > 0 ? "∞" : "-∞"
        }

        // Apply scale if specified
        let scaledValue: Double
        if let scale = options.scale {
            scaledValue = doubleValue * NSDecimalNumber(decimal: scale).doubleValue
        } else {
            scaledValue = doubleValue
        }

        // Use the appropriate formatter strategy
        let formatter = FormatterFactory.shared.formatter(for: options)
        return formatter.format(scaledValue, options: options, locale: locale)
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

// MARK: - ICUNumberSkeletonIntegerFormatStyle

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

    // MARK: - Initialization

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

    // MARK: - Formatting

    public func format(_ value: Value) -> String {
        doubleStyle.format(Double(value))
    }
}

// MARK: - ICUNumberSkeletonDecimalFormatStyle

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

    // MARK: - Initialization

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

    // MARK: - Formatting

    public func format(_ value: Decimal) -> String {
        doubleStyle.format(NSDecimalNumber(decimal: value).doubleValue)
    }
}
