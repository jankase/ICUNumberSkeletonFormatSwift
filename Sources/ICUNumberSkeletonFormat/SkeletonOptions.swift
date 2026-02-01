import Foundation

/// Represents the parsed options from an ICU number skeleton string.
///
/// `SkeletonOptions` is a typed representation of all formatting options that can be
/// specified in an ICU Number Skeleton. It can be created by parsing a skeleton string
/// with `SkeletonParser` or constructed programmatically.
///
/// ## Example Usage
///
/// ```swift
/// // Parse from skeleton string
/// let parser = SkeletonParser()
/// let options = try parser.parse("currency/USD .00 sign-accounting")
///
/// // Create programmatically
/// var customOptions = SkeletonOptions()
/// customOptions.unit = .currency(code: "EUR")
/// customOptions.precision = .fractionDigits(min: 2, max: 2)
/// customOptions.signDisplay = .always
/// customOptions.grouping = .auto
///
/// // Use with format style
/// let style = ICUNumberSkeletonFormatStyle<Double>(options: customOptions)
/// style.format(1234.56) // "+€1,234.56" (locale dependent)
/// ```
///
/// ## Property Categories
///
/// - **Notation**: How the number is represented (simple, scientific, compact)
/// - **Unit**: Type of unit (currency, percent, measure unit)
/// - **Precision**: Decimal places or significant digits
/// - **Rounding**: How to round the number
/// - **Integer Width**: Padding or truncation of integer part
/// - **Scale**: Multiply factor applied before formatting
/// - **Grouping**: Thousands separator behavior
/// - **Sign Display**: When to show +/- signs
/// - **Decimal Separator**: When to show decimal point
/// - **Numbering System**: Which digit characters to use
public struct SkeletonOptions: Sendable, Equatable, Codable, Hashable {

    // MARK: - Notation

    /// The notation style for number formatting.
    ///
    /// Determines how the number is represented in the output.
    ///
    /// ## Cases
    /// - `simple`: Standard decimal notation (e.g., 1234.56)
    /// - `scientific`: Scientific notation (e.g., 1.23E3)
    /// - `engineering`: Engineering notation with exponents in multiples of 3
    /// - `compactShort`: Compact notation with short forms (e.g., 1K, 1.2M)
    /// - `compactLong`: Compact notation with long forms (e.g., 1 thousand, 1.2 million)
    ///
    /// ## Example
    /// ```swift
    /// var options = SkeletonOptions()
    /// options.notation = .scientific
    /// // Format: 1.234567E6
    ///
    /// options.notation = .compactShort
    /// // Format: 1.2M
    /// ```
    public enum Notation: Sendable, Equatable, Codable, Hashable {
        /// Standard decimal notation
        case simple
        /// Scientific notation (e.g., 1.23E4)
        case scientific
        /// Engineering notation (exponents are multiples of 3)
        case engineering
        /// Compact with short form (e.g., 1K, 1M)
        case compactShort
        /// Compact with long form (e.g., 1 thousand)
        case compactLong
    }

    // MARK: - Unit

    /// The unit type for number formatting.
    ///
    /// Specifies what kind of unit to append to the formatted number.
    ///
    /// ## Cases
    /// - `none`: No unit
    /// - `percent`: Percentage (%)
    /// - `permille`: Per-mille (‰)
    /// - `currency(code:)`: Currency with ISO code (e.g., USD, EUR)
    /// - `measureUnit(type:subtype:)`: Measure unit (e.g., length-meter)
    ///
    /// ## Example
    /// ```swift
    /// var options = SkeletonOptions()
    /// options.unit = .currency(code: "USD")
    /// // Format: $1,234.56
    ///
    /// options.unit = .percent
    /// // Format: 25%
    ///
    /// options.unit = .measureUnit(type: "length", subtype: "meter")
    /// // Format: 100 m
    /// ```
    public enum Unit: Sendable, Equatable, Codable, Hashable {
        /// No unit
        case none
        /// Percentage (multiplies by 100, appends %)
        case percent
        /// Permille (multiplies by 1000, appends ‰)
        case permille
        /// Currency with ISO code
        case currency(code: String)
        /// Measure unit with type and subtype
        case measureUnit(type: String, subtype: String)
    }

