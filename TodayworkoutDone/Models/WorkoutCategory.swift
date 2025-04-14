//
//  WorkoutCategory.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/04/04.
//

import Foundation
import SwiftData

protocol WorkoutCategoryData {
    var name: String { get set }
}

struct WorkoutCategoryState: WorkoutCategoryData, Equatable, Codable {
    var name: String
    
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
