import Foundation

/// Errors that can occur during skeleton parsing.
///
/// These errors provide specific information about what went wrong when parsing
/// an ICU number skeleton string, including the invalid portion of the input.
public enum SkeletonParseError: Error, Sendable, Equatable {
    /// An unrecognized or invalid token was encountered.
    ///
    /// - Parameter String: The invalid token that was found.
    case invalidToken(String)
    
    /// A precision specification is malformed or invalid.
    ///
    /// Valid precision formats include:
    /// - `.00` - Fixed fraction digits
    /// - `@@@` - Significant digits
    /// - `precision-increment/0.05` - Round to increment
    ///
    /// - Parameter String: The invalid precision specification.
    case invalidPrecision(String)
    
    /// An integer width specification is malformed or invalid.
    ///
    /// Valid formats include:
    /// - `integer-width/0000` - Minimum padding
    /// - `integer-width/+000` - Truncation
    /// - `integer-width/##00` - Min/max digits
    ///
    /// - Parameter String: The invalid integer width specification.
    case invalidIntegerWidth(String)
    
    /// A scale value could not be parsed as a number.
    ///
    /// - Parameter String: The invalid scale value.
    case invalidScale(String)
    
    /// A currency code is not valid (must be 3 uppercase letters).
    ///
    /// Valid examples: USD, EUR, GBP, JPY
    ///
    /// - Parameter String: The invalid currency code.
    case invalidCurrencyCode(String)
    
    /// A measure unit specification is malformed.
    ///
    /// Valid format: `measure-unit/type-subtype` (e.g., `length-meter`)
    ///
    /// - Parameter String: The invalid measure unit specification.
    case invalidMeasureUnit(String)
    
    /// A numbering system identifier is invalid.
    ///
    /// - Parameter String: The invalid numbering system.
    case invalidNumberingSystem(String)
    
    /// An option was found that is not expected in this context.
    ///
    /// - Parameter String: The unexpected option.
    case unexpectedOption(String)
    
    /// The same option was specified more than once.
    ///
    /// - Parameter String: The duplicate option.
    case duplicateOption(String)
}

extension SkeletonParseError: LocalizedError {
    /// A localized description of the error.
    public var errorDescription: String? {
        switch self {
        case .invalidToken(let token):
            return "Invalid skeleton token: '\(token)'"
        case .invalidPrecision(let precision):
            return "Invalid precision specification: '\(precision)'"
        case .invalidIntegerWidth(let width):
            return "Invalid integer width: '\(width)'"
        case .invalidScale(let scale):
            return "Invalid scale value: '\(scale)'"
        case .invalidCurrencyCode(let code):
            return "Invalid currency code: '\(code)'"
        case .invalidMeasureUnit(let unit):
            return "Invalid measure unit: '\(unit)'"
        case .invalidNumberingSystem(let system):
            return "Invalid numbering system: '\(system)'"
        case .unexpectedOption(let option):
            return "Unexpected option: '\(option)'"
        case .duplicateOption(let option):
            return "Duplicate option: '\(option)'"
        }
    }
}

/// Parses ICU number skeleton strings into structured `SkeletonOptions`.
///
/// The parser follows the ICU Number Skeleton specification, where tokens are
/// separated by spaces (U+0020) and can be combined to create complex formatting rules.
///
/// ## Token Separator Specification
///
/// Per ICU specification, tokens are separated by **spaces only**:
/// - ✅ Valid: `"currency/USD .00"`
/// - ❌ Invalid: `"currency/USD\t.00"` (tabs not supported)
/// - ❌ Invalid: `"currency/USD\n.00"` (newlines not supported)
///
/// ## Example Usage
///
/// ```swift
/// let parser = SkeletonParser()
///
/// // Parse a simple skeleton
/// let options = try parser.parse("currency/USD .00")
/// // options.unit == .currency(code: "USD")
/// // options.precision == .fractionDigits(min: 2, max: 2)
///
/// // Parse a complex skeleton
/// let complex = try parser.parse("currency/EUR .00 sign-accounting group-auto")
/// // Multiple options combined
///
/// // Handle errors
/// do {
///     let invalid = try parser.parse("currency/INVALID")
/// } catch SkeletonParseError.invalidCurrencyCode(let code) {
///     print("Invalid currency: \(code)")
/// }
/// ```
///
/// ## Parser Validation
///
/// The parser includes robust validation:
/// - Empty value detection (e.g., `"scale/"` → `.invalidScale("")`)
/// - Integer width validation (must have at least one '0')
/// - Error message preservation (full token in errors)
/// - Token classification (intelligent pattern recognition)
/// - Component validation (non-empty measure unit parts)
///
/// ## Supported Tokens
///
/// See `ICUNumberSkeletonFormatStyle` documentation for a complete list of supported tokens.
public struct SkeletonParser: Sendable {

