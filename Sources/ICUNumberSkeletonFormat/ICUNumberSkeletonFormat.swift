import Foundation

/// A number formatter that uses ICU number skeleton strings for configuration.
///
/// ICU Number Skeleton is a compact, locale-independent syntax for specifying number
/// formatting options. This formatter parses skeleton strings and applies them to
/// format numbers appropriately.
///
/// ## Example Usage
///
/// ```swift
/// let formatter = try ICUNumberSkeletonFormat(skeleton: "currency/USD .00")
/// let formatted = formatter.format(1234.5) // "$1,234.50"
///
/// // With custom locale
/// let euroFormatter = try ICUNumberSkeletonFormat(
///     skeleton: "currency/EUR .00",
///     locale: Locale(identifier: "de_DE")
/// )
/// let euroFormatted = euroFormatter.format(1234.5) // "1.234,50 €"
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
/// - `@@##`: 2-4 significant digits
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
public struct ICUNumberSkeletonFormat: Sendable {

    // MARK: - Properties

    /// The parsed skeleton options.
    public let options: SkeletonOptions

    /// The locale used for formatting.
    public let locale: Locale

    /// The underlying number formatter.
    private let numberFormatter: NumberFormatter

    // MARK: - Initialization

    /// Creates a new formatter with the given skeleton string.
    ///
    /// - Parameters:
    ///   - skeleton: The ICU number skeleton string.
    ///   - locale: The locale to use for formatting. Defaults to the current locale.
    /// - Throws: `SkeletonParseError` if the skeleton string is invalid.
    public init(skeleton: String, locale: Locale = .current) throws {
        let parser = SkeletonParser()
        self.options = try parser.parse(skeleton)
        self.locale = locale

        let builder = NumberFormatterBuilder()
        self.numberFormatter = builder.build(from: options, locale: locale)
    }

    /// Creates a new formatter with pre-parsed skeleton options.
    ///
    /// - Parameters:
    ///   - options: The skeleton options to use.
    ///   - locale: The locale to use for formatting. Defaults to the current locale.
    public init(options: SkeletonOptions, locale: Locale = .current) {
        self.options = options
        self.locale = locale

        let builder = NumberFormatterBuilder()
        self.numberFormatter = builder.build(from: options, locale: locale)
    }

    // MARK: - Formatting

    /// Formats a number using the configured skeleton options.
    ///
    /// - Parameter number: The number to format.
    /// - Returns: The formatted string, or `nil` if formatting fails.
    public func format<T: BinaryInteger>(_ number: T) -> String? {
        numberFormatter.string(from: NSNumber(value: Int64(number)))
    }

    /// Formats a number using the configured skeleton options.
    ///
    /// - Parameter number: The number to format.
    /// - Returns: The formatted string, or `nil` if formatting fails.
    public func format<T: BinaryFloatingPoint>(_ number: T) -> String? {
        numberFormatter.string(from: NSNumber(value: Double(number)))
    }

    /// Formats a Decimal using the configured skeleton options.
    ///
    /// - Parameter number: The Decimal to format.
    /// - Returns: The formatted string, or `nil` if formatting fails.
    public func format(_ number: Decimal) -> String? {
        numberFormatter.string(from: number as NSDecimalNumber)
    }

    /// Formats an NSNumber using the configured skeleton options.
    ///
    /// - Parameter number: The NSNumber to format.
    /// - Returns: The formatted string, or `nil` if formatting fails.
    public func format(_ number: NSNumber) -> String? {
        numberFormatter.string(from: number)
    }
}

// MARK: - Convenience Extensions

public extension ICUNumberSkeletonFormat {

    /// Creates a currency formatter.
    ///
    /// - Parameters:
    ///   - currencyCode: The ISO 4217 currency code (e.g., "USD", "EUR").
    ///   - locale: The locale to use for formatting.
    /// - Returns: A formatter configured for currency formatting.
    static func currency(_ currencyCode: String, locale: Locale = .current) throws -> ICUNumberSkeletonFormat {
        try ICUNumberSkeletonFormat(skeleton: "currency/\(currencyCode)", locale: locale)
    }

    /// Creates a percent formatter.
    ///
    /// - Parameter locale: The locale to use for formatting.
    /// - Returns: A formatter configured for percent formatting.
    static func percent(locale: Locale = .current) throws -> ICUNumberSkeletonFormat {
        try ICUNumberSkeletonFormat(skeleton: "percent", locale: locale)
    }

    /// Creates a scientific notation formatter.
    ///
    /// - Parameter locale: The locale to use for formatting.
    /// - Returns: A formatter configured for scientific notation.
    static func scientific(locale: Locale = .current) throws -> ICUNumberSkeletonFormat {
        try ICUNumberSkeletonFormat(skeleton: "scientific", locale: locale)
    }

    /// Creates a compact notation formatter.
    ///
    /// - Parameters:
    ///   - style: The compact style (`.short` or `.long`).
    ///   - locale: The locale to use for formatting.
    /// - Returns: A formatter configured for compact notation.
    static func compact(_ style: CompactStyle, locale: Locale = .current) throws -> ICUNumberSkeletonFormat {
        let skeleton = style == .short ? "compact-short" : "compact-long"
        return try ICUNumberSkeletonFormat(skeleton: skeleton, locale: locale)
    }

    /// Compact notation style.
    enum CompactStyle: Sendable {
        case short
        case long
    }
}

// MARK: - FormatStyle Support (iOS 15+, macOS 12+)

/// A FormatStyle that uses ICU number skeleton for formatting.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct ICUNumberSkeletonFormatStyle<Value: BinaryFloatingPoint>: FormatStyle, Sendable {

    public typealias FormatInput = Value
    public typealias FormatOutput = String

    private let skeleton: String
    private let locale: Locale

    /// Creates a new format style with the given skeleton string.
    ///
    /// - Parameters:
    ///   - skeleton: The ICU number skeleton string.
    ///   - locale: The locale to use for formatting.
    public init(skeleton: String, locale: Locale = .current) {
        self.skeleton = skeleton
        self.locale = locale
    }

    public func format(_ value: Value) -> String {
        do {
            let formatter = try ICUNumberSkeletonFormat(skeleton: skeleton, locale: locale)
            return formatter.format(value) ?? String(describing: value)
        } catch {
            return String(describing: value)
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
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
