//
//  MockedData.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/07/23.
//

import Foundation

extension WorkoutCategory {
    static let mockedData: [WorkoutCategory] = [
        WorkoutCategory(name: "헬스"),
        WorkoutCategory(name: "요가"),
        WorkoutCategory(name: "필라테스")
    ]
}

extension Workout {
    static let mockedData: [Workout] = [
        Workout(
            name: "스쿼트",
            category: WorkoutCategoryState(name: "하체"),
            target: "대퇴사두근, 햄스트링, 둔근",
            isSelected: false,
            summary: "대표적인 하체 복합 운동으로, 하체 근육 강화와 코어 안정성 향상에 효과적입니다.",
            instructions: [
                "어깨너비로 다리를 벌리고 선다.",
                "엉덩이를 뒤로 빼며 천천히 앉는다.",
                "무릎이 발끝을 넘지 않게 조심한다.",
                "발뒤꿈치로 지면을 밀어 올라온다."
            ],
            cautions: [
                "무릎이 안쪽으로 모이지 않도록 주의",
                "허리가 굽지 않도록 코어에 힘주기"
            ],
            difficulty: 2,
            mets: 5.0,
            caloriesPer30Min: 120,
            recommendedReps: "12~15회 × 3세트",
            restInterval: "30~60초",
            equipment: ["바벨", "덤벨", "스미스 머신"],
            animationName: "squat_animation"
        ),
        Workout(
            name: "스쿼트",
            category: WorkoutCategoryState(name: "하체"),
            target: "대퇴사두근, 햄스트링, 둔근",
            isSelected: false,
            summary: "대표적인 하체 복합 운동으로, 하체 근육 강화와 코어 안정성 향상에 효과적입니다.",
            instructions: [
                "어깨너비로 다리를 벌리고 선다.",
                "엉덩이를 뒤로 빼며 천천히 앉는다.",
                "무릎이 발끝을 넘지 않게 조심한다.",
                "발뒤꿈치로 지면을 밀어 올라온다."
            ],
            cautions: [
                "무릎이 안쪽으로 모이지 않도록 주의",
                "허리가 굽지 않도록 코어에 힘주기"
            ],
            difficulty: 2,
            mets: 5.0,
            caloriesPer30Min: 120,
            recommendedReps: "12~15회 × 3세트",
            restInterval: "30~60초",
            equipment: ["바벨", "덤벨", "스미스 머신"],
            animationName: "squat_animation"
        ),
        Workout(
            name: "스쿼트",
            category: WorkoutCategoryState(name: "하체"),
            target: "대퇴사두근, 햄스트링, 둔근",
            isSelected: false,
            summary: "대표적인 하체 복합 운동으로, 하체 근육 강화와 코어 안정성 향상에 효과적입니다.",
            instructions: [
                "어깨너비로 다리를 벌리고 선다.",
                "엉덩이를 뒤로 빼며 천천히 앉는다.",
                "무릎이 발끝을 넘지 않게 조심한다.",
                "발뒤꿈치로 지면을 밀어 올라온다."
            ],
            cautions: [
                "무릎이 안쪽으로 모이지 않도록 주의",
                "허리가 굽지 않도록 코어에 힘주기"
            ],
            difficulty: 2,
            mets: 5.0,
            caloriesPer30Min: 120,
            recommendedReps: "12~15회 × 3세트",
            restInterval: "30~60초",
            equipment: ["바벨", "덤벨", "스미스 머신"],
            animationName: "squat_animation"
        ),
        Workout(
            name: "스트레칭",
            category: WorkoutCategoryState(name: "하체"),
            target: "대퇴사두근, 햄스트링, 둔근",
            isSelected: false,
            summary: "대표적인 하체 복합 운동으로, 하체 근육 강화와 코어 안정성 향상에 효과적입니다.",
            instructions: [
                "어깨너비로 다리를 벌리고 선다.",
                "엉덩이를 뒤로 빼며 천천히 앉는다.",
                "무릎이 발끝을 넘지 않게 조심한다.",
                "발뒤꿈치로 지면을 밀어 올라온다."
            ],
            cautions: [
                "무릎이 안쪽으로 모이지 않도록 주의",
                "허리가 굽지 않도록 코어에 힘주기"
            ],
            difficulty: 2,
            mets: 5.0,
            caloriesPer30Min: 120,
            recommendedReps: "12~15회 × 3세트",
            restInterval: "30~60초",
            equipment: ["바벨", "덤벨", "스미스 머신"],
            animationName: "squat_animation"
        )
    ]
}

extension Routine {
    static let mockedData: [Routine] = Workout.mockedData.compactMap {
        Routine(
            index: 0,
            workout: $0,
            sets: [
                WorkoutSet(prevWeight: 30, weight: 40, prevReps: 12, reps: 12),
                WorkoutSet(prevWeight: 40, weight: 50, prevReps: 12, reps: 12),
                WorkoutSet(prevWeight: 50, weight: 60, prevReps: 12, reps: 10),
                WorkoutSet(prevWeight: 60, weight: 80, prevReps: 10, reps: 5)
            ],
            averageEndDate: 43
        )
    }
}

extension MyRoutine {
    static let mockedData: MyRoutine = MyRoutine(name: "test", routines: Routine.mockedData)
}

extension WorkoutRoutine {
    static let mockedData: WorkoutRoutine = WorkoutRoutine(name: "Test",
                                                           startDate: Date(),
                                                           endDate: Date(),
                                                           routines: Routine.mockedData)
}

extension WorkoutSet {
    static let mockedData: [WorkoutSet] = [
        WorkoutSet(), WorkoutSet(), WorkoutSet()
    ]
}