    /// Creates a new skeleton parser.
    public init() {}

    /// Parses a skeleton string into `SkeletonOptions`.
    ///
    /// This method tokenizes the skeleton string (splitting on spaces) and parses
    /// each token according to ICU Number Skeleton specification. Tokens are processed
    /// left to right, and later tokens can override earlier ones for conflicting options.
    ///
    /// ## Example
    /// ```swift
    /// let parser = SkeletonParser()
    ///
    /// // Simple parsing
    /// let options = try parser.parse("percent .0")
    /// // options.unit == .percent
    /// // options.precision == .fractionDigits(min: 1, max: 1)
    ///
    /// // Complex parsing with multiple options
    /// let complex = try parser.parse("""
    ///     currency/USD .00 rounding-mode-half-up sign-always
    /// """)
    /// ```
    ///
    /// - Parameter skeleton: The ICU number skeleton string to parse. Tokens must be separated by spaces.
    /// - Returns: The parsed options containing all formatting rules.
    /// - Throws: `SkeletonParseError` if the skeleton contains invalid tokens or malformed options.
    public func parse(_ skeleton: String) throws -> SkeletonOptions {
        var options = SkeletonOptions()

        let tokens = tokenize(skeleton)

        var index = 0
        while index < tokens.count {
            let token = tokens[index]
            index += 1

            try parseToken(token, into: &options)
        }

        return options
    }

    // MARK: - Tokenization

    private func tokenize(_ skeleton: String) -> [String] {
        // Skeleton tokens are separated by spaces (U+0020) per ICU specification
        // Tokens can contain slashes for options (e.g., "currency/USD")
        skeleton
            .trimmingCharacters(in: .whitespaces)
            .components(separatedBy: " ")
            .filter { !$0.isEmpty }
    }

    // MARK: - Token Parsing

    private func parseToken(_ token: String, into options: inout SkeletonOptions) throws {
        // Handle precision tokens (start with . or @)
        if token.hasPrefix(".") || token.hasPrefix("@") {
            try parsePrecision(token, into: &options)
            return
        }

        // Handle integer width tokens (start with # or 0)
        if token.first == "0" || token.first == "#" {
            // Check if it looks like an integer width pattern (only contains 0 and #)
            if token.allSatisfy({ $0 == "0" || $0 == "#" }) {
                try parseIntegerWidthShort(token, into: &options)
                return
            } else {
                // Starts with 0 or # but contains other characters - invalid integer width
                throw SkeletonParseError.invalidIntegerWidth(token)
            }
        }

        // Handle tokens with options (contain /)
        if token.contains("/") {
            try parseSlashToken(token, into: &options)
            return
        }

        // Handle keyword tokens
        try parseKeywordToken(token, into: &options)
    }

    // MARK: - Precision Parsing

    private func parsePrecision(_ token: String, into options: inout SkeletonOptions) throws {
        if token.hasPrefix("@") {
            // Significant digits precision
            try parseSignificantDigits(token, into: &options)
        } else if token.hasPrefix(".") {
            // Fraction digits precision
            try parseFractionDigits(token, into: &options)
        } else {
            throw SkeletonParseError.invalidPrecision(token)
        }
    }

    private func parseSignificantDigits(_ token: String, into options: inout SkeletonOptions) throws {
        var minSig = 0
        var maxSig = 0

        for char in token {
            switch char {
            case "@":
                minSig += 1
                maxSig += 1
            case "#":
                maxSig += 1
            default:
                throw SkeletonParseError.invalidPrecision(token)
            }
        }

        if minSig == 0 {
            throw SkeletonParseError.invalidPrecision(token)
        }

        options.precision = .significantDigits(min: minSig, max: maxSig)
    }

    private func parseFractionDigits(_ token: String, into options: inout SkeletonOptions) throws {
        // Remove the leading dot
        let digits = String(token.dropFirst())

        if digits.isEmpty {
            // Just "." means 0 fraction digits
            options.precision = .fractionDigits(min: 0, max: 0)
            return
        }

        var minFrac = 0
        var maxFrac = 0

        // Check for combined fraction/significant: .00/@@@
        if digits.contains("@") {
            do {
                try parseFractionSignificant(digits, into: &options)
            } catch SkeletonParseError.invalidPrecision {
                // Re-throw with the full token including the dot
                throw SkeletonParseError.invalidPrecision(token)
            }
            return
        }

        for char in digits {
            switch char {
            case "0":
                minFrac += 1
                maxFrac += 1
            case "#":
                maxFrac += 1
            case "*":
                // Unlimited precision
                options.precision = .unlimited
                return
            default:
                throw SkeletonParseError.invalidPrecision(token)
            }
        }

        options.precision = .fractionDigits(min: minFrac, max: maxFrac)
    }

