import Foundation

/// Protocol defining the contract for number formatting strategies.
/// Following the Strategy pattern for different number formatting types.
public protocol NumberFormattingStrategy: Sendable {
    /// Formats a double value according to the strategy's rules.
    /// - Parameters:
    ///   - value: The value to format.
    ///   - options: The skeleton options to apply.
    ///   - locale: The locale for formatting.
    /// - Returns: The formatted string.
    func format(_ value: Double, options: SkeletonOptions, locale: Locale) -> String
}

/// Factory for creating the appropriate formatting strategy based on skeleton options.
public struct FormatterFactory: Sendable {

    public static let shared = FormatterFactory()

    private init() {}

    /// Returns the appropriate formatter strategy for the given options.
    /// - Parameter options: The skeleton options to determine the formatter type.
    /// - Returns: A formatting strategy appropriate for the options.
    public func formatter(for options: SkeletonOptions) -> NumberFormattingStrategy {
        guard let unit = options.unit else {
            return DecimalFormattingStrategy()
        }

        switch unit {
        case .currency(let code):
            return CurrencyFormattingStrategy(currencyCode: code)
        case .percent:
            return PercentFormattingStrategy()
        case .permille:
            return PermilleFormattingStrategy()
        case .measureUnit(let type, let subtype):
            return MeasureUnitFormattingStrategy(unitType: type, unitSubtype: subtype)
        case .none:
            return DecimalFormattingStrategy()
        }
    }
}
