//
//  CategoryAPIRepository.swift
//  TodayworkoutDone
//
//  Created by ocean on 9/16/24.
//

import Foundation
import Dependencies

extension DependencyValues {
    var categoryAPI: RealCategoryAPIRepository {
        get { self[RealCategoryAPIRepository.self] }
        set { self[RealCategoryAPIRepository.self] = newValue }
    }
}

struct RealCategoryAPIRepository {
    var loadCategories: () -> [WorkoutCategoryState]
}

extension RealCategoryAPIRepository: DependencyKey {
    public static let liveValue = Self(
        loadCategories: {
            let categories: [WorkoutCategoryState] = load("category.json")
            
            return categories
        }
    )
}

extension RealCategoryAPIRepository: TestDependencyKey {
    public static let testValue = Self(
        loadCategories: unimplemented("\(Self.self).loadWorkouts")
    )
}
