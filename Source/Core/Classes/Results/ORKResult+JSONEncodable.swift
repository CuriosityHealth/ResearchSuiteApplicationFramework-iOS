//
//  ORKResult+JSONEncodable.swift
//  ResearchSuiteExtensions
//
//  Created by James Kizer on 4/25/18.
//

import Foundation
import ResearchKit
import Gloss
import ResearchSuiteExtensions

class RSJSONHelpers {
    
    static func merge(_ from: JSON?, into: JSON) -> JSON {
        var returnJSON = into
        from?.forEach { (key, value) in
            returnJSON[key] = value
        }
        
        return returnJSON
    }
    
}

extension ORKResult: JSONEncodable {
    @objc open func toJSON() -> JSON? {
        
        return jsonify([
            "identifier" ~~> self.identifier,
            Gloss.Encoder.encode(dateISO8601ForKey: "startDate")(self.startDate),
            Gloss.Encoder.encode(dateISO8601ForKey: "endDate")(self.endDate),
            "userInfo" ~~> self.userInfo
            ])
        
    }
}

extension ORKCollectionResult {
    @objc open override func toJSON() -> JSON? {
        
        guard let superJson = super.toJSON() else {
            return nil
        }
        
        var json: JSON = [:]
        if let results = self.results {
            results.forEach { (result) in
                json[result.identifier] = result.toJSON()
            }
        }
        
        return RSJSONHelpers.merge(json, into: superJson)
    }
}

extension ORKTextQuestionResult {
    @objc open override func toJSON() -> JSON? {
        
        guard let superJson = super.toJSON() else {
            return nil
        }
        
        let json = jsonify([
            "textAnswer" ~~> self.textAnswer
            ])
        
        return RSJSONHelpers.merge(json, into: superJson)
    }
}

extension ORKScaleQuestionResult {
    @objc open override func toJSON() -> JSON? {
        
        guard let superJson = super.toJSON() else {
            return nil
        }
        
        let json = jsonify([
            "scaleAnswer" ~~> self.scaleAnswer
            ])
        
        return RSJSONHelpers.merge(json, into: superJson)
    }
}

//ORKChoiceQuestionResult
extension ORKChoiceQuestionResult {
    @objc open override func toJSON() -> JSON? {
        
        guard let superJson = super.toJSON() else {
            return nil
        }
        
        let jsonArray: [JSON] = self.choiceAnswers?.compactMap { $0 as? JSONEncodable }.compactMap { $0.toJSON() } ?? []
        
        let json = jsonify([
            "choiceAnswers" ~~> jsonArray
            ])
        
        return RSJSONHelpers.merge(json, into: superJson)
    }
}

extension ORKBooleanQuestionResult {
    @objc open override func toJSON() -> JSON? {
        
        guard let superJson = super.toJSON() else {
            return nil
        }
        
        let json = jsonify([
            "booleanAnswer" ~~> self.booleanAnswer
            ])
        
        return RSJSONHelpers.merge(json, into: superJson)
    }
}

//ORKNumericQuestionResult
extension ORKNumericQuestionResult {
    @objc open override func toJSON() -> JSON? {
        
        guard let superJson = super.toJSON() else {
            return nil
        }
        
        let json = jsonify([
            "numericAnswer" ~~> self.numericAnswer,
            "unit" ~~> self.unit
            ])
        
        return RSJSONHelpers.merge(json, into: superJson)
    }
}



//ORKTimeOfDayQuestionResult
extension ORKTimeOfDayQuestionResult {
    @objc open override func toJSON() -> JSON? {
        
        guard let superJson = super.toJSON() else {
            return nil
        }
        
        let calendar = Calendar(identifier: .gregorian)
        
        guard let dateComponents = self.dateComponentsAnswer,
            let date = calendar.date(from: dateComponents) else {
                return superJson
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        
        let json = jsonify([
            "dateComponentsAnswer" ~~> formatter.string(from: date)
            ])
        
        return RSJSONHelpers.merge(json, into: superJson)
    }
}

//ORKTimeIntervalQuestionResult
extension ORKTimeIntervalQuestionResult {
    @objc open override func toJSON() -> JSON? {
        
        guard let superJson = super.toJSON() else {
            return nil
        }
        
        let json = jsonify([
            "intervalAnswer" ~~> self.intervalAnswer
            ])
        
        return RSJSONHelpers.merge(json, into: superJson)
    }
}

//ORKDateQuestionResult
extension ORKDateQuestionResult {
    @objc open override func toJSON() -> JSON? {
        
        guard let superJson = super.toJSON() else {
            return nil
        }
        
        let json = jsonify([
            Gloss.Encoder.encode(dateISO8601ForKey: "dateAnswer")(self.dateAnswer)
            ])
        
        return RSJSONHelpers.merge(json, into: superJson)
    }
}

extension ORKLocation: JSONEncodable {
    public func toJSON() -> JSON? {
        return jsonify([
            "latitude" ~~> self.coordinate.latitude,
            "longitude" ~~> self.coordinate.longitude,
            ])
    }
}

//ORKLocationQuestionResult
extension ORKLocationQuestionResult {
    @objc open override func toJSON() -> JSON? {
        
        guard let superJson = super.toJSON() else {
            return nil
        }
        
        let json = jsonify([
            "locationAnswer" ~~> self.locationAnswer
            ])
        
        return RSJSONHelpers.merge(json, into: superJson)
    }
}

//ORKMultipleComponentQuestionResult
extension ORKMultipleComponentQuestionResult {
    @objc open override func toJSON() -> JSON? {
        
        guard let superJson = super.toJSON() else {
            return nil
        }
        
        let jsonArray: [JSON] = self.componentsAnswer?.compactMap { $0 as? JSONEncodable }.compactMap { $0.toJSON() } ?? []
        
        let json = jsonify([
            "componentsAnswer" ~~> jsonArray
            ])
        
        return RSJSONHelpers.merge(json, into: superJson)
    }
}

//RSEnhancedMultipleChoiceResult
extension RSEnhancedMultipleChoiceResult {
    @objc open override func toJSON() -> JSON? {
        
        guard let superJson = super.toJSON() else {
            return nil
        }
        
        let jsonArray: [JSON] = self.choiceAnswers?.compactMap { $0.toJSON() } ?? []
        
        let json = jsonify([
            "choiceAnswers" ~~> jsonArray
            ])
        
        return RSJSONHelpers.merge(json, into: superJson)
    }
}


