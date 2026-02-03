import Foundation

/// Maps ICU measure unit type-subtype pairs to Foundation Dimension units.
public enum MeasureUnitMapping {

    /// Returns the Foundation Dimension for the given ICU measure unit type and subtype.
    /// - Parameters:
    ///   - type: The unit type (e.g., "length", "mass", "temperature").
    ///   - subtype: The unit subtype (e.g., "meter", "kilogram", "celsius").
    /// - Returns: The corresponding Foundation Dimension, or nil if not supported.
    public static func unit(forType type: String, subtype: String) -> Dimension? {
        switch type {
        case "length":
            return lengthUnit(for: subtype)
        case "mass":
            return massUnit(for: subtype)
        case "duration":
            return durationUnit(for: subtype)
        case "temperature":
            return temperatureUnit(for: subtype)
        case "volume":
            return volumeUnit(for: subtype)
        case "speed":
            return speedUnit(for: subtype)
        case "area":
            return areaUnit(for: subtype)
        default:
            return nil
        }
    }

    // MARK: - Length Units

    private static func lengthUnit(for subtype: String) -> UnitLength? {
        switch subtype {
        case "meter": return .meters
        case "kilometer": return .kilometers
        case "centimeter": return .centimeters
        case "millimeter": return .millimeters
        case "mile": return .miles
        case "yard": return .yards
        case "foot": return .feet
        case "inch": return .inches
        default: return nil
        }
    }

    // MARK: - Mass Units

    private static func massUnit(for subtype: String) -> UnitMass? {
        switch subtype {
        case "kilogram": return .kilograms
        case "gram": return .grams
        case "milligram": return .milligrams
        case "pound": return .pounds
        case "ounce": return .ounces
        default: return nil
        }
    }

    // MARK: - Duration Units

    private static func durationUnit(for subtype: String) -> UnitDuration? {
        switch subtype {
        case "second": return .seconds
        case "minute": return .minutes
        case "hour": return .hours
        default: return nil
        }
    }

    // MARK: - Temperature Units

    private static func temperatureUnit(for subtype: String) -> UnitTemperature? {
        switch subtype {
        case "celsius": return .celsius
        case "fahrenheit": return .fahrenheit
        case "kelvin": return .kelvin
        default: return nil
        }
    }

    // MARK: - Volume Units

    private static func volumeUnit(for subtype: String) -> UnitVolume? {
        switch subtype {
        case "liter": return .liters
        case "milliliter": return .milliliters
        case "gallon": return .gallons
        case "fluid-ounce": return .fluidOunces
        default: return nil
        }
    }

    // MARK: - Speed Units

    private static func speedUnit(for subtype: String) -> UnitSpeed? {
        switch subtype {
        case "meter-per-second": return .metersPerSecond
        case "kilometer-per-hour": return .kilometersPerHour
        case "mile-per-hour": return .milesPerHour
        default: return nil
        }
    }

    // MARK: - Area Units

    private static func areaUnit(for subtype: String) -> UnitArea? {
        switch subtype {
        case "square-meter": return .squareMeters
        case "square-kilometer": return .squareKilometers
        case "square-mile": return .squareMiles
        case "square-foot": return .squareFeet
        default: return nil
        }
    }
}
