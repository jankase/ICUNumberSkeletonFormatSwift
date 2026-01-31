import Foundation

/// Builds and configures a NumberFormatter based on skeleton options.
struct NumberFormatterBuilder {

    /// Creates a configured NumberFormatter from skeleton options.
    ///
    /// - Parameters:
    ///   - options: The skeleton options to apply.
    ///   - locale: The locale to use for formatting.
    /// - Returns: A configured NumberFormatter.
    func build(from options: SkeletonOptions, locale: Locale) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale

        // Apply notation
        applyNotation(options.notation, to: formatter)

        // Apply unit
        applyUnit(options.unit, width: options.unitWidth, to: formatter)

        // Apply precision
        applyPrecision(options.precision, to: formatter)

        // Apply rounding mode
        applyRoundingMode(options.roundingMode, to: formatter)

        // Apply integer width
        applyIntegerWidth(options.integerWidth, to: formatter)

        // Apply scale
        if let scale = options.scale {
            formatter.multiplier = scale as NSDecimalNumber
        }

        // Apply grouping
        applyGrouping(options.grouping, to: formatter)

        // Apply sign display
        applySignDisplay(options.signDisplay, to: formatter)

        // Apply decimal separator
        applyDecimalSeparator(options.decimalSeparator, to: formatter)

