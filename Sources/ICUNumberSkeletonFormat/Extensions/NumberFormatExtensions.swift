import Foundation

// MARK: - FormatStyle Extensions for Double

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

// MARK: - FormatStyle Extensions for Int

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

// MARK: - FormatStyle Extensions for Decimal

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
