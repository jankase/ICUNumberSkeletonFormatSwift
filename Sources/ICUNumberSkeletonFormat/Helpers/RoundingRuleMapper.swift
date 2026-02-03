import Foundation

/// Maps ICU rounding modes to Foundation rounding rules.
public enum RoundingRuleMapper {

    /// Maps a skeleton rounding mode to a FloatingPointRoundingRule.
    /// - Parameter mode: The skeleton rounding mode.
    /// - Returns: The corresponding FloatingPointRoundingRule.
    public static func map(_ mode: SkeletonOptions.RoundingMode) -> FloatingPointRoundingRule {
        switch mode {
        case .ceiling:
            return .up
        case .floor:
            return .down
        case .down:
            return .towardZero
        case .up:
            return .awayFromZero
        case .halfEven:
            return .toNearestOrEven
        case .halfDown:
            return .toNearestOrEven
        case .halfUp:
            return .toNearestOrAwayFromZero
        case .unnecessary:
            return .toNearestOrEven
        }
    }

    /// Maps a skeleton rounding mode to a NumberFormatter.RoundingMode.
    /// - Parameter mode: The skeleton rounding mode.
    /// - Returns: The corresponding NumberFormatter.RoundingMode.
    public static func numberFormatterMode(_ mode: SkeletonOptions.RoundingMode) -> NumberFormatter.RoundingMode {
        switch mode {
        case .ceiling:
            return .ceiling
        case .floor:
            return .floor
        case .down:
            return .down
        case .up:
            return .up
        case .halfEven:
            return .halfEven
        case .halfDown:
            return .halfDown
        case .halfUp:
            return .halfUp
        case .unnecessary:
            return .halfEven
        }
    }
}
