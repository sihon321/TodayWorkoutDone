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
    
    var categoryType: WorkoutCategoryType? {
        return WorkoutCategoryType(rawValue: name.lowercased())
    }
    
    enum CodingKeys: String, CodingKey {
        case name
    }
    
    init(name: String) {
        self.name = name
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
    }
}

extension WorkoutCategoryState {
    init(model: WorkoutCategory) {
        self.name = model.name
    }
    
    func toModel() -> WorkoutCategory {
        return WorkoutCategory(name: name)
    }
}

@Model
class WorkoutCategory: WorkoutCategoryData, Equatable {
    var name: String

    init(name: String) {
        self.name = name
    }
}

extension WorkoutCategory {
    func update(from state: WorkoutCategoryState) {
        name = state.name
    }
}
