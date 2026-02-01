import Testing
import Foundation
@testable import ICUNumberSkeletonFormat

@Suite("SkeletonOptions Tests")
struct SkeletonOptionsTests {
    
    // MARK: - Initialization Tests
    
    @Test("Default initialization creates empty options")
    func defaultInitialization() {
        let options = SkeletonOptions()
        
        #expect(options.notation == nil)
        #expect(options.unit == nil)
        #expect(options.unitWidth == nil)
        #expect(options.precision == nil)
        #expect(options.roundingMode == nil)
        #expect(options.integerWidth == nil)
        #expect(options.scale == nil)
        #expect(options.grouping == nil)
        #expect(options.signDisplay == nil)
        #expect(options.decimalSeparator == nil)
        #expect(options.numberingSystem == nil)
        #expect(options.latinDigits == false)
    }
    
    // MARK: - Equatable Tests
    
    @Test("SkeletonOptions equality with identical properties")
    func equalityIdentical() {
        var options1 = SkeletonOptions()
        options1.notation = .scientific
        options1.precision = .fractionDigits(min: 2, max: 2)
        
        var options2 = SkeletonOptions()
        options2.notation = .scientific
        options2.precision = .fractionDigits(min: 2, max: 2)
        
        #expect(options1 == options2)
    }
    
    @Test("SkeletonOptions inequality with different notation")
    func inequalityNotation() {
        var options1 = SkeletonOptions()
        options1.notation = .scientific
        
        var options2 = SkeletonOptions()
        options2.notation = .engineering
        
        #expect(options1 != options2)
    }
    
    @Test("SkeletonOptions inequality with different precision")
    func inequalityPrecision() {
        var options1 = SkeletonOptions()
        options1.precision = .fractionDigits(min: 2, max: 2)
        
        var options2 = SkeletonOptions()
        options2.precision = .fractionDigits(min: 2, max: 3)
        
        #expect(options1 != options2)
    }
    
    // MARK: - Hashable Tests
    
    @Test("SkeletonOptions can be used in a Set")
    func hashableInSet() {
        var options1 = SkeletonOptions()
        options1.notation = .scientific
        
        var options2 = SkeletonOptions()
        options2.notation = .engineering
        
        var options3 = SkeletonOptions()
        options3.notation = .scientific // duplicate of options1
        
        let set: Set<SkeletonOptions> = [options1, options2, options3]
        
        // Should contain only 2 unique elements
        #expect(set.count == 2)
        #expect(set.contains(options1))
        #expect(set.contains(options2))
    }
    
    @Test("SkeletonOptions can be used as Dictionary keys")
    func hashableAsDictionaryKey() {
        var options1 = SkeletonOptions()
        options1.notation = .scientific
        
        var options2 = SkeletonOptions()
        options2.notation = .engineering
        
        var dictionary: [SkeletonOptions: String] = [:]
        dictionary[options1] = "scientific"
        dictionary[options2] = "engineering"
        
        #expect(dictionary.count == 2)
        #expect(dictionary[options1] == "scientific")
        #expect(dictionary[options2] == "engineering")
    }
    
    // MARK: - Codable Tests
    
    @Test("SkeletonOptions can be encoded and decoded")
    func codableRoundTrip() throws {
        var original = SkeletonOptions()
        original.notation = .scientific
        original.precision = .fractionDigits(min: 2, max: 4)
        original.grouping = .auto
        original.signDisplay = .always
        original.scale = Decimal(100)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(SkeletonOptions.self, from: data)
        
        #expect(decoded == original)
        #expect(decoded.notation == .scientific)
        #expect(decoded.precision == .fractionDigits(min: 2, max: 4))
        #expect(decoded.grouping == .auto)
        #expect(decoded.signDisplay == .always)
        #expect(decoded.scale == Decimal(100))
    }
    
    @Test("SkeletonOptions with all properties can be encoded and decoded")
    func codableAllProperties() throws {
        var original = SkeletonOptions()
        original.notation = .compactShort
        original.unit = .currency(code: "USD")
        original.unitWidth = .narrow
        original.precision = .significantDigits(min: 3, max: 5)
        original.roundingMode = .halfUp
        original.integerWidth = SkeletonOptions.IntegerWidth(minDigits: 3, maxDigits: 5)
        original.scale = Decimal(string: "0.01")
        original.grouping = .off
        original.signDisplay = .exceptZero
        original.decimalSeparator = .always
        original.numberingSystem = "latn"
        original.latinDigits = true
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(SkeletonOptions.self, from: data)
        
        #expect(decoded == original)
    }
    
    @Test("Empty SkeletonOptions can be encoded and decoded")
    func codableEmpty() throws {
        let original = SkeletonOptions()
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(SkeletonOptions.self, from: data)
        
        #expect(decoded == original)
    }
    
    // MARK: - Notation Enum Tests
    
