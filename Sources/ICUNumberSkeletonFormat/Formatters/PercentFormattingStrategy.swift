import Foundation

/// Formatting strategy for percent values.
public struct PercentFormattingStrategy: NumberFormattingStrategy {

    public init() {}

    public func format(_ value: Double, options: SkeletonOptions, locale: Locale) -> String {
        let effectiveLocale = NumberingSystemHelper.applyNumberingSystem(to: locale, options: options)
        var format = Decimal.FormatStyle.Percent(locale: effectiveLocale)

        format = applyPrecision(to: format, options: options)
        format = applyGrouping(to: format, options: options)
        format = applySign(to: format, value: value, options: options)
        format = applyRounding(to: format, options: options)

        return Decimal(value).formatted(format)
    }

    // MARK: - Private Helpers

    private func applyPrecision(to format: Decimal.FormatStyle.Percent, options: SkeletonOptions) -> Decimal.FormatStyle.Percent {
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
            let decimalPlaces = PrecisionHelper.numberOfDecimalPlaces(in: value)
            return format.precision(.fractionLength(decimalPlaces...decimalPlaces))
        case .unlimited:
            return format.precision(.fractionLength(0...15))
        }
    }

    private func applyGrouping(to format: Decimal.FormatStyle.Percent, options: SkeletonOptions) -> Decimal.FormatStyle.Percent {
        guard let grouping = options.grouping else { return format }

        switch grouping {
        case .auto, .min2, .onAligned:
            return format.grouping(.automatic)
        case .off:
            return format.grouping(.never)
        }
    }

    private func applySign(to format: Decimal.FormatStyle.Percent, value: Double, options: SkeletonOptions) -> Decimal.FormatStyle.Percent {
        guard let signDisplay = options.signDisplay else { return format }

        let isZero = value == 0.0 || value == -0.0

        switch signDisplay {
        case .auto, .accounting, .negative:
            return format.sign(strategy: .automatic)
        case .always, .accountingAlways:
            return format.sign(strategy: .always())
        case .never:
            return format.sign(strategy: .never)
        case .exceptZero, .accountingExceptZero:
            return isZero ? format.sign(strategy: .automatic) : format.sign(strategy: .always())
        }
    }

    private func applyRounding(to format: Decimal.FormatStyle.Percent, options: SkeletonOptions) -> Decimal.FormatStyle.Percent {
        guard let roundingMode = options.roundingMode else { return format }
        return format.rounded(rule: RoundingRuleMapper.map(roundingMode))
    }
}
