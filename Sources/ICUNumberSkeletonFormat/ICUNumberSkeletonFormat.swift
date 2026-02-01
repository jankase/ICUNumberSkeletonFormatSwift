import Foundation

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

    /// Creates a new format style with the given skeleton string.
    ///
    /// - Parameters:
    ///   - skeleton: The ICU number skeleton string.
    ///   - locale: The locale to use for formatting. Defaults to the current locale.
    /// - Note: If the skeleton is invalid, formatting will fall back to default number formatting.
    public init(skeleton: String, locale: Locale = .current) {
        self.skeleton = skeleton
        self.locale = locale
        let parser = SkeletonParser()
        self.options = (try? parser.parse(skeleton)) ?? SkeletonOptions()
    }

    /// Creates a new format style with pre-parsed skeleton options.
    ///
    /// - Parameters:
    ///   - options: The skeleton options to use.
    ///   - locale: The locale to use for formatting. Defaults to the current locale.
    public init(options: SkeletonOptions, locale: Locale = .current) {
        self.options = options
        self.locale = locale
        self.skeleton = ""
    }

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

        // Build and apply the appropriate format style
        return formatValue(scaledValue)
    }

    private func formatValue(_ value: Double) -> String {
        // Handle currency formatting
        if case .currency(let code) = options.unit {
            return formatCurrency(value, code: code)
        }

        // Handle percent formatting
        if case .percent = options.unit {
            return formatPercent(value)
        }

        // Handle permille formatting
        if case .permille = options.unit {
            return formatPermille(value)
        }

        // Handle measure unit formatting
        if case .measureUnit(let type, let subtype) = options.unit {
            return formatMeasureUnit(value, type: type, subtype: subtype)
        }

        // Handle decimal/other formatting
        return formatDecimal(value)
    }

    private func formatCurrency(_ value: Double, code: String) -> String {
        let effectiveLocale = applyNumberingSystem(to: locale)
        var format = Decimal.FormatStyle.Currency(code: code, locale: effectiveLocale)

        // Apply unit width
        format = applyCurrencyWidth(to: format)

        // Apply precision
        format = applyCurrencyPrecision(to: format)

        // Apply grouping
        format = applyCurrencyGrouping(to: format)

        // Apply sign display
        format = applyCurrencySign(to: format, value: value)

        // Apply decimal separator
        format = applyCurrencyDecimalSeparator(to: format)

        // Apply rounding
        format = applyCurrencyRounding(to: format)

        return Decimal(value).formatted(format)
    }

    private func formatPercent(_ value: Double) -> String {
        let effectiveLocale = applyNumberingSystem(to: locale)
        var format = Decimal.FormatStyle.Percent(locale: effectiveLocale)

        // Apply precision
        format = applyPercentPrecision(to: format)

        // Apply grouping
        format = applyPercentGrouping(to: format)

        // Apply sign display
        format = applyPercentSign(to: format, value: value)

        // Apply rounding
        format = applyPercentRounding(to: format)

        return Decimal(value).formatted(format)
    }

    private func formatPermille(_ value: Double) -> String {
        let effectiveLocale = applyNumberingSystem(to: locale)
        // Scale by 1000 for permille
        let scaledValue = value * 1000
        var format = Decimal.FormatStyle(locale: effectiveLocale)

        // Apply precision
        format = applyDecimalPrecision(to: format)

        // Apply grouping
        format = applyDecimalGrouping(to: format)

        // Apply sign display (use original value for zero check)
        format = applyDecimalSign(to: format, value: value)

        // Apply decimal separator
        format = applyDecimalDecimalSeparator(to: format)

        // Apply rounding
        format = applyDecimalRounding(to: format)

        let formattedNumber = Decimal(scaledValue).formatted(format)
        // Append permille symbol
        return formattedNumber + "\u{2030}" // ‰ symbol
    }

    private func formatMeasureUnit(_ value: Double, type: String, subtype: String) -> String {
        let effectiveLocale = applyNumberingSystem(to: locale)
        
        // Map type-subtype to Foundation units
        guard let unit = measureUnitFromTypeSubtype(type: type, subtype: subtype) else {
            // Fallback to decimal formatting if unit not recognized
            return formatDecimal(value)
        }

        // Create measurement
        let measurement = Measurement(value: value, unit: unit)
        
        // Create formatter with appropriate width
        let formatter = MeasurementFormatter()
        formatter.locale = effectiveLocale
        formatter.unitOptions = .providedUnit
        
        // Apply unit width if specified
        if let width = options.unitWidth {
            switch width {
            case .narrow:
                formatter.unitStyle = .short
            case .short:
                formatter.unitStyle = .short
            case .fullName:
                formatter.unitStyle = .long
            case .hidden:
                // Format only the number part
                var numberFormat = Decimal.FormatStyle(locale: effectiveLocale)
                numberFormat = applyDecimalPrecision(to: numberFormat)
                numberFormat = applyDecimalGrouping(to: numberFormat)
                numberFormat = applyDecimalSign(to: numberFormat, value: value)
                numberFormat = applyDecimalRounding(to: numberFormat)
                return Decimal(value).formatted(numberFormat)
            default:
                formatter.unitStyle = .medium
            }
        }

        // Apply number formatting options through formatter's numberFormatter
        if let numberFormatter = formatter.numberFormatter {
            // Apply precision
            applyPrecisionToNumberFormatter(numberFormatter)
            
            // Apply grouping
            if let grouping = options.grouping {
                numberFormatter.usesGroupingSeparator = grouping != .off
            }
            
            // Apply rounding mode
            if let roundingMode = options.roundingMode {
                numberFormatter.roundingMode = numberFormatterRoundingMode(from: roundingMode)
            }
        }

        return formatter.string(from: measurement)
    }

    private func formatDecimal(_ value: Double) -> String {
        let effectiveLocale = applyNumberingSystem(to: locale)
        var format = Decimal.FormatStyle(locale: effectiveLocale)

        // Apply notation
        format = applyNotation(to: format)

        // Apply precision
        format = applyDecimalPrecision(to: format)

        // Apply grouping
        format = applyDecimalGrouping(to: format)

        // Apply sign display
        format = applyDecimalSign(to: format, value: value)

        // Apply decimal separator
        format = applyDecimalDecimalSeparator(to: format)

        // Apply rounding
        format = applyDecimalRounding(to: format)

        // Convert to string
        var result = Decimal(value).formatted(format)

        // Apply integer width padding/truncation if specified
        if let intWidth = options.integerWidth {
            result = applyIntegerWidth(to: result, integerWidth: intWidth, locale: effectiveLocale)
        }

        return result
    }

    // MARK: - Helper Methods

    private func applyNumberingSystem(to locale: Locale) -> Locale {
        // Apply numbering system if specified
        if let system = options.numberingSystem {
            var components = Locale.Components(locale: locale)
            components.numberingSystem = Locale.NumberingSystem(system)
            return Locale(components: components)
        }
        
        // Apply latin digits override if specified
        if options.latinDigits {
            var components = Locale.Components(locale: locale)
            components.numberingSystem = Locale.NumberingSystem("latn")
            return Locale(components: components)
        }
        
        return locale
    }

    private func applyIntegerWidth(to formattedString: String, integerWidth: SkeletonOptions.IntegerWidth, locale: Locale) -> String {
        // Extract the integer part (before decimal separator or end of string)
        let decimalSeparator = Locale.current.decimalSeparator ?? "."
        let parts = formattedString.components(separatedBy: decimalSeparator)
        
        guard let integerPart = parts.first else { return formattedString }
        let fractionalPart = parts.count > 1 ? parts[1] : nil
        
        // Remove grouping separators to count actual digits
        let groupingSeparator = locale.groupingSeparator ?? ","
        let sign = integerPart.first == "-" || integerPart.first == "+" ? String(integerPart.first!) : ""
        var digitsOnly = integerPart.filter { $0.isNumber }
        
        // Apply minimum width (pad with zeros)
        while digitsOnly.count < integerWidth.minDigits {
            digitsOnly = "0" + digitsOnly
        }
        
        // Apply maximum width (truncate from left) if specified
        if let maxDigits = integerWidth.maxDigits, digitsOnly.count > maxDigits {
            digitsOnly = String(digitsOnly.suffix(maxDigits))
        }
        
        // Re-apply grouping
        var formatted = ""
        let reversedDigits = String(digitsOnly.reversed())
        for (index, char) in reversedDigits.enumerated() {
            if index > 0 && index % 3 == 0 && options.grouping != .off {
                formatted = groupingSeparator + formatted
            }
            formatted = String(char) + formatted
        }
        
        // Reconstruct the full number
        var result = sign + formatted
        if let frac = fractionalPart {
            result += decimalSeparator + frac
        }
        
        return result
    }

    private func measureUnitFromTypeSubtype(type: String, subtype: String) -> Dimension? {
        // Map ICU measure unit identifiers to Foundation units
        switch (type, subtype) {
        // Length
        case ("length", "meter"): return UnitLength.meters
        case ("length", "kilometer"): return UnitLength.kilometers
        case ("length", "centimeter"): return UnitLength.centimeters
        case ("length", "millimeter"): return UnitLength.millimeters
        case ("length", "mile"): return UnitLength.miles
        case ("length", "yard"): return UnitLength.yards
        case ("length", "foot"): return UnitLength.feet
        case ("length", "inch"): return UnitLength.inches
        
        // Mass
        case ("mass", "kilogram"): return UnitMass.kilograms
        case ("mass", "gram"): return UnitMass.grams
        case ("mass", "milligram"): return UnitMass.milligrams
        case ("mass", "pound"): return UnitMass.pounds
        case ("mass", "ounce"): return UnitMass.ounces
        
        // Duration
        case ("duration", "second"): return UnitDuration.seconds
        case ("duration", "minute"): return UnitDuration.minutes
        case ("duration", "hour"): return UnitDuration.hours
        
        // Temperature
        case ("temperature", "celsius"): return UnitTemperature.celsius
        case ("temperature", "fahrenheit"): return UnitTemperature.fahrenheit
        case ("temperature", "kelvin"): return UnitTemperature.kelvin
        
        // Volume
        case ("volume", "liter"): return UnitVolume.liters
        case ("volume", "milliliter"): return UnitVolume.milliliters
        case ("volume", "gallon"): return UnitVolume.gallons
        case ("volume", "fluid-ounce"): return UnitVolume.fluidOunces
        
        // Speed
        case ("speed", "meter-per-second"): return UnitSpeed.metersPerSecond
        case ("speed", "kilometer-per-hour"): return UnitSpeed.kilometersPerHour
        case ("speed", "mile-per-hour"): return UnitSpeed.milesPerHour
        
        // Area
        case ("area", "square-meter"): return UnitArea.squareMeters
        case ("area", "square-kilometer"): return UnitArea.squareKilometers
        case ("area", "square-mile"): return UnitArea.squareMiles
        case ("area", "square-foot"): return UnitArea.squareFeet
        
        default: return nil
        }
    }

    private func applyPrecisionToNumberFormatter(_ formatter: NumberFormatter) {
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

    private func numberFormatterRoundingMode(from mode: SkeletonOptions.RoundingMode) -> NumberFormatter.RoundingMode {
        switch mode {
        case .ceiling: return .ceiling
        case .floor: return .floor
        case .down: return .down
        case .up: return .up
        case .halfEven: return .halfEven
        case .halfDown: return .halfDown
        case .halfUp: return .halfUp
        case .unnecessary: return .halfEven
        }
    }

    // MARK: - Decimal Format Modifiers

    private func applyNotation(to format: Decimal.FormatStyle) -> Decimal.FormatStyle {
        guard let notation = options.notation else { return format }

        switch notation {
        case .simple:
            return format.notation(.automatic)
        case .scientific:
            return format.notation(.scientific)
        case .compactShort:
            return format.notation(.compactName)
        case .compactLong:
            return format.notation(.compactName)
        case .engineering:
            return format.notation(.scientific)
        }
    }

    private func applyDecimalPrecision(to format: Decimal.FormatStyle) -> Decimal.FormatStyle {
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
            // For increment-based rounding, we use the number of decimal places in the increment
            let decimalPlaces = numberOfDecimalPlaces(in: value)
            return format.precision(.fractionLength(decimalPlaces...decimalPlaces))
        case .unlimited:
            return format.precision(.fractionLength(0...15))
        }
    }

    private func numberOfDecimalPlaces(in decimal: Decimal) -> Int {
        let nsDecimal = NSDecimalNumber(decimal: decimal)
        let string = nsDecimal.stringValue
        
        if let dotIndex = string.firstIndex(of: ".") {
            return string.distance(from: string.index(after: dotIndex), to: string.endIndex)
        }
        
        return 0
    }

    private func applyDecimalGrouping(to format: Decimal.FormatStyle) -> Decimal.FormatStyle {
        guard let grouping = options.grouping else { return format }

        switch grouping {
        case .auto:
            return format.grouping(.automatic)
        case .off:
            return format.grouping(.never)
        case .min2, .onAligned:
            return format.grouping(.automatic)
        }
    }

    private func applyDecimalSign(to format: Decimal.FormatStyle, value: Double) -> Decimal.FormatStyle {
        guard let signDisplay = options.signDisplay else { return format }

        // Check if value is zero for exceptZero cases
        let isZero = value == 0.0 || value == -0.0

        switch signDisplay {
        case .auto:
            return format.sign(strategy: .automatic)
        case .always, .accountingAlways:
            return format.sign(strategy: .always())
        case .never:
            return format.sign(strategy: .never)
        case .exceptZero, .accountingExceptZero:
            // If value is zero, don't show sign; otherwise always show sign
            if isZero {
                return format.sign(strategy: .automatic)
            } else {
                return format.sign(strategy: .always())
            }
        case .accounting:
            return format.sign(strategy: .automatic)
        case .negative:
            return format.sign(strategy: .automatic)
        }
    }

    private func applyDecimalDecimalSeparator(to format: Decimal.FormatStyle) -> Decimal.FormatStyle {
        guard let separator = options.decimalSeparator else { return format }

        switch separator {
        case .auto:
            return format.decimalSeparator(strategy: .automatic)
        case .always:
            return format.decimalSeparator(strategy: .always)
        }
    }

    private func applyDecimalRounding(to format: Decimal.FormatStyle) -> Decimal.FormatStyle {
        guard let roundingMode = options.roundingMode else { return format }

        let rule: FloatingPointRoundingRule = switch roundingMode {
        case .ceiling: .up
        case .floor: .down
        case .down: .towardZero
        case .up: .awayFromZero
        case .halfEven: .toNearestOrEven
        case .halfDown: .toNearestOrEven
        case .halfUp: .toNearestOrAwayFromZero
        case .unnecessary: .toNearestOrEven
        }

        return format.rounded(rule: rule)
    }

    // MARK: - Currency Format Modifiers

    private func applyCurrencyWidth(to format: Decimal.FormatStyle.Currency) -> Decimal.FormatStyle.Currency {
        guard let width = options.unitWidth else { return format }

        switch width {
        case .narrow:
            return format.presentation(.narrow)
        case .short:
            return format // default is short
        case .fullName:
            return format.presentation(.fullName)
        case .isoCode:
            return format.presentation(.isoCode)
        case .hidden:
            // Hidden means show no symbol - use isoCode as closest approximation
            return format.presentation(.isoCode)
        case .formal, .variant:
            // These don't have direct equivalents in Foundation
            return format
        }
    }

    private func applyCurrencyPrecision(to format: Decimal.FormatStyle.Currency) -> Decimal.FormatStyle.Currency {
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
            // Use standard currency precision (default behavior)
            return format
        case .currencyCash:
            // Cash rounding - typically rounds to nearest 0.05 for some currencies
            // Foundation doesn't have built-in cash rounding, so we'll use increment
            return format.precision(.fractionLength(0...2))
        case .increment(let value):
            // Determine precision from increment value
            let decimalPlaces = numberOfDecimalPlaces(in: value)
            return format.precision(.fractionLength(decimalPlaces...decimalPlaces))
        case .unlimited:
            return format.precision(.fractionLength(0...15))
        }
    }

    private func applyCurrencyGrouping(to format: Decimal.FormatStyle.Currency) -> Decimal.FormatStyle.Currency {
        guard let grouping = options.grouping else { return format }

        switch grouping {
        case .auto:
            return format.grouping(.automatic)
        case .off:
            return format.grouping(.never)
        case .min2, .onAligned:
            return format.grouping(.automatic)
        }
    }

    private func applyCurrencySign(to format: Decimal.FormatStyle.Currency, value: Double) -> Decimal.FormatStyle.Currency {
        guard let signDisplay = options.signDisplay else { return format }

        // Check if value is zero for exceptZero cases
        let isZero = value == 0.0 || value == -0.0

        switch signDisplay {
        case .auto:
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
            // If value is zero, don't show sign; otherwise always show sign
            if isZero {
                return format.sign(strategy: .automatic)
            } else {
                return format.sign(strategy: .always())
            }
        case .accountingExceptZero:
            // If value is zero, use automatic; otherwise use accountingAlways
            if isZero {
                return format.sign(strategy: .automatic)
            } else {
                return format.sign(strategy: .accountingAlways())
            }
        case .negative:
            return format.sign(strategy: .automatic)
        }
    }

    private func applyCurrencyDecimalSeparator(to format: Decimal.FormatStyle.Currency) -> Decimal.FormatStyle.Currency {
        guard let separator = options.decimalSeparator else { return format }

        switch separator {
        case .auto:
            return format.decimalSeparator(strategy: .automatic)
        case .always:
            return format.decimalSeparator(strategy: .always)
        }
    }

    private func applyCurrencyRounding(to format: Decimal.FormatStyle.Currency) -> Decimal.FormatStyle.Currency {
        guard let roundingMode = options.roundingMode else { return format }

        let rule: FloatingPointRoundingRule = switch roundingMode {
        case .ceiling: .up
        case .floor: .down
        case .down: .towardZero
        case .up: .awayFromZero
        case .halfEven: .toNearestOrEven
        case .halfDown: .toNearestOrEven
        case .halfUp: .toNearestOrAwayFromZero
        case .unnecessary: .toNearestOrEven
        }

        return format.rounded(rule: rule)
    }

    // MARK: - Percent Format Modifiers

    private func applyPercentPrecision(to format: Decimal.FormatStyle.Percent) -> Decimal.FormatStyle.Percent {
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
            let decimalPlaces = numberOfDecimalPlaces(in: value)
            return format.precision(.fractionLength(decimalPlaces...decimalPlaces))
        case .unlimited:
            return format.precision(.fractionLength(0...15))
        }
    }

    private func applyPercentGrouping(to format: Decimal.FormatStyle.Percent) -> Decimal.FormatStyle.Percent {
        guard let grouping = options.grouping else { return format }

        switch grouping {
        case .auto:
            return format.grouping(.automatic)
        case .off:
            return format.grouping(.never)
        case .min2, .onAligned:
            return format.grouping(.automatic)
        }
    }

    private func applyPercentSign(to format: Decimal.FormatStyle.Percent, value: Double) -> Decimal.FormatStyle.Percent {
        guard let signDisplay = options.signDisplay else { return format }

        // Check if value is zero for exceptZero cases
        let isZero = value == 0.0 || value == -0.0

        switch signDisplay {
        case .auto:
            return format.sign(strategy: .automatic)
        case .always, .accountingAlways:
            return format.sign(strategy: .always())
        case .never:
            return format.sign(strategy: .never)
        case .exceptZero, .accountingExceptZero:
            // If value is zero, don't show sign; otherwise always show sign
            if isZero {
                return format.sign(strategy: .automatic)
            } else {
                return format.sign(strategy: .always())
            }
        case .accounting, .negative:
            return format.sign(strategy: .automatic)
        }
    }

    private func applyPercentRounding(to format: Decimal.FormatStyle.Percent) -> Decimal.FormatStyle.Percent {
        guard let roundingMode = options.roundingMode else { return format }

        let rule: FloatingPointRoundingRule = switch roundingMode {
        case .ceiling: .up
        case .floor: .down
        case .down: .towardZero
        case .up: .awayFromZero
        case .halfEven: .toNearestOrEven
        case .halfDown: .toNearestOrEven
        case .halfUp: .toNearestOrAwayFromZero
        case .unnecessary: .toNearestOrEven
        }

        return format.rounded(rule: rule)
    }
}

// MARK: - FormatStyle Extensions

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

// MARK: - Integer FormatStyle

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

    public func format(_ value: Value) -> String {
        doubleStyle.format(Double(value))
    }
}

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

// MARK: - Decimal FormatStyle

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

    public func format(_ value: Decimal) -> String {
        doubleStyle.format(NSDecimalNumber(decimal: value).doubleValue)
    }
}

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
