import Foundation

/// Represents the parsed options from an ICU number skeleton string.
public struct SkeletonOptions: Sendable, Equatable, Codable, Hashable {

    // MARK: - Notation

    /// The notation style for number formatting.
    public enum Notation: Sendable, Equatable, Codable, Hashable {
        case simple
        case scientific
        case engineering
        case compactShort
        case compactLong
    }

    // MARK: - Unit

    /// The unit type for number formatting.
    public enum Unit: Sendable, Equatable, Codable, Hashable {
        case none
        case percent
        case permille
        case currency(code: String)
        case measureUnit(type: String, subtype: String)
    }

    /// The width for displaying units.
    public enum UnitWidth: Sendable, Equatable, Codable, Hashable {
        case narrow
        case short
        case fullName
        case isoCode
        case formal
        case variant
        case hidden
    }

    // MARK: - Precision

    /// Precision specification for number formatting.
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
        case currencyCash
        /// Increment-based precision (e.g., round to 0.05).
        case increment(value: Decimal)
        /// Unlimited precision.
        case unlimited
    }

    // MARK: - Rounding Mode

    /// The rounding mode for number formatting.
    public enum RoundingMode: Sendable, Equatable, Codable, Hashable {
        case ceiling
        case floor
        case down
        case up
        case halfEven
        case halfDown
        case halfUp
        case unnecessary
    }

    // MARK: - Integer Width

    /// Specifies the minimum and maximum integer digits.
    public struct IntegerWidth: Sendable, Equatable, Codable, Hashable {
        public var minDigits: Int
        public var maxDigits: Int?

        public init(minDigits: Int, maxDigits: Int? = nil) {
            self.minDigits = minDigits
            self.maxDigits = maxDigits
        }
    }

    // MARK: - Grouping

    /// Grouping strategy for number formatting.
    public enum Grouping: Sendable, Equatable, Codable, Hashable {
        case auto
        case off
        case min2
        case onAligned
    }

    // MARK: - Sign Display

    /// Sign display strategy for number formatting.
    public enum SignDisplay: Sendable, Equatable, Codable, Hashable {
        case auto
        case always
        case never
        case accountingAlways
        case accounting
        case exceptZero
        case accountingExceptZero
        case negative
    }

    // MARK: - Decimal Separator

    /// Decimal separator display strategy.
    public enum DecimalSeparator: Sendable, Equatable, Codable, Hashable {
        case auto
        case always
    }

    // MARK: - Properties

    /// The notation style.
    public var notation: Notation?

    /// The unit type.
    public var unit: Unit?

    /// The unit display width.
    public var unitWidth: UnitWidth?

    /// The precision specification.
    public var precision: Precision?

    /// The rounding mode.
    public var roundingMode: RoundingMode?

    /// The integer width specification.
    public var integerWidth: IntegerWidth?

    /// Scale factor to multiply the number by before formatting.
    public var scale: Decimal?

    /// Grouping strategy.
    public var grouping: Grouping?

    /// Sign display strategy.
    public var signDisplay: SignDisplay?

    /// Decimal separator display strategy.
    public var decimalSeparator: DecimalSeparator?

    /// The numbering system to use (e.g., "latn", "arab").
    public var numberingSystem: String?

    /// Whether to use Latin digits regardless of locale.
    public var latinDigits: Bool = false

    // MARK: - Initialization

    public init() {}
}
