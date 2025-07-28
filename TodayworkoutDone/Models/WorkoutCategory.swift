//
//  WorkoutCategory.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/04/04.
//

import Foundation
import SwiftData
import HealthKit

protocol WorkoutCategoryData {
    var name: String { get set }
    var classification: [String] { get }
    var explanation: String? { get }
    var count: Int? { get }
}

struct WorkoutCategoryState: WorkoutCategoryData, Equatable, Codable {
    enum WorkoutCategoryType: String, CaseIterable, Codable {
        case strength
        case pilates
        case cardio
        case yoga
        case stretching

        // HealthKit용 매핑
        var hkWorkoutActivityType: HKWorkoutActivityType {
            switch self {
            case .strength:
                return .traditionalStrengthTraining
            case .pilates:
                return .pilates
            case .cardio:
                return .running // Cardio 기본값은 running, 세부 분류 필요시 따로 처리
            case .yoga:
                return .yoga
            case .stretching:
                return .flexibility
            }
        }
    }

    var name: String
    var classification: [String]
    var explanation: String?
    var count: Int?
    
    var categoryType: WorkoutCategoryType {
        return WorkoutCategoryType(rawValue: name.lowercased()) ?? .strength
    }
    
    enum CodingKeys: String, CodingKey {
        case name, classification, explanation, count
    }
    
    init(name: String,
         classification: [String],
         explanation: String?,
         count: Int?) {
        self.name = name
        self.classification = classification
        self.explanation = explanation
        self.count = count
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        classification = try container.decode([String].self, forKey: .classification)
        explanation = try container.decodeIfPresent(String.self, forKey: .explanation)
        count =  try container.decodeIfPresent(Int.self, forKey: .count)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(classification, forKey: .classification)
        try container.encode(explanation, forKey: .explanation)
        try container.encode(count, forKey: .count)
    }
}

extension WorkoutCategoryState {
    init(model: WorkoutCategory) {
        self.name = model.name
        self.classification = model.classification
        self.explanation = model.explanation
        self.count = model.count
    }
    
    func toModel() -> WorkoutCategory {
        return WorkoutCategory(
            name: name,
            classification: classification,
            explanation: explanation,
            count: count
        )
    }
}

@Model
class WorkoutCategory: WorkoutCategoryData, Equatable {
    var name: String
    var classification: [String]
    var explanation: String?
    var count: Int?

    init(name: String,
         classification: [String],
         explanation: String?,
         count: Int?) {
        self.name = name
        self.classification = classification
        self.explanation = explanation
        self.count = count
    }
}

extension WorkoutCategory {
    func update(from state: WorkoutCategoryState) {
        name = state.name
        classification = state.classification
        explanation = state.explanation
        count = state.count
    }
}