    @Test("Notation enum equality")
    func notationEquality() {
        #expect(SkeletonOptions.Notation.simple == SkeletonOptions.Notation.simple)
        #expect(SkeletonOptions.Notation.scientific != SkeletonOptions.Notation.engineering)
    }
    
    @Test("Notation enum is hashable")
    func notationHashable() {
        let set: Set<SkeletonOptions.Notation> = [.simple, .scientific, .simple]
        #expect(set.count == 2)
    }
    
    // MARK: - Unit Enum Tests
    
    @Test("Unit enum equality")
    func unitEquality() {
        #expect(SkeletonOptions.Unit.percent == SkeletonOptions.Unit.percent)
        #expect(SkeletonOptions.Unit.currency(code: "USD") == SkeletonOptions.Unit.currency(code: "USD"))
        #expect(SkeletonOptions.Unit.currency(code: "USD") != SkeletonOptions.Unit.currency(code: "EUR"))
        #expect(SkeletonOptions.Unit.measureUnit(type: "length", subtype: "meter") == 
                SkeletonOptions.Unit.measureUnit(type: "length", subtype: "meter"))
    }
    
    @Test("Unit enum is hashable")
    func unitHashable() {
        let set: Set<SkeletonOptions.Unit> = [
            .percent,
            .permille,
            .currency(code: "USD"),
            .currency(code: "USD") // duplicate
        ]
        #expect(set.count == 3)
    }
    
    // MARK: - UnitWidth Enum Tests
    
    @Test("UnitWidth enum equality")
    func unitWidthEquality() {
        #expect(SkeletonOptions.UnitWidth.narrow == SkeletonOptions.UnitWidth.narrow)
        #expect(SkeletonOptions.UnitWidth.short != SkeletonOptions.UnitWidth.fullName)
    }
    
    // MARK: - Precision Enum Tests
    
    @Test("Precision enum equality")
    func precisionEquality() {
        #expect(SkeletonOptions.Precision.integer == SkeletonOptions.Precision.integer)
        #expect(SkeletonOptions.Precision.fractionDigits(min: 2, max: 2) == 
                SkeletonOptions.Precision.fractionDigits(min: 2, max: 2))
        #expect(SkeletonOptions.Precision.fractionDigits(min: 2, max: 2) != 
                SkeletonOptions.Precision.fractionDigits(min: 2, max: 3))
        #expect(SkeletonOptions.Precision.significantDigits(min: 3, max: 3) == 
                SkeletonOptions.Precision.significantDigits(min: 3, max: 3))
        #expect(SkeletonOptions.Precision.increment(value: Decimal(string: "0.05")!) == 
                SkeletonOptions.Precision.increment(value: Decimal(string: "0.05")!))
    }
    
    @Test("Precision enum is hashable")
    func precisionHashable() {
        let set: Set<SkeletonOptions.Precision> = [
            .integer,
            .fractionDigits(min: 2, max: 2),
            .integer, // duplicate
            .unlimited
        ]
        #expect(set.count == 3)
    }
    
    // MARK: - RoundingMode Enum Tests
    
    @Test("RoundingMode enum equality")
    func roundingModeEquality() {
        #expect(SkeletonOptions.RoundingMode.ceiling == SkeletonOptions.RoundingMode.ceiling)
        #expect(SkeletonOptions.RoundingMode.floor != SkeletonOptions.RoundingMode.ceiling)
    }
    
    @Test("RoundingMode enum is hashable")
    func roundingModeHashable() {
        let set: Set<SkeletonOptions.RoundingMode> = [.ceiling, .floor, .ceiling]
        #expect(set.count == 2)
    }
    
    // MARK: - IntegerWidth Tests
    
    @Test("IntegerWidth equality")
    func integerWidthEquality() {
        let width1 = SkeletonOptions.IntegerWidth(minDigits: 3, maxDigits: 5)
        let width2 = SkeletonOptions.IntegerWidth(minDigits: 3, maxDigits: 5)
        let width3 = SkeletonOptions.IntegerWidth(minDigits: 3, maxDigits: nil)
        
        #expect(width1 == width2)
        #expect(width1 != width3)
    }
    
    @Test("IntegerWidth is hashable")
    func integerWidthHashable() {
        let set: Set<SkeletonOptions.IntegerWidth> = [
            SkeletonOptions.IntegerWidth(minDigits: 3, maxDigits: 5),
            SkeletonOptions.IntegerWidth(minDigits: 3, maxDigits: 5), // duplicate
            SkeletonOptions.IntegerWidth(minDigits: 2, maxDigits: 4)
        ]
        #expect(set.count == 2)
    }
    
    @Test("IntegerWidth is codable")
    func integerWidthCodable() throws {
        let original = SkeletonOptions.IntegerWidth(minDigits: 3, maxDigits: 5)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(SkeletonOptions.IntegerWidth.self, from: data)
        
        #expect(decoded == original)
        #expect(decoded.minDigits == 3)
        #expect(decoded.maxDigits == 5)
    }
    
    // MARK: - Grouping Enum Tests
    
    @Test("Grouping enum equality")
    func groupingEquality() {
        #expect(SkeletonOptions.Grouping.auto == SkeletonOptions.Grouping.auto)
        #expect(SkeletonOptions.Grouping.off != SkeletonOptions.Grouping.auto)
    }
    
    // MARK: - SignDisplay Enum Tests
    
    @Test("SignDisplay enum equality")
    func signDisplayEquality() {
        #expect(SkeletonOptions.SignDisplay.auto == SkeletonOptions.SignDisplay.auto)
        #expect(SkeletonOptions.SignDisplay.always != SkeletonOptions.SignDisplay.never)
    }
    
    @Test("SignDisplay enum is hashable")
    func signDisplayHashable() {
        let set: Set<SkeletonOptions.SignDisplay> = [.auto, .always, .auto]
        #expect(set.count == 2)
    }
    
    // MARK: - DecimalSeparator Enum Tests
    
    @Test("DecimalSeparator enum equality")
    func decimalSeparatorEquality() {
        #expect(SkeletonOptions.DecimalSeparator.auto == SkeletonOptions.DecimalSeparator.auto)
        #expect(SkeletonOptions.DecimalSeparator.auto != SkeletonOptions.DecimalSeparator.always)
    }
}