    /// The width for displaying units.
    ///
    /// Controls how verbose the unit representation is.
    ///
    /// ## Cases
    /// - `narrow`: Narrowest representation (e.g., $ vs USD)
    /// - `short`: Short representation (e.g., m for meters)
    /// - `fullName`: Full name (e.g., US dollars, meters)
    /// - `isoCode`: ISO code (e.g., USD)
    /// - `formal`: Formal representation (limited support)
    /// - `variant`: Variant representation (limited support)
    /// - `hidden`: Hide the unit symbol/text
    ///
    /// ## Example
    /// ```swift
    /// var options = SkeletonOptions()
    /// options.unit = .currency(code: "USD")
    /// options.unitWidth = .narrow
    /// // Format: $100
    ///
    /// options.unitWidth = .isoCode
    /// // Format: USD 100
    ///
    /// options.unitWidth = .fullName
    /// // Format: 100 US dollars
    /// ```
    public enum UnitWidth: Sendable, Equatable, Codable, Hashable {
        /// Narrowest representation
        case narrow
        /// Short representation
        case short
        /// Full name representation
        case fullName
        /// ISO code representation
        case isoCode
        /// Formal representation
        case formal
        /// Variant representation
        case variant
        /// Hide the unit
        case hidden
    }

    // MARK: - Precision

    /// Precision specification for number formatting.
    ///
    /// Controls how many decimal places or significant digits to show.
    ///
    /// ## Cases
    /// - `integer`: No decimal places
    /// - `fractionDigits(min:max:)`: Fixed fraction digits (e.g., .00 = min:2, max:2)
    /// - `significantDigits(min:max:)`: Significant digits (e.g., @@@ = min:3, max:3)
    /// - `fractionSignificant(...)`: Combined fraction and significant constraints
    /// - `currencyStandard`: Standard currency precision (2 for most currencies)
    /// - `currencyCash`: Cash rounding precision
    /// - `increment(value:)`: Round to specific increment (e.g., 0.05 for nickel rounding)
    /// - `unlimited`: Maximum available precision
    ///
    /// ## Example
    /// ```swift
    /// var options = SkeletonOptions()
    /// options.precision = .fractionDigits(min: 2, max: 2)
    /// // 1.2 → "1.20", 1.234 → "1.23"
    ///
    /// options.precision = .significantDigits(min: 3, max: 3)
    /// // 1234 → "1,230", 0.001234 → "0.00123"
    ///
    /// options.precision = .increment(value: Decimal(string: "0.05")!)
    /// // 1.23 → "1.25", 1.27 → "1.25"
    /// ```
    public enum Precision: Sendable, Equatable, Codable, Hashable {
        /// Use integer precision (no decimal places).
        case integer
        /// Fixed number of fraction digits.
        case fractionDigits(min: Int, max: Int)
        /// Significant digits precision.
        case significantDigits(min: Int, max: Int)
        /// Fraction digits with significant digit constraint.
        case fractionSignificant(minFraction: Int, maxFraction: Int, minSignificant: Int, maxSignificant: Int)
        /// Precision based on currency.
        case currencyStandard
        /// Cash rounding precision.
        case currencyCash
        /// Increment-based precision (e.g., round to 0.05).
        case increment(value: Decimal)
        /// Unlimited precision.
        case unlimited
    }

    // MARK: - Rounding Mode

