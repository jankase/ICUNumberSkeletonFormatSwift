import Foundation

/// Helper for applying integer width formatting.
public enum IntegerWidthHelper {

    /// Applies integer width padding and truncation to a formatted string.
    /// - Parameters:
    ///   - formattedString: The already formatted number string.
    ///   - integerWidth: The integer width specification.
    ///   - options: The skeleton options for grouping settings.
    ///   - locale: The locale for formatting.
    /// - Returns: The string with integer width applied.
    public static func apply(
        to formattedString: String,
        integerWidth: SkeletonOptions.IntegerWidth,
        options: SkeletonOptions,
        locale: Locale
    ) -> String {
        let decimalSeparator = Locale.current.decimalSeparator ?? "."
        let parts = formattedString.components(separatedBy: decimalSeparator)

        guard let integerPart = parts.first else { return formattedString }
        let fractionalPart = parts.count > 1 ? parts[1] : nil

        let groupingSeparator = locale.groupingSeparator ?? ","
        let sign = extractSign(from: integerPart)
        var digitsOnly = integerPart.filter { $0.isNumber }

        // Apply minimum width (pad with zeros)
        while digitsOnly.count < integerWidth.minDigits {
            digitsOnly = "0" + digitsOnly
        }

        // Apply maximum width (truncate from left) if specified
        if let maxDigits = integerWidth.maxDigits, digitsOnly.count > maxDigits {
            digitsOnly = String(digitsOnly.suffix(maxDigits))
        }

        // Re-apply grouping if not disabled
        let formatted = applyGrouping(
            to: digitsOnly,
            separator: groupingSeparator,
            groupingEnabled: options.grouping != .off
        )

        // Reconstruct the full number
        var result = sign + formatted
        if let frac = fractionalPart {
            result += decimalSeparator + frac
        }

        return result
    }

    // MARK: - Private Helpers

    private static func extractSign(from integerPart: String) -> String {
        if let first = integerPart.first, first == "-" || first == "+" {
            return String(first)
        }
        return ""
    }

    private static func applyGrouping(to digits: String, separator: String, groupingEnabled: Bool) -> String {
        guard groupingEnabled else { return digits }

        var formatted = ""
        let reversedDigits = String(digits.reversed())

        for (index, char) in reversedDigits.enumerated() {
            if index > 0 && index % 3 == 0 {
                formatted = separator + formatted
            }
            formatted = String(char) + formatted
        }

        return formatted
    }
}