@Suite("SkeletonOptions Property Mutation Tests")
struct SkeletonOptionsMutationTests {
    
    @Test("Modifying properties creates different instances")
    func propertyMutation() {
        var options1 = SkeletonOptions()
        options1.notation = .scientific
        
        var options2 = options1 // copy
        options2.notation = .engineering
        
        #expect(options1.notation == .scientific)
        #expect(options2.notation == .engineering)
        #expect(options1 != options2)
    }
    
    @Test("Setting all properties individually")
    func setAllProperties() {
        var options = SkeletonOptions()
        
        options.notation = .compactShort
        #expect(options.notation == .compactShort)
        
        options.unit = .percent
        #expect(options.unit == .percent)
        
        options.unitWidth = .narrow
        #expect(options.unitWidth == .narrow)
        
        options.precision = .integer
        #expect(options.precision == .integer)
        
        options.roundingMode = .ceiling
        #expect(options.roundingMode == .ceiling)
        
        options.integerWidth = SkeletonOptions.IntegerWidth(minDigits: 2)
        #expect(options.integerWidth?.minDigits == 2)
        
        options.scale = Decimal(100)
        #expect(options.scale == 100)
        
        options.grouping = .off
        #expect(options.grouping == .off)
        
        options.signDisplay = .always
        #expect(options.signDisplay == .always)
        
        options.decimalSeparator = .always
        #expect(options.decimalSeparator == .always)
        
        options.numberingSystem = "arab"
        #expect(options.numberingSystem == "arab")
        
        options.latinDigits = true
        #expect(options.latinDigits == true)
    }
    
    @Test("Clearing properties by setting to nil")
    func clearProperties() {
        var options = SkeletonOptions()
        options.notation = .scientific
        options.precision = .integer
        
        options.notation = nil
        options.precision = nil
        
        #expect(options.notation == nil)
        #expect(options.precision == nil)
    }
}

@Suite("SkeletonOptions Complex Scenario Tests")
struct SkeletonOptionsComplexTests {
    
    @Test("Currency with all related options")
    func currencyWithAllOptions() {
        var options = SkeletonOptions()
        options.unit = .currency(code: "USD")
        options.unitWidth = .fullName
        options.precision = .fractionDigits(min: 2, max: 2)
        options.grouping = .auto
        options.signDisplay = .accounting
        options.roundingMode = .halfUp
        
        #expect(options.unit == .currency(code: "USD"))
        #expect(options.unitWidth == .fullName)
    }
    
    @Test("Measure unit with all related options")
    func measureUnitWithAllOptions() {
        var options = SkeletonOptions()
        options.unit = .measureUnit(type: "length", subtype: "meter")
        options.unitWidth = .short
        options.precision = .fractionDigits(min: 1, max: 2)
        options.grouping = .auto
        
        #expect(options.unit == .measureUnit(type: "length", subtype: "meter"))
    }
    
    @Test("Scientific notation with precision")
    func scientificWithPrecision() {
        var options = SkeletonOptions()
        options.notation = .scientific
        options.precision = .significantDigits(min: 3, max: 5)
        options.signDisplay = .always
        
        #expect(options.notation == .scientific)
        #expect(options.precision == .significantDigits(min: 3, max: 5))
    }
    
    @Test("Options with scale and integer width")
    func scaleWithIntegerWidth() {
        var options = SkeletonOptions()
        options.scale = Decimal(100)
        options.integerWidth = SkeletonOptions.IntegerWidth(minDigits: 4, maxDigits: 6)
        options.grouping = .off
        
        #expect(options.scale == 100)
        #expect(options.integerWidth?.minDigits == 4)
        #expect(options.integerWidth?.maxDigits == 6)
    }
}
