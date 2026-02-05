import Foundation
import ICUNumberSkeletonFormat

print(String(repeating: "=", count: 80))
print("ICU Number Skeleton Format Style - Demonstrations")
print(String(repeating: "=", count: 80))

print("\n📊 1. BASIC FORMATTING")
print(String(repeating: "-", count: 80))

let number = 1234.5678
print("Original number: \(number)")
print("Default format: \(number.formatted())")
print("With .formatted(icuSkeleton:):")
print("  '.00' → \(number.formatted(icuSkeleton: ".00"))")
print("  '.0#' → \(number.formatted(icuSkeleton: ".0#"))")
print("  '.####' → \(number.formatted(icuSkeleton: ".####"))")

print("\n💵 2. CURRENCY FORMATTING")
print(String(repeating: "-", count: 80))

let price = 1234.56
print("Price: \(price)")
print("\nBasic currency:")
print("  USD: \(price.formatted(icuSkeleton: "currency/USD .00"))")
print("  EUR: \(price.formatted(icuSkeleton: "currency/EUR .00"))")
print("  GBP: \(price.formatted(icuSkeleton: "currency/GBP .00"))")
print("  JPY: \(price.formatted(icuSkeleton: "currency/JPY precision-integer"))")

print("\nCurrency with different unit widths:")
print("  Narrow:    \(price.formatted(icuSkeleton: "currency/USD unit-width-narrow .00"))")
print("  Short:     \(price.formatted(icuSkeleton: "currency/USD unit-width-short .00"))")
print("  ISO code:  \(price.formatted(icuSkeleton: "currency/USD unit-width-iso-code .00"))")
print("  Full name: \(price.formatted(icuSkeleton: "currency/USD unit-width-full-name .00"))")
print("  Hidden:    \(price.formatted(icuSkeleton: "currency/USD unit-width-hidden .00"))")

let euroStyle = ICUNumberSkeletonFormatStyle<Double>(
    skeleton: "currency/EUR .00",
    locale: Locale(identifier: "de_DE")
)
print("\nGerman locale EUR: \(euroStyle.format(price))")

let japanStyle = ICUNumberSkeletonFormatStyle<Double>(
    skeleton: "currency/JPY precision-integer",
    locale: Locale(identifier: "ja_JP")
)
print("Japanese locale JPY: \(japanStyle.format(price))")

print("\n📈 3. PERCENT & PERMILLE")
print(String(repeating: "-", count: 80))

let ratio = 0.2567
print("Ratio: \(ratio)")
print("\nPercent formatting:")
print("  Basic percent: \(ratio.formatted(icuSkeleton: "percent"))")
print("  With scale:    \(ratio.formatted(icuSkeleton: "percent scale/100"))")
print("  With precision: \(ratio.formatted(icuSkeleton: "percent scale/100 .00"))")
print("  Integer only:   \(ratio.formatted(icuSkeleton: "percent scale/100 precision-integer"))")

let permilleValue = 0.0234
print("\nPermille formatting:")
print("  Basic permille: \(permilleValue.formatted(icuSkeleton: "permille"))")
print("  With scale:     \(permilleValue.formatted(icuSkeleton: "permille scale/1000"))")
print("  With precision: \(permilleValue.formatted(icuSkeleton: "permille scale/1000 .00"))")

print("\n🎯 4. PRECISION CONTROL")
print(String(repeating: "-", count: 80))

let precisionNumber = 1234.5678
print("Number: \(precisionNumber)")
print("\nFraction digits (dot notation):")
print("  .00 (exactly 2):    \(precisionNumber.formatted(icuSkeleton: ".00"))")
print("  .0# (1-2 digits):   \(precisionNumber.formatted(icuSkeleton: ".0#"))")
print("  .0## (1-3 digits):  \(precisionNumber.formatted(icuSkeleton: ".0##"))")
print("  .## (0-2 digits):   \(precisionNumber.formatted(icuSkeleton: ".##"))")
print("  .#### (0-4 digits): \(precisionNumber.formatted(icuSkeleton: ".####"))")

print("\nSignificant digits (@ notation):")
let sigNumber = 12345.678
print("Number: \(sigNumber)")
print("  @ (1 sig digit):     \(sigNumber.formatted(icuSkeleton: "@"))")
print("  @@ (2 sig digits):   \(sigNumber.formatted(icuSkeleton: "@@"))")
print("  @@@ (3 sig digits):  \(sigNumber.formatted(icuSkeleton: "@@@"))")
print("  @@@@ (4 sig digits): \(sigNumber.formatted(icuSkeleton: "@@@@"))")
print("  @@## (2-4 sig):      \(sigNumber.formatted(icuSkeleton: "@@##"))")

print("\nPrecision keywords:")
print("  precision-integer:   \(precisionNumber.formatted(icuSkeleton: "precision-integer"))")
print("  precision-unlimited: \(precisionNumber.formatted(icuSkeleton: "precision-unlimited"))")

print("\nIncrement rounding:")
let incrementNumber = 1.234
print("Number: \(incrementNumber)")
print("  Round to 0.05: \(incrementNumber.formatted(icuSkeleton: "precision-increment/0.05"))")
print("  Round to 0.25: \(incrementNumber.formatted(icuSkeleton: "precision-increment/0.25"))")
print("  Round to 0.1:  \(incrementNumber.formatted(icuSkeleton: "precision-increment/0.1"))")

print("\n📐 5. NOTATION STYLES")
print(String(repeating: "-", count: 80))

let largeNumber = 1234567.89
let smallNumber = 0.0001234
print("Large number: \(largeNumber)")
print("\nNotation types:")
print("  Simple:        \(largeNumber.formatted(icuSkeleton: "notation-simple"))")
print("  Scientific:    \(largeNumber.formatted(icuSkeleton: "scientific"))")
print("  Engineering:   \(largeNumber.formatted(icuSkeleton: "engineering"))")
print("  Compact-short: \(largeNumber.formatted(icuSkeleton: "compact-short"))")
print("  Compact-long:  \(largeNumber.formatted(icuSkeleton: "compact-long"))")

print("\nSmall number: \(smallNumber)")
print("  Scientific:    \(smallNumber.formatted(icuSkeleton: "scientific"))")
print("  Engineering:   \(smallNumber.formatted(icuSkeleton: "engineering"))")

let compactNumbers = [1_500.0, 12_000.0, 1_500_000.0, 2_300_000_000.0]
print("\nCompact notation examples:")
for num in compactNumbers {
    print("  \(num) → short: \(num.formatted(icuSkeleton: "compact-short")), long: \(num.formatted(icuSkeleton: "compact-long"))")
}

print("\n🔄 6. ROUNDING MODES")
print(String(repeating: "-", count: 80))

let roundingTests = [2.5, 3.5, 2.4, 2.6, -2.5]
print("Testing with numbers: \(roundingTests)")
print("\nRounding to integer:")
for mode in ["ceiling", "floor", "down", "up", "half-even", "half-down", "half-up"] {
    let skeleton = "precision-integer rounding-mode-\(mode)"
    print("  \(mode.padding(toLength: 12, withPad: " ", startingAt: 0)): ", terminator: "")
    print(roundingTests.map { $0.formatted(icuSkeleton: skeleton) }.joined(separator: ", "))
}

print("\nRounding with 1 decimal place:")
let decimalTests = [2.45, 2.55, 2.44, 2.46]
print("Testing with: \(decimalTests)")
for mode in ["half-even", "half-up", "half-down"] {
    let skeleton = ".0 rounding-mode-\(mode)"
    print("  \(mode.padding(toLength: 12, withPad: " ", startingAt: 0)): ", terminator: "")
    print(decimalTests.map { $0.formatted(icuSkeleton: skeleton) }.joined(separator: ", "))
}

print("\n➕ 7. SIGN DISPLAY")
print(String(repeating: "-", count: 80))

let signTests = [42.0, -42.0, 0.0]
print("Testing with numbers: \(signTests)")
print("\nSign display options:")
let signModes: [(String, String)] = [
    ("auto", "sign-auto"),
    ("always", "sign-always"),
    ("never", "sign-never"),
    ("except-zero", "sign-except-zero"),
    ("accounting", "currency/USD sign-accounting"),
    ("acct-always", "currency/USD sign-accounting-always")
]
for (name, skeleton) in signModes {
    print("  \(name.padding(toLength: 12, withPad: " ", startingAt: 0)): ", terminator: "")
    print(signTests.map { $0.formatted(icuSkeleton: skeleton) }.joined(separator: " | "))
}

print("\n🔢 8. GROUPING")
print(String(repeating: "-", count: 80))

let groupingNumber = 1234567.89
print("Number: \(groupingNumber)")
print("\nGrouping options:")
print("  auto (default): \(groupingNumber.formatted(icuSkeleton: "group-auto"))")
print("  off:            \(groupingNumber.formatted(icuSkeleton: "group-off"))")
print("  min2:           \(groupingNumber.formatted(icuSkeleton: "group-min2"))")
print("  on-aligned:     \(groupingNumber.formatted(icuSkeleton: "group-on-aligned"))")

print("\nSmaller numbers:")
for num in [1234.56, 123.45, 12.34] {
    print("  \(num): auto=\(num.formatted(icuSkeleton: "group-auto")), off=\(num.formatted(icuSkeleton: "group-off"))")
}

print("\n📏 9. INTEGER WIDTH")
print(String(repeating: "-", count: 80))

let widthTests = [5.0, 42.0, 123.0, 1234.0, 12345.0]
print("Testing with: \(widthTests)")
print("\nInteger width padding:")
print("  000 (min 3 digits):         ", terminator: "")
print(widthTests.map { $0.formatted(icuSkeleton: "integer-width/000") }.joined(separator: ", "))
print("  00000 (min 5 digits):       ", terminator: "")
print(widthTests.map { $0.formatted(icuSkeleton: "integer-width/00000") }.joined(separator: ", "))
print("\nInteger width with truncation:")
print("  +000 (exactly 3 digits):    ", terminator: "")
print(widthTests.map { $0.formatted(icuSkeleton: "integer-width/+000") }.joined(separator: ", "))
print("  ##00 (min 2, max 4 digits): ", terminator: "")
print(widthTests.map { $0.formatted(icuSkeleton: "integer-width/##00") }.joined(separator: ", "))

print("\n⚖️ 10. SCALE")
print(String(repeating: "-", count: 80))

let scaleNumber = 0.5
print("Number: \(scaleNumber)")
print("\nScale multiplication:")
print("  scale/100:   \(scaleNumber.formatted(icuSkeleton: "scale/100"))")
print("  scale/1000:  \(scaleNumber.formatted(icuSkeleton: "scale/1000"))")
print("  scale/10:    \(scaleNumber.formatted(icuSkeleton: "scale/10"))")
print("  scale/0.01:  \(scaleNumber.formatted(icuSkeleton: "scale/0.01"))")

print("\nPractical use cases:")
print("  Basis points (x10000): \(0.0234.formatted(icuSkeleton: "scale/10000 .00")) bp")
print("  Manual percent (x100): \(0.456.formatted(icuSkeleton: "scale/100 .00"))%")
print("  PPM (x1000000):        \(0.000123.formatted(icuSkeleton: "scale/1000000 .0")) ppm")

print("\n🔘 11. DECIMAL SEPARATOR")
print(String(repeating: "-", count: 80))

let decimalTests2 = [42.0, 42.5, 42.567]
print("Testing with: \(decimalTests2)")
print("\nDecimal separator display:")
print("  auto (default): ", terminator: "")
print(decimalTests2.map { $0.formatted(icuSkeleton: "decimal-auto .0#") }.joined(separator: ", "))
print("  always:         ", terminator: "")
print(decimalTests2.map { $0.formatted(icuSkeleton: "decimal-always .0#") }.joined(separator: ", "))

print("\n🌍 12. NUMBERING SYSTEMS")
print(String(repeating: "-", count: 80))

let numberingTest = 12345.67
print("Number: \(numberingTest)")
print("\nDifferent numbering systems:")
print("  Latin (default): \(numberingTest.formatted(icuSkeleton: "numbering-system/latn .00"))")
print("  Latin shorthand: \(numberingTest.formatted(icuSkeleton: "latin .00"))")
let arabicLocale = Locale(identifier: "ar")
let arabicStyle = ICUNumberSkeletonFormatStyle<Double>(
    skeleton: "numbering-system/arab .00",
    locale: arabicLocale
)
print("  Arabic-Indic:    \(arabicStyle.format(numberingTest))")

print("\n🎨 13. COMPLEX COMBINATIONS")
print(String(repeating: "-", count: 80))

print("Combining multiple options for real-world use cases:\n")
let financialValue = 1234567.89
print("Financial Report - USD:")
let financeStyle = "currency/USD .00 group-auto sign-accounting"
print("  Positive: \(financialValue.formatted(icuSkeleton: financeStyle))")
print("  Negative: \((-financialValue).formatted(icuSkeleton: financeStyle))")

let euroValue = 1234.56
let euroGermanStyle = ICUNumberSkeletonFormatStyle<Double>(
    skeleton: "currency/EUR .00 sign-always",
    locale: Locale(identifier: "de_DE")
)
print("\nEuropean Format (German) with always-show sign:")
print("  \(euroGermanStyle.format(euroValue))")
print("  \(euroGermanStyle.format(-euroValue))")

let scientificValue = 0.0001234567
print("\nScientific with 3 significant digits:")
print("  \(scientificValue.formatted(icuSkeleton: "scientific @@@ sign-always"))")

let compactValue = 1_500_000.0
print("\nCompact currency notation:")
print("  Short: \(compactValue.formatted(icuSkeleton: "compact-short currency/USD"))")
print("  Long:  \(compactValue.formatted(icuSkeleton: "compact-long currency/USD"))")

let percentValue = -0.0567
print("\nPercentage with accounting format:")
print("  \(percentValue.formatted(icuSkeleton: "percent scale/100 .00 sign-accounting"))")

let idNumber = 42.0
print("\nZero-padded ID numbers:")
print("  ID-\(idNumber.formatted(icuSkeleton: "integer-width/00000 group-off"))")

let basisPoints = 0.0234
print("\nBasis points (1/100th of a percent):")
print("  \(basisPoints.formatted(icuSkeleton: "scale/10000 .00")) bp")

let cashValue = 12.47
print("\nCash rounding to nearest 5 cents:")
print("  $\(cashValue) → \(cashValue.formatted(icuSkeleton: "currency/USD precision-increment/0.05"))")

let bigNumber = 987_654_321.123_456
print("\nLarge number with various formats:")
print("  Scientific: \(bigNumber.formatted(icuSkeleton: "scientific @@@@"))")
print("  Engineering: \(bigNumber.formatted(icuSkeleton: "engineering @@@@"))")
print("  Compact: \(bigNumber.formatted(icuSkeleton: "compact-short .00"))")
print("  No grouping: \(bigNumber.formatted(icuSkeleton: "group-off .00"))")

print("\n⚠️ 14. SPECIAL VALUES")
print(String(repeating: "-", count: 80))

print("Handling special floating-point values:")
print("  Infinity:  \(Double.infinity.formatted(icuSkeleton: "currency/USD"))")
print("  -Infinity: \((-Double.infinity).formatted(icuSkeleton: "currency/USD"))")
print("  NaN:       \(Double.nan.formatted(icuSkeleton: "currency/USD"))")

print(String(repeating: "=", count: 80))
print("SUMMARY")
print(String(repeating: "=", count: 80))

print("""

Key Takeaways:
• Skeleton strings use space-separated tokens
• Options can be freely combined for complex formatting
• Locale affects grouping, decimal separator, and symbols
• Precision tokens: . for fraction digits, @ for significant digits
• Scale multiplies before formatting (useful for percentages, basis points)
• Sign display controls +/- appearance
• Rounding modes provide fine control over rounding behavior
Common Patterns:
• Currency:   "currency/USD .00"
• Percentage:  "percent scale/100 .00"
• Scientific:  "scientific @@@"
• Compact:     "compact-short"
• Financial:   "currency/USD sign-accounting .00"
• No grouping: "group-off"

For more information, see:
• README.md in the package
• ICU Number Skeletons: https://unicode-org.github.io/icu/userguide/format_parse/numbers/skeletons.html

""")