    private func parseFractionSignificant(_ digits: String, into options: inout SkeletonOptions) throws {
        // Format: 00/@@@  or similar
        let parts = digits.split(separator: "/", maxSplits: 1, omittingEmptySubsequences: false)
        guard parts.count == 2 else {
            throw SkeletonParseError.invalidPrecision(digits)
        }

        var minFrac = 0
        var maxFrac = 0

        for char in parts[0] {
            switch char {
            case "0":
                minFrac += 1
                maxFrac += 1
            case "#":
                maxFrac += 1
            default:
                throw SkeletonParseError.invalidPrecision(digits)
            }
        }

        var minSig = 0
        var maxSig = 0

        for char in parts[1] {
            switch char {
            case "@":
                minSig += 1
                maxSig += 1
            case "#":
                maxSig += 1
            default:
                throw SkeletonParseError.invalidPrecision(digits)
            }
        }

        options.precision = .fractionSignificant(
            minFraction: minFrac,
            maxFraction: maxFrac,
            minSignificant: minSig,
            maxSignificant: maxSig
        )
    }

    private func parseIntegerWidthShort(_ token: String, into options: inout SkeletonOptions) throws {
        var minDigits = 0
        var maxDigits: Int? = nil
        var hasSeenZero = false

        for char in token {
            switch char {
            case "0":
                hasSeenZero = true
                minDigits += 1
                // Also increment max if we're tracking it
                if maxDigits != nil {
                    maxDigits! += 1
                }
            case "#":
                // Initialize maxDigits if this is the first # we've seen
                if maxDigits == nil {
                    maxDigits = minDigits
                }
                maxDigits! += 1
                // If we've already seen a 0, then # coming after is invalid
                if hasSeenZero {
                    throw SkeletonParseError.invalidIntegerWidth(token)
                }
            default:
                throw SkeletonParseError.invalidIntegerWidth(token)
            }
        }

        // Integer width must have at least one required digit (at least one '0')
        guard hasSeenZero else {
            throw SkeletonParseError.invalidIntegerWidth(token)
        }

        // If we never saw #, there's no maximum constraint
        if maxDigits == nil {
            maxDigits = nil
        }

        options.integerWidth = .init(minDigits: minDigits, maxDigits: maxDigits)
    }

    // MARK: - Slash Token Parsing

    private func parseSlashToken(_ token: String, into options: inout SkeletonOptions) throws {
        let parts = token.split(separator: "/", maxSplits: 1, omittingEmptySubsequences: false)
        guard parts.count == 2 else {
            throw SkeletonParseError.invalidToken(token)
        }

        let keyword = String(parts[0])
        let value = String(parts[1])

        switch keyword {
        case "currency":
            try parseCurrency(value, into: &options)
        case "measure-unit":
            try parseMeasureUnit(value, into: &options)
        case "integer-width":
            try parseIntegerWidth(value, into: &options)
        case "scale":
            try parseScale(value, into: &options)
        case "numbering-system":
            try parseNumberingSystem(value, into: &options)
        case "precision-increment":
            try parsePrecisionIncrement(value, into: &options)
        default:
            throw SkeletonParseError.invalidToken(token)
        }
    }

    private func parseCurrency(_ code: String, into options: inout SkeletonOptions) throws {
        // Currency code should be 3 uppercase letters
        guard code.count == 3, code.allSatisfy({ $0.isUppercase && $0.isLetter }) else {
            throw SkeletonParseError.invalidCurrencyCode(code)
        }
        options.unit = .currency(code: code)
    }

    private func parseMeasureUnit(_ unit: String, into options: inout SkeletonOptions) throws {
        // Format: type-subtype (e.g., length-meter)
        let parts = unit.split(separator: "-", maxSplits: 1, omittingEmptySubsequences: false)
        guard parts.count == 2 else {
            throw SkeletonParseError.invalidMeasureUnit(unit)
        }
        
        let type = String(parts[0])
        let subtype = String(parts[1])
        
        // Validate that neither part is empty
        guard !type.isEmpty, !subtype.isEmpty else {
            throw SkeletonParseError.invalidMeasureUnit(unit)
        }
        
        options.unit = .measureUnit(type: type, subtype: subtype)
    }