        return formatter
    }

    // MARK: - Notation

    private func applyNotation(_ notation: SkeletonOptions.Notation?, to formatter: NumberFormatter) {
        guard let notation = notation else { return }

        switch notation {
        case .simple:
            formatter.numberStyle = .decimal
        case .scientific:
            formatter.numberStyle = .scientific
        case .engineering:
            formatter.numberStyle = .scientific
            // Engineering notation uses exponents that are multiples of 3
            formatter.exponentSymbol = "E"
        case .compactShort:
            formatter.numberStyle = .decimal
            formatter.usesSignificantDigits = true
            formatter.maximumSignificantDigits = 3
        case .compactLong:
            formatter.numberStyle = .decimal
            formatter.usesSignificantDigits = true
            formatter.maximumSignificantDigits = 4
        }
    }

    // MARK: - Unit

    private func applyUnit(
        _ unit: SkeletonOptions.Unit?,
        width: SkeletonOptions.UnitWidth?,
        to formatter: NumberFormatter
    ) {
        guard let unit = unit else { return }

        switch unit {
        case .none:
            break
        case .percent:
            formatter.numberStyle = .percent
        case .permille:
            formatter.numberStyle = .decimal
            formatter.positiveSuffix = "‰"
            formatter.negativeSuffix = "‰"
            formatter.multiplier = 1000
        case .currency(let code):
            formatter.numberStyle = .currency
            formatter.currencyCode = code
            applyUnitWidth(width, for: .currency, to: formatter)
        case .measureUnit:
            // Measure units require iOS 16+/macOS 13+ MeasurementFormatter
            // For now, we just set decimal style
            formatter.numberStyle = .decimal
        }
    }

    private func applyUnitWidth(
        _ width: SkeletonOptions.UnitWidth?,
        for unit: UnitType,
        to formatter: NumberFormatter
    ) {
        guard let width = width else { return }

        switch (unit, width) {
        case (.currency, .narrow):
            formatter.currencySymbol = formatter.locale.currencySymbol ?? "$"
        case (.currency, .short):
            formatter.currencySymbol = formatter.locale.currencySymbol ?? "$"
        case (.currency, .isoCode):
            formatter.currencySymbol = formatter.currencyCode
        case (.currency, .fullName):
            formatter.numberStyle = .currencyPlural
        case (.currency, .hidden):
            formatter.currencySymbol = ""
        default:
            break
        }
    }

    private enum UnitType {
        case currency
        case measure
    }

    // MARK: - Precision

    private func applyPrecision(_ precision: SkeletonOptions.Precision?, to formatter: NumberFormatter) {
        guard let precision = precision else { return }

        switch precision {
        case .integer:
            formatter.maximumFractionDigits = 0
            formatter.minimumFractionDigits = 0
            formatter.usesSignificantDigits = false
        case .fractionDigits(let min, let max):
            formatter.minimumFractionDigits = min
            formatter.maximumFractionDigits = max
            formatter.usesSignificantDigits = false
        case .significantDigits(let min, let max):
            formatter.usesSignificantDigits = true
            formatter.minimumSignificantDigits = min
            formatter.maximumSignificantDigits = max
        case .fractionSignificant(let minFrac, let maxFrac, let minSig, let maxSig):
            // Combine fraction and significant digit constraints
            formatter.minimumFractionDigits = minFrac
            formatter.maximumFractionDigits = maxFrac
            formatter.usesSignificantDigits = true
            formatter.minimumSignificantDigits = minSig
            formatter.maximumSignificantDigits = maxSig
        case .currencyStandard, .currencyCash:
            // Use locale-specific currency precision
            break
        case .increment(let value):
            formatter.roundingIncrement = value as NSNumber
        case .unlimited:
            formatter.maximumFractionDigits = 340 // Maximum supported by NumberFormatter
            formatter.usesSignificantDigits = false
        }
    }

    // MARK: - Rounding Mode

    private func applyRoundingMode(_ mode: SkeletonOptions.RoundingMode?, to formatter: NumberFormatter) {
        guard let mode = mode else { return }

        switch mode {
        case .ceiling:
            formatter.roundingMode = .ceiling
        case .floor:
            formatter.roundingMode = .floor
        case .down:
            formatter.roundingMode = .down
        case .up:
            formatter.roundingMode = .up
        case .halfEven:
            formatter.roundingMode = .halfEven
        case .halfDown:
            formatter.roundingMode = .halfDown
        case .halfUp:
            formatter.roundingMode = .halfUp
        case .unnecessary:
            // No rounding should occur - not directly supported
            formatter.roundingMode = .halfEven
        }
    }

    // MARK: - Integer Width

    private func applyIntegerWidth(_ width: SkeletonOptions.IntegerWidth?, to formatter: NumberFormatter) {
        guard let width = width else { return }

        formatter.minimumIntegerDigits = width.minDigits
        if let maxDigits = width.maxDigits {
            formatter.maximumIntegerDigits = maxDigits
        }
    }

    // MARK: - Grouping

    private func applyGrouping(_ grouping: SkeletonOptions.Grouping?, to formatter: NumberFormatter) {
        guard let grouping = grouping else { return }

        switch grouping {
        case .auto:
            formatter.usesGroupingSeparator = true
        case .off:
            formatter.usesGroupingSeparator = false
        case .min2:
            formatter.usesGroupingSeparator = true
            formatter.groupingSize = 3
        case .onAligned:
            formatter.usesGroupingSeparator = true
        }
    }

    // MARK: - Sign Display

    private func applySignDisplay(_ signDisplay: SkeletonOptions.SignDisplay?, to formatter: NumberFormatter) {
        guard let signDisplay = signDisplay else { return }

        switch signDisplay {
        case .auto:
            // Default behavior
            break
        case .always:
            formatter.positivePrefix = "+"
        case .never:
            formatter.negativePrefix = ""
            formatter.positivePrefix = ""
        case .accounting:
            if formatter.numberStyle == .currency {
                formatter.numberStyle = .currencyAccounting
            }
        case .accountingAlways:
            if formatter.numberStyle == .currency {
                formatter.numberStyle = .currencyAccounting
            }
            formatter.positivePrefix = "+"
        case .exceptZero:
            formatter.positivePrefix = "+"
            formatter.zeroSymbol = "0"
        case .accountingExceptZero:
            if formatter.numberStyle == .currency {
                formatter.numberStyle = .currencyAccounting
            }
            formatter.positivePrefix = "+"
        case .negative:
            formatter.positivePrefix = ""
        }
    }

    // MARK: - Decimal Separator

    private func applyDecimalSeparator(
        _ separator: SkeletonOptions.DecimalSeparator?,
        to formatter: NumberFormatter
    ) {
        guard let separator = separator else { return }

        switch separator {
        case .auto:
            formatter.alwaysShowsDecimalSeparator = false
        case .always:
            formatter.alwaysShowsDecimalSeparator = true
        }
    }
}
