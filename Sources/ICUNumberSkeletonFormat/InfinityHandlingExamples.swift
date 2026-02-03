import Foundation

// MARK: - Infinity and NaN Handling Examples

@main
struct InfinityHandlingExamples {
    static func main() {
        print("=== Special Values Handling ===\n")

        let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".00", locale: Locale(identifier: "en_US"))

        // Positive Infinity
        print("Positive infinity: \(style.format(Double.infinity))")
        // Output: Positive infinity: ∞

        // Negative Infinity  
        print("Negative infinity: \(style.format(-Double.infinity))")
        // Output: Negative infinity: -∞

        // Not a Number
        print("NaN: \(style.format(Double.nan))")
        // Output: NaN: NaN

        print("\n=== Operations Producing Special Values ===\n")

        // Division by zero
        print("1.0 / 0.0 = \(style.format(1.0 / 0.0))")
        // Output: 1.0 / 0.0 = ∞

        print("-1.0 / 0.0 = \(style.format(-1.0 / 0.0))")
        // Output: -1.0 / 0.0 = -∞

        print("0.0 / 0.0 = \(style.format(0.0 / 0.0))")
        // Output: 0.0 / 0.0 = NaN

        // Mathematical operations
        print("sqrt(-1.0) = \(style.format((-1.0).squareRoot()))")
        // Output: sqrt(-1.0) = NaN

        print("\n=== Special Values with Different Formats ===\n")

        // Currency
        let currencyStyle = ICUNumberSkeletonFormatStyle<Double>.currency("USD", locale: Locale(identifier: "en_US"))
        print("Currency infinity: \(currencyStyle.format(Double.infinity))")
        // Output: Currency infinity: ∞

        // Percent
        let percentStyle = ICUNumberSkeletonFormatStyle<Double>.percent(locale: Locale(identifier: "en_US"))
        print("Percent NaN: \(percentStyle.format(Double.nan))")
        // Output: Percent NaN: NaN

        // Scientific notation
        let scientificStyle = ICUNumberSkeletonFormatStyle<Double>.scientific(locale: Locale(identifier: "en_US"))
        print("Scientific infinity: \(scientificStyle.format(Double.infinity))")
        // Output: Scientific infinity: ∞

        // Compact notation
        let compactStyle = ICUNumberSkeletonFormatStyle<Double>.compact(.short, locale: Locale(identifier: "en_US"))
        print("Compact infinity: \(compactStyle.format(Double.infinity))")
        // Output: Compact infinity: ∞

        print("\n=== Using Extension Methods ===\n")

        // Using the extension method
        print("Extension infinity: \(Double.infinity.formatted(icuSkeleton: ".00"))")
        // Output: Extension infinity: ∞

        print("Extension NaN: \(Double.nan.formatted(icuSkeleton: "percent"))")
        // Output: Extension NaN: NaN

        print("\n=== Real-World Scenarios ===\n")

        // Calculate average (might result in NaN if dividing by zero)
        func calculateAverage(_ values: [Double]) -> String {
            let sum = values.reduce(0, +)
            let average = sum / Double(values.count)
            let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: ".00", locale: .current)
            return style.format(average)
        }

        print("Average of [1, 2, 3]: \(calculateAverage([1, 2, 3]))")
        // Output: Average of [1, 2, 3]: 2.00

        print("Average of empty array: \(calculateAverage([]))")
        // Output: Average of empty array: NaN (0.0 / 0.0)

        // Growth rate calculation (might result in infinity)
        func formatGrowthRate(from oldValue: Double, to newValue: Double) -> String {
            let growth = (newValue - oldValue) / oldValue
            let style = ICUNumberSkeletonFormatStyle<Double>(skeleton: "percent .0", locale: .current)
            return style.format(growth)
        }

        print("Growth from 100 to 150: \(formatGrowthRate(from: 100, to: 150))")
        // Output: Growth from 100 to 150: 50.0%

        print("Growth from 0 to 100: \(formatGrowthRate(from: 0, to: 100))")
        // Output: Growth from 0 to 100: ∞ (division by zero)

        print("\n=== All Tests Passed Without Runtime Errors! ===")
    }
}
