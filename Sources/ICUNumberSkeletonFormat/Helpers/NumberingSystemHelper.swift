import Foundation

/// Helper for applying numbering system options to locales.
public enum NumberingSystemHelper {

    /// Applies the numbering system from options to the given locale.
    /// - Parameters:
    ///   - locale: The base locale.
    ///   - options: The skeleton options containing numbering system settings.
    /// - Returns: A locale with the appropriate numbering system applied.
    public static func applyNumberingSystem(to locale: Locale, options: SkeletonOptions) -> Locale {
        if let system = options.numberingSystem {
            var components = Locale.Components(locale: locale)
            components.numberingSystem = Locale.NumberingSystem(system)
            return Locale(components: components)
        }

        if options.latinDigits {
            var components = Locale.Components(locale: locale)
            components.numberingSystem = Locale.NumberingSystem("latn")
            return Locale(components: components)
        }

        return locale
    }
}
