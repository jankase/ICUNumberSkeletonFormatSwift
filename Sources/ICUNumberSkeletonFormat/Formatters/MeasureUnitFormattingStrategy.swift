import Foundation

/// Formatting strategy for measure unit values.
public struct MeasureUnitFormattingStrategy: NumberFormattingStrategy {

    private let unitType: String
    private let unitSubtype: String

    public init(unitType: String, unitSubtype: String) {
        self.unitType = unitType
        self.unitSubtype = unitSubtype
    }

    public func format(_ value: Double, options: SkeletonOptions, locale: Locale) -> String {
        let effectiveLocale = NumberingSystemHelper.applyNumberingSystem(to: locale, options: options)

        guard let unit = MeasureUnitMapping.unit(forType: unitType, subtype: unitSubtype) else {
            // Fallback to decimal formatting if unit not recognized
            return DecimalFormattingStrategy().format(value, options: options, locale: locale)
        }

        // Handle hidden unit width - just format the number
        if options.unitWidth == .hidden {
            return formatNumberOnly(value, options: options, locale: effectiveLocale)
        }

        let measurement = Measurement(value: value, unit: unit)
        let formatter = createMeasurementFormatter(options: options, locale: effectiveLocale)

        return formatter.string(from: measurement)
    }

    // MARK: - Private Helpers

    private func formatNumberOnly(_ value: Double, options: SkeletonOptions, locale: Locale) -> String {
        var format = Decimal.FormatStyle(locale: locale)

        format = applyPrecision(to: format, options: options)
        format = applyGrouping(to: format, options: options)
        format = applySign(to: format, value: value, options: options)
        format = applyRounding(to: format, options: options)

        return Decimal(value).formatted(format)
    }

    private func createMeasurementFormatter(options: SkeletonOptions, locale: Locale) -> MeasurementFormatter {
        let formatter = MeasurementFormatter()
        formatter.locale = locale
        formatter.unitOptions = .providedUnit

        if let width = options.unitWidth {
            switch width {
            case .narrow, .short:
                formatter.unitStyle = .short
            case .fullName:
                formatter.unitStyle = .long
            default:
                formatter.unitStyle = .medium
            }
        }

        if let numberFormatter = formatter.numberFormatter {
            applyPrecisionToNumberFormatter(numberFormatter, options: options)

            if let grouping = options.grouping {
                numberFormatter.usesGroupingSeparator = grouping != .off
            }

            if let roundingMode = options.roundingMode {
                numberFormatter.roundingMode = RoundingRuleMapper.numberFormatterMode(roundingMode)
            }
        }

        return formatter
    }

    private func applyPrecisionToNumberFormatter(_ formatter: NumberFormatter, options: SkeletonOptions) {
        guard let precision = options.precision else { return }

        switch precision {
        case .integer:
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 0
        case .fractionDigits(let min, let max):
            formatter.minimumFractionDigits = min
            formatter.maximumFractionDigits = max
        case .significantDigits(let min, let max):
            formatter.usesSignificantDigits = true
            formatter.minimumSignificantDigits = min
            formatter.maximumSignificantDigits = max
        case .fractionSignificant(let minFrac, let maxFrac, _, _):
            formatter.minimumFractionDigits = minFrac
            formatter.maximumFractionDigits = maxFrac
        case .increment(let value):
            formatter.roundingIncrement = NSDecimalNumber(decimal: value)
        case .unlimited:
            formatter.maximumFractionDigits = 15
        default:
            break
        }
    }

    private func applyPrecision(to format: Decimal.FormatStyle, options: SkeletonOptions) -> Decimal.FormatStyle {
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

    private func applyGrouping(to format: Decimal.FormatStyle, options: SkeletonOptions) -> Decimal.FormatStyle {
        guard let grouping = options.grouping else { return format }

        switch grouping {
        case .auto, .min2, .onAligned:
            return format.grouping(.automatic)
        case .off:
            return format.grouping(.never)
        }
    }

    private func applySign(to format: Decimal.FormatStyle, value: Double, options: SkeletonOptions) -> Decimal.FormatStyle {
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

    private func applyRounding(to format: Decimal.FormatStyle, options: SkeletonOptions) -> Decimal.FormatStyle {
        guard let roundingMode = options.roundingMode else { return format }
        return format.rounded(rule: RoundingRuleMapper.map(roundingMode))
    }
}