    private func parseIntegerWidth(_ value: String, into options: inout SkeletonOptions) throws {
        // Format: +000 (minimum with truncation) or 000 (minimum only) or ##00 (min and max)
        var workingValue = value
        var truncate = false

        if workingValue.hasPrefix("+") {
            truncate = true
            workingValue = String(workingValue.dropFirst())
        }

        var minDigits = 0
        var maxDigits: Int? = nil
        var inOptionalPart = true

        for char in workingValue {
            switch char {
            case "#":
                if !inOptionalPart {
                    throw SkeletonParseError.invalidIntegerWidth(value)
                }
                if maxDigits == nil {
                    maxDigits = 0
                }
                maxDigits! += 1
            case "0":
                inOptionalPart = false
                minDigits += 1
            default:
                throw SkeletonParseError.invalidIntegerWidth(value)
            }
        }

        // Integer width must have at least one required digit (at least one '0')
        guard minDigits > 0 else {
            throw SkeletonParseError.invalidIntegerWidth(value)
        }

        if truncate {
            // With +, we have a maximum equal to minDigits (truncate behavior)
            options.integerWidth = .init(minDigits: minDigits, maxDigits: minDigits)
        } else if let max = maxDigits {
            options.integerWidth = .init(minDigits: minDigits, maxDigits: max + minDigits)
        } else {
            options.integerWidth = .init(minDigits: minDigits, maxDigits: nil)
        }
    }

    private func parseScale(_ value: String, into options: inout SkeletonOptions) throws {
        guard let decimal = Decimal(string: value) else {
            throw SkeletonParseError.invalidScale(value)
        }
        options.scale = decimal
    }

    private func parseNumberingSystem(_ value: String, into options: inout SkeletonOptions) throws {
        guard !value.isEmpty else {
            throw SkeletonParseError.invalidNumberingSystem(value)
        }
        options.numberingSystem = value
    }

    private func parsePrecisionIncrement(_ value: String, into options: inout SkeletonOptions) throws {
        guard let decimal = Decimal(string: value) else {
            throw SkeletonParseError.invalidPrecision(value)
        }
        options.precision = .increment(value: decimal)
    }

    // MARK: - Keyword Token Parsing

    private func parseKeywordToken(_ token: String, into options: inout SkeletonOptions) throws {
        switch token {
        // Notation
        case "notation-simple", "simple":
            options.notation = .simple
        case "scientific":
            options.notation = .scientific
        case "engineering":
            options.notation = .engineering
        case "compact-short":
            options.notation = .compactShort
        case "compact-long":
            options.notation = .compactLong

        // Unit
        case "percent":
            options.unit = .percent
        case "permille":
            options.unit = .permille

        // Unit Width
        case "unit-width-narrow":
            options.unitWidth = .narrow
        case "unit-width-short":
            options.unitWidth = .short
        case "unit-width-full-name":
            options.unitWidth = .fullName
        case "unit-width-iso-code":
            options.unitWidth = .isoCode
        case "unit-width-formal":
            options.unitWidth = .formal
        case "unit-width-variant":
            options.unitWidth = .variant
        case "unit-width-hidden":
            options.unitWidth = .hidden

        // Precision
        case "precision-integer":
            options.precision = .integer
        case "precision-currency-standard":
            options.precision = .currencyStandard
        case "precision-currency-cash":
            options.precision = .currencyCash
        case "precision-unlimited":
            options.precision = .unlimited

        // Rounding Mode
        case "rounding-mode-ceiling":
            options.roundingMode = .ceiling
        case "rounding-mode-floor":
            options.roundingMode = .floor
        case "rounding-mode-down":
            options.roundingMode = .down
        case "rounding-mode-up":
            options.roundingMode = .up
        case "rounding-mode-half-even":
            options.roundingMode = .halfEven
        case "rounding-mode-half-down":
            options.roundingMode = .halfDown
        case "rounding-mode-half-up":
            options.roundingMode = .halfUp
        case "rounding-mode-unnecessary":
            options.roundingMode = .unnecessary

        // Grouping
        case "group-auto":
            options.grouping = .auto
        case "group-off":
            options.grouping = .off
        case "group-min2":
            options.grouping = .min2
        case "group-on-aligned":
            options.grouping = .onAligned

        // Sign Display
        case "sign-auto":
            options.signDisplay = .auto
        case "sign-always":
            options.signDisplay = .always
        case "sign-never":
            options.signDisplay = .never
        case "sign-accounting":
            options.signDisplay = .accounting
        case "sign-accounting-always":
            options.signDisplay = .accountingAlways
        case "sign-except-zero":
            options.signDisplay = .exceptZero
        case "sign-accounting-except-zero":
            options.signDisplay = .accountingExceptZero
        case "sign-negative":
            options.signDisplay = .negative

        // Decimal Separator
        case "decimal-auto":
            options.decimalSeparator = .auto
        case "decimal-always":
            options.decimalSeparator = .always

        // Latin digits
        case "latin":
            options.latinDigits = true

        default:
            throw SkeletonParseError.invalidToken(token)
        }
    }
}
