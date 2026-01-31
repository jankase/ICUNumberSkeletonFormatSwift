# ICUNumberSkeletonFormat

A Swift package that provides number formatting using ICU Number Skeleton syntax. This package allows you to use compact, locale-independent skeleton strings to configure number formatting across all Apple platforms.

## Features

- Parse and apply ICU Number Skeleton format strings
- Support for all Apple platforms (iOS, macOS, tvOS, watchOS, visionOS)
- Comprehensive formatting options including:
  - Notation styles (simple, scientific, engineering, compact)
  - Currency and unit formatting
  - Precision control (fraction digits, significant digits)
  - Rounding modes
  - Grouping separators
  - Sign display options
  - Decimal separator control
- Thread-safe `Sendable` types
- Swift 5.9+ with strict concurrency support

## Requirements

- Swift 5.9+
- iOS 17.0+ / macOS 14.0+ / tvOS 17.0+ / watchOS 10.0+ / visionOS 1.0+

## Installation

### Swift Package Manager

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/jankase/ICUNumberSkeletonFormatSwift.git", from: "1.0.0")
]
```

Or add it via Xcode:
1. File → Add Package Dependencies...
2. Enter the repository URL
3. Select the version rule

## Usage

### Basic Usage

```swift
import ICUNumberSkeletonFormat

// Create a formatter with a skeleton string
let formatter = try ICUNumberSkeletonFormat(skeleton: "currency/USD .00")
let formatted = formatter.format(1234.5) // "$1,234.50"

// Format with different number types
formatter.format(42)              // Integer
formatter.format(3.14159)         // Double
formatter.format(Decimal("99.99")) // Decimal
```

### Currency Formatting

```swift
// Using skeleton string
let usdFormatter = try ICUNumberSkeletonFormat(skeleton: "currency/USD .00")
usdFormatter.format(1234.56) // "$1,234.56"

// Using convenience method
let euroFormatter = try ICUNumberSkeletonFormat.currency("EUR", locale: Locale(identifier: "de_DE"))
euroFormatter.format(1234.56) // "1.234,56 €"

// With unit width options
let formatter = try ICUNumberSkeletonFormat(skeleton: "currency/USD unit-width-iso-code")
formatter.format(100) // "USD 100.00"
```

### Percent Formatting

```swift
let percentFormatter = try ICUNumberSkeletonFormat(skeleton: "percent")
percentFormatter.format(0.25) // "25%"

// Or use the convenience method
let formatter = try ICUNumberSkeletonFormat.percent()
formatter.format(0.5) // "50%"
```

### Scientific Notation

```swift
let scientificFormatter = try ICUNumberSkeletonFormat(skeleton: "scientific")
scientificFormatter.format(12345.0) // "1.2345E4"

// Or use the convenience method
let formatter = try ICUNumberSkeletonFormat.scientific()
```

### Compact Notation

```swift
// Short compact notation (1K, 1M, etc.)
let shortFormatter = try ICUNumberSkeletonFormat(skeleton: "compact-short")
shortFormatter.format(1500) // "1.5K"

// Long compact notation (1 thousand, etc.)
let longFormatter = try ICUNumberSkeletonFormat(skeleton: "compact-long")
longFormatter.format(1500) // "1.5 thousand"
```

### Precision Control

```swift
// Exactly 2 fraction digits
let exact = try ICUNumberSkeletonFormat(skeleton: ".00")
exact.format(1.5) // "1.50"

// 1-2 fraction digits
let range = try ICUNumberSkeletonFormat(skeleton: ".0#")
range.format(1.5) // "1.5"
range.format(1.56) // "1.56"

// Significant digits
let sigDigits = try ICUNumberSkeletonFormat(skeleton: "@@@")
sigDigits.format(12345) // "12,300" (3 significant digits)

// Integer precision
let integer = try ICUNumberSkeletonFormat(skeleton: "precision-integer")
integer.format(1.9) // "2"
```

### Rounding Modes

```swift
// Round toward positive infinity
let ceiling = try ICUNumberSkeletonFormat(skeleton: "precision-integer rounding-mode-ceiling")
ceiling.format(1.1) // "2"

// Round toward negative infinity
let floor = try ICUNumberSkeletonFormat(skeleton: "precision-integer rounding-mode-floor")
floor.format(1.9) // "1"

// Banker's rounding (half-even)
let halfEven = try ICUNumberSkeletonFormat(skeleton: "precision-integer rounding-mode-half-even")
halfEven.format(2.5) // "2"
halfEven.format(3.5) // "4"
```

### Grouping Control

```swift
// No grouping separators
let noGroup = try ICUNumberSkeletonFormat(skeleton: "group-off")
noGroup.format(1234567) // "1234567"

// Auto grouping (locale-dependent)
let autoGroup = try ICUNumberSkeletonFormat(skeleton: "group-auto")
autoGroup.format(1234567) // "1,234,567"
```

### Sign Display

```swift
// Always show sign
let alwaysSign = try ICUNumberSkeletonFormat(skeleton: "sign-always")
alwaysSign.format(123) // "+123"

