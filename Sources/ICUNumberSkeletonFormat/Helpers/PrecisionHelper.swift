import Foundation

/// Helper for precision-related calculations.
public enum PrecisionHelper {

    /// Calculates the number of decimal places in a Decimal value.
    /// - Parameter decimal: The decimal value to analyze.
    /// - Returns: The number of decimal places.
    public static func numberOfDecimalPlaces(in decimal: Decimal) -> Int {
        let nsDecimal = NSDecimalNumber(decimal: decimal)
        let string = nsDecimal.stringValue

        if let dotIndex = string.firstIndex(of: ".") {
            return string.distance(from: string.index(after: dotIndex), to: string.endIndex)
        }

        return 0
    }
}