    /// The rounding mode for number formatting.
    ///
    /// Determines how numbers are rounded when precision limits are applied.
    ///
    /// ## Cases
    /// - `ceiling`: Round toward positive infinity (2.1 → 3, -2.9 → -2)
    /// - `floor`: Round toward negative infinity (2.9 → 2, -2.1 → -3)
    /// - `down`: Round toward zero (truncate)
    /// - `up`: Round away from zero
    /// - `halfEven`: Round to nearest, ties to even (banker's rounding)
    /// - `halfDown`: Round to nearest, ties toward zero
    /// - `halfUp`: Round to nearest, ties away from zero
    /// - `unnecessary`: No rounding needed (error if would round)
    ///
    /// ## Example
    /// ```swift
    /// var options = SkeletonOptions()
    /// options.precision = .fractionDigits(min: 1, max: 1)
    ///
    /// options.roundingMode = .halfUp
    /// // 2.5 → "3.0", 2.4 → "2.0"
    ///
    /// options.roundingMode = .halfEven
    /// // 2.5 → "2.0", 3.5 → "4.0"
    ///
    /// options.roundingMode = .ceiling
    /// // 2.1 → "3.0", 2.9 → "3.0"
    /// ```
    public enum RoundingMode: Sendable, Equatable, Codable, Hashable {
        /// Round toward positive infinity
        case ceiling
        /// Round toward negative infinity
        case floor
        /// Round toward zero (truncate)
        case down
        /// Round away from zero
        case up
        /// Round to nearest, ties to even
        case halfEven
        /// Round to nearest, ties toward zero
        case halfDown
        /// Round to nearest, ties away from zero
        case halfUp
        /// Error if rounding would be necessary
        case unnecessary
    }

    // MARK: - Integer Width

    /// Specifies the minimum and maximum integer digits.
    ///
    /// Controls padding with zeros and/or truncation of the integer part.
    ///
    /// - `minDigits`: Minimum number of integer digits (pad with leading zeros if needed)
    /// - `maxDigits`: Maximum number of integer digits (truncate from left if needed), or `nil` for no limit
    ///
    /// ## Example
    /// ```swift
    /// var options = SkeletonOptions()
    ///
    /// // Minimum 4 digits, no maximum
    /// options.integerWidth = IntegerWidth(minDigits: 4, maxDigits: nil)
    /// // 42 → "0042", 12345 → "12345"
    ///
    /// // Exactly 3 digits (pad or truncate)
    /// options.integerWidth = IntegerWidth(minDigits: 3, maxDigits: 3)
    /// // 42 → "042", 1234 → "234"
    ///
    /// // Min 2, max 4 digits
    /// options.integerWidth = IntegerWidth(minDigits: 2, maxDigits: 4)
    /// // 5 → "05", 12345 → "12,345" (may vary with grouping)
    /// ```
    public struct IntegerWidth: Sendable, Equatable, Codable, Hashable {
        /// Minimum number of integer digits (padding)
        public var minDigits: Int
        /// Maximum number of integer digits (truncation), or nil for no limit
        public var maxDigits: Int?

        /// Creates an integer width specification.
        ///
        /// - Parameters:
        ///   - minDigits: Minimum number of integer digits. Values less than this will be padded with leading zeros.
        ///   - maxDigits: Maximum number of integer digits, or `nil` for no maximum. Values exceeding this will be truncated from the left.
        public init(minDigits: Int, maxDigits: Int? = nil) {
            self.minDigits = minDigits
            self.maxDigits = maxDigits
        }
    }

    // MARK: - Grouping

    /// Grouping strategy for number formatting.
    ///
    /// Controls whether and how grouping separators (e.g., thousands separators) are used.
    ///
    /// ## Cases
    /// - `auto`: Use locale's default grouping
    /// - `off`: Never use grouping separators
    /// - `min2`: Only group if 2 or more digits in group (mapped to auto)
    /// - `onAligned`: Use grouping for alignment purposes (mapped to auto)
    ///
    /// ## Example
    /// ```swift
    /// var options = SkeletonOptions()
    ///
    /// options.grouping = .auto
    /// // 1234567 → "1,234,567" (in en_US)
    ///
    /// options.grouping = .off
    /// // 1234567 → "1234567"
    /// ```
    public enum Grouping: Sendable, Equatable, Codable, Hashable {
        /// Automatic locale-dependent grouping
        case auto
        /// No grouping separators
        case off
        /// Group only if minimum 2 digits
        case min2
        /// Group for alignment
        case onAligned
    }

    // MARK: - Sign Display