// Never show sign
let neverSign = try ICUNumberSkeletonFormat(skeleton: "sign-never")
neverSign.format(-123) // "123"

// Accounting format (parentheses for negative)
let accounting = try ICUNumberSkeletonFormat(skeleton: "currency/USD sign-accounting")
accounting.format(-100) // "($100.00)"
```

### Scale

```swift
// Multiply by 100 (useful for basis points or manual percent)
let scaled = try ICUNumberSkeletonFormat(skeleton: "scale/100")
scaled.format(0.5) // "50"
```

### Integer Width

```swift
// Minimum 3 integer digits (zero-padded)
let padded = try ICUNumberSkeletonFormat(skeleton: "integer-width/000")
padded.format(5) // "005"
```

### Combining Options

```swift
// Complex skeleton with multiple options
let formatter = try ICUNumberSkeletonFormat(
    skeleton: "currency/EUR .00 group-auto sign-always rounding-mode-half-up",
    locale: Locale(identifier: "de_DE")
)
formatter.format(1234.555) // "+1.234,56 €"
```

### Using Pre-parsed Options

```swift
// Build options programmatically
var options = SkeletonOptions()
options.precision = .fractionDigits(min: 2, max: 2)
options.grouping = .off
options.signDisplay = .always

let formatter = ICUNumberSkeletonFormat(options: options)
formatter.format(1234.5) // "+1234.50"
```

## Skeleton Syntax Reference

### Notation
| Token | Description |
|-------|-------------|
| `notation-simple` or `simple` | Standard decimal notation |
| `scientific` | Scientific notation (e.g., 1.23E4) |
| `engineering` | Engineering notation (exponents are multiples of 3) |
| `compact-short` | Compact notation with short form (e.g., 1K) |
| `compact-long` | Compact notation with long form (e.g., 1 thousand) |

### Units
| Token | Description |
|-------|-------------|
| `percent` | Format as percentage |
| `permille` | Format as permille (‰) |
| `currency/XXX` | Format as currency (e.g., `currency/USD`) |
| `measure-unit/type-subtype` | Format with measure unit |

### Unit Width
| Token | Description |
|-------|-------------|
| `unit-width-narrow` | Narrowest representation |
| `unit-width-short` | Short representation |
| `unit-width-full-name` | Full name (e.g., "US dollars") |
| `unit-width-iso-code` | ISO code (e.g., "USD") |
| `unit-width-hidden` | Hide the unit |

### Precision
| Token | Description |
|-------|-------------|
| `.00` | Exactly 2 fraction digits |
| `.0#` | 1-2 fraction digits |
| `.##` | 0-2 fraction digits |
| `@@@` | 3 significant digits |
| `@@##` | 2-4 significant digits |
| `precision-integer` | No fraction digits |
| `precision-unlimited` | Maximum precision |
| `precision-increment/0.05` | Round to increment |

### Rounding Mode
| Token | Description |
|-------|-------------|
| `rounding-mode-ceiling` | Round toward positive infinity |
| `rounding-mode-floor` | Round toward negative infinity |
| `rounding-mode-down` | Round toward zero |
| `rounding-mode-up` | Round away from zero |
| `rounding-mode-half-even` | Round to nearest, ties to even |
| `rounding-mode-half-down` | Round to nearest, ties toward zero |
| `rounding-mode-half-up` | Round to nearest, ties away from zero |

### Integer Width
| Token | Description |
|-------|-------------|
| `integer-width/+000` | Minimum 3 digits, truncate if necessary |
| `integer-width/000` | Minimum 3 digits |
| `integer-width/##00` | Minimum 2 digits, maximum 4 |

### Scale
| Token | Description |
|-------|-------------|
| `scale/100` | Multiply by 100 before formatting |
| `scale/0.01` | Multiply by 0.01 before formatting |

### Grouping
| Token | Description |
|-------|-------------|
| `group-auto` | Locale-dependent grouping |
| `group-off` | No grouping separators |
| `group-min2` | Only group if 2+ digits in group |
| `group-on-aligned` | Grouping for alignment |

### Sign Display
| Token | Description |
|-------|-------------|
| `sign-auto` | Show minus sign for negative only |
| `sign-always` | Always show sign |
| `sign-never` | Never show sign |
| `sign-accounting` | Use accounting format for negatives |
| `sign-accounting-always` | Accounting format, always show sign |
| `sign-except-zero` | Show sign except for zero |

### Decimal Separator
| Token | Description |
|-------|-------------|
| `decimal-auto` | Show decimal separator only if needed |
| `decimal-always` | Always show decimal separator |

### Numbering System
| Token | Description |
|-------|-------------|
| `numbering-system/latn` | Use Latin digits |
| `numbering-system/arab` | Use Arabic-Indic digits |
| `latin` | Shorthand for Latin digits |

## License

MIT License - see [LICENSE](LICENSE) for details.

## References

- [ICU Number Skeletons](https://unicode-org.github.io/icu/userguide/format_parse/numbers/skeletons.html)
- [Unicode Technical Standard #35](https://www.unicode.org/reports/tr35/tr35-numbers.html)
