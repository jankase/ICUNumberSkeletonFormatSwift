import Foundation

/// Formatting strategy for currency values.
public struct CurrencyFormattingStrategy: NumberFormattingStrategy {

    private let currencyCode: String

    public init(currencyCode: String) {
        self.currencyCode = currencyCode
    }

    public func format(_ value: Double, options: SkeletonOptions, locale: Locale) -> String {
        let effectiveLocale = NumberingSystemHelper.applyNumberingSystem(to: locale, options: options)
        var format = Decimal.FormatStyle.Currency(code: currencyCode, locale: effectiveLocale)

        format = applyWidth(to: format, options: options)
        format = applyPrecision(to: format, options: options)
        format = applyGrouping(to: format, options: options)
        format = applySign(to: format, value: value, options: options)
        format = applyDecimalSeparator(to: format, options: options)
        format = applyRounding(to: format, options: options)

        return Decimal(value).formatted(format)
    }

    // MARK: - Private Helpers

    private func applyWidth(to format: Decimal.FormatStyle.Currency, options: SkeletonOptions) -> Decimal.FormatStyle.Currency {
        guard let width = options.unitWidth else { return format }

        switch width {
        case .narrow:
            return format.presentation(.narrow)
        case .short:
            return format
        case .fullName:
            return format.presentation(.fullName)
        case .isoCode, .hidden:
            return format.presentation(.isoCode)
        case .formal, .variant:
            return format
        }
    }

    private func applyPrecision(to format: Decimal.FormatStyle.Currency, options: SkeletonOptions) -> Decimal.FormatStyle.Currency {
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
        case .currencyStandard:
            return format
        case .currencyCash:
            return format.precision(.fractionLength(0...2))
        case .increment(let value):
            let decimalPlaces = PrecisionHelper.numberOfDecimalPlaces(in: value)
            return format.precision(.fractionLength(decimalPlaces...decimalPlaces))
        case .unlimited:
            return format.precision(.fractionLength(0...15))
        }
    }

    private func applyGrouping(to format: Decimal.FormatStyle.Currency, options: SkeletonOptions) -> Decimal.FormatStyle.Currency {
        guard let grouping = options.grouping else { return format }

        switch grouping {
        case .auto, .min2, .onAligned:
            return format.grouping(.automatic)
        case .off:
            return format.grouping(.never)
        }
    }

    private func applySign(to format: Decimal.FormatStyle.Currency, value: Double, options: SkeletonOptions) -> Decimal.FormatStyle.Currency {
        guard let signDisplay = options.signDisplay else { return format }

        let isZero = value == 0.0 || value == -0.0

        switch signDisplay {
        case .auto, .negative:
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
            return isZero ? format.sign(strategy: .automatic) : format.sign(strategy: .always())
        case .accountingExceptZero:
            return isZero ? format.sign(strategy: .automatic) : format.sign(strategy: .accountingAlways())
        }
    }

    private func applyDecimalSeparator(to format: Decimal.FormatStyle.Currency, options: SkeletonOptions) -> Decimal.FormatStyle.Currency {
        guard let separator = options.decimalSeparator else { return format }

        switch separator {
        case .auto:
            return format.decimalSeparator(strategy: .automatic)
        case .always:
            return format.decimalSeparator(strategy: .always)
        }
    }

    private func applyRounding(to format: Decimal.FormatStyle.Currency, options: SkeletonOptions) -> Decimal.FormatStyle.Currency {
        guard let roundingMode = options.roundingMode else { return format }
        return format.rounded(rule: RoundingRuleMapper.map(roundingMode))
    }
}