    /// Sign display strategy for number formatting.
    ///
    /// Controls when and how to display positive (+) and negative (-) signs.
    ///
    /// ## Cases
    /// - `auto`: Show minus for negative, nothing for positive or zero
    /// - `always`: Always show sign (+ or -)
    /// - `never`: Never show sign
    /// - `accounting`: Use accounting format for negatives (e.g., parentheses)
    /// - `accountingAlways`: Accounting format, always show sign for positive
    /// - `exceptZero`: Show sign except for zero
    /// - `accountingExceptZero`: Accounting format except for zero
    /// - `negative`: Extension feature for negative-only sign
    ///
    /// ## Example
    /// ```swift
    /// var options = SkeletonOptions()
    ///
    /// options.signDisplay = .always
    /// // 42 → "+42", -42 → "-42", 0 → "+0"
    ///
    /// options.signDisplay = .accounting
    /// // 42 → "42", -42 → "(42)"
    ///
    /// options.signDisplay = .never
    /// // -42 → "42"
    /// ```
    public enum SignDisplay: Sendable, Equatable, Codable, Hashable {
        /// Show minus for negative only
        case auto
        /// Always show sign
        case always
        /// Never show sign
        case never
        /// Accounting format always
        case accountingAlways
        /// Accounting format for negatives
        case accounting
        /// Show sign except for zero
        case exceptZero
        /// Accounting except for zero
        case accountingExceptZero
        /// Extension: negative-only sign
        case negative
    }

    // MARK: - Decimal Separator

    /// Decimal separator display strategy.
    ///
    /// Controls when to show the decimal separator (e.g., decimal point or comma).
    ///
    /// ## Cases
    /// - `auto`: Show only if there are fraction digits
    /// - `always`: Always show, even for integers
    ///
    /// ## Example
    /// ```swift
    /// var options = SkeletonOptions()
    ///
    /// options.decimalSeparator = .auto
    /// // 42 → "42", 42.5 → "42.5"
    ///
    /// options.decimalSeparator = .always
    /// // 42 → "42.", 42.5 → "42.5"
    /// ```
    public enum DecimalSeparator: Sendable, Equatable, Codable, Hashable {
        /// Show only if needed
        case auto
        /// Always show decimal separator
        case always
    }

    // MARK: - Properties

    /// The notation style for number representation.
    ///
    /// When `nil`, uses simple (standard) notation.
    public var notation: Notation?

    /// The unit type to format with.
    ///
    /// When `nil`, no unit is appended.
    public var unit: Unit?

    /// The unit display width.
    ///
    /// When `nil`, uses default width for the locale and unit type.
    public var unitWidth: UnitWidth?

    /// The precision specification.
    ///
    /// When `nil`, uses default precision for the number type and unit.
    public var precision: Precision?

    /// The rounding mode.
    ///
    /// When `nil`, uses default rounding (typically half-even).
    public var roundingMode: RoundingMode?

    /// The integer width specification.
    ///
    /// When `nil`, no padding or truncation is applied to the integer part.
    public var integerWidth: IntegerWidth?

    /// Scale factor to multiply the number by before formatting.
    ///
    /// When `nil`, no scaling is applied. Example: `scale = 100` converts 0.5 to 50.
    public var scale: Decimal?

    /// Grouping separator strategy.
    ///
    /// When `nil`, uses locale's default grouping behavior.
    public var grouping: Grouping?

    /// Sign display strategy.
    ///
    /// When `nil`, uses default sign display (show minus only for negative).
    public var signDisplay: SignDisplay?

    /// Decimal separator display strategy.
    ///
    /// When `nil`, shows decimal separator only when needed.
    public var decimalSeparator: DecimalSeparator?

    /// The numbering system to use (e.g., "latn", "arab").
    ///
    /// When `nil`, uses the locale's default numbering system.
    /// Common values: "latn" (0-9), "arab" (٠-٩), "deva" (Devanagari), etc.
    public var numberingSystem: String?

    /// Whether to use Latin digits (0-9) regardless of locale.
    ///
    /// When `true`, overrides the locale's numbering system to use Latin digits.
    /// This is a shorthand for `numberingSystem = "latn"`.
    public var latinDigits: Bool = false

    // MARK: - Initialization

    /// Creates a new `SkeletonOptions` with all properties set to `nil` or default values.
    ///
    /// ## Example
    /// ```swift
    /// var options = SkeletonOptions()
    /// options.unit = .currency(code: "USD")
    /// options.precision = .fractionDigits(min: 2, max: 2)
    /// options.signDisplay = .accounting
    /// ```
    public init() {}
}
