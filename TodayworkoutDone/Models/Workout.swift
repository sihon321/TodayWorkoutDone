//
//  Workouts.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/03/04.
//

import Foundation
import SwiftData

protocol WorkoutData {
    associatedtype WorkoutCategoryType
    
    var name: String { get set }
    var category: WorkoutCategoryType { get set }
    var target: [String] { get set }
    var isSelected: Bool { get set }
    var summary: String { get set }                    // 운동 설명
    var instructions: [String] { get set }             // 운동 방법 (단계별)
    var cautions: [String] { get set }                 // 주의 사항
    var difficulty: Int  { get set }                   // 난이도 (1~5)
    var mets: Double  { get set }                      // METs 값
    var caloriesPer30Min: Int { get set }              // 30분당 예상 칼로리
    var recommendedReps: String { get set }            // 예: "12~15회 × 3세트"
    var restInterval: String { get set }               // 예: "30~60초"
    var equipment: [String] { get set }                // 예: ["바벨", "덤벨"]
    var animationName: String? { get set }             // Lottie 등 리소스 이름
}

struct WorkoutState: WorkoutData, Codable, Equatable {
    typealias WorkoutCategoryType = WorkoutCategoryState
    
    var id: UUID = UUID()
    var name: String
    var category: WorkoutCategoryType
    var target: [String]
    var isSelected: Bool
    var summary: String
    var instructions: [String]
    var cautions: [String]
    var difficulty: Int
    var mets: Double
    var caloriesPer30Min: Int
    var recommendedReps: String
    var restInterval: String
    var equipment: [String]
    var animationName: String?
    
    enum CodingKeys: String, CodingKey {
        case name, category, target, isSelected, summary, instructions, cautions
        case difficulty, mets, caloriesPer30Min, recommendedReps, restInterval
        case equipment, animationName
    }
}

extension WorkoutState {
    init(model: Workout) {
        self.name = model.name
        self.category = model.category
        self.target = model.target
        self.isSelected = model.isSelected
        self.summary = model.summary
        self.instructions = model.instructions
        self.cautions = model.cautions
        self.difficulty = model.difficulty
        self.mets = model.mets
        self.caloriesPer30Min = model.caloriesPer30Min
        self.recommendedReps = model.recommendedReps
        self.restInterval = model.restInterval
        self.equipment = model.equipment
        self.animationName = model.animationName
    }
    
    func toModel() -> Workout {
        return Workout.create(from: self)
    }
}

extension Array where Element == WorkoutState {
    var allTrue: Bool {
        return self.allSatisfy { $0.isSelected }
    }
}

// MARK: - SwiftData

@Model
class Workout: WorkoutData, Equatable {
    typealias WorkoutCategoryType = WorkoutCategoryState
    
    var name: String
    var category: WorkoutCategoryType
    var target: [String]
    var isSelected: Bool
    var summary: String
    var instructions: [String]
    var cautions: [String]
    var difficulty: Int
    var mets: Double
    var caloriesPer30Min: Int
    var recommendedReps: String
    var restInterval: String
    var equipment: [String]
    var animationName: String?

    init(name: String,
         category: WorkoutCategoryType,
         target: [String],
         isSelected: Bool,
         summary: String,
         instructions: [String],
         cautions: [String],
         difficulty: Int,
         mets: Double,
         caloriesPer30Min: Int,
         recommendedReps: String,
         restInterval: String,
         equipment: [String],
         animationName: String?) {
        self.name = name
        self.category = category
        self.target = target
        self.isSelected = isSelected
        self.summary = summary
        self.instructions = instructions
        self.cautions = cautions
        self.difficulty = difficulty
        self.mets = mets
        self.caloriesPer30Min = caloriesPer30Min
        self.recommendedReps = recommendedReps
        self.restInterval = restInterval
        self.equipment = equipment
        self.animationName = animationName
    }
}

extension Workout {
    func update(from state: WorkoutState) {
        name = state.name
        category = state.category
        target = state.target
        isSelected = state.isSelected
    }
    
    static func create(from state: WorkoutState) -> Workout {
        Workout(
            name: state.name,
            category: state.category,
            target: state.target,
            isSelected: state.isSelected,
            summary: state.summary,
            instructions: state.instructions,
            cautions: state.cautions,
            difficulty: state.difficulty,
            mets: state.mets,
            caloriesPer30Min: state.caloriesPer30Min,
            recommendedReps: state.recommendedReps,
            restInterval: state.restInterval,
            equipment: state.equipment,
            animationName: state.animationName
        )
    }
}

extension Array where Element == Workout {
    var allTrue: Bool {
        return self.allSatisfy { $0.isSelected }
    }
}
