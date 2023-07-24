//
//  MockedData.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/07/23.
//

import Foundation

extension Category {
    static let mockedData: [Category] = [
        Category(kor: "헬스", en: "gym"),
        Category(kor: "요가", en: "yoga"),
        Category(kor: "필라테스", en: "pilates")
    ]
}

extension Workouts {
    static let mockedData: [Workouts] = [
        Workouts(name: "스쿼시", category: "gym", target: "하체"),
        Workouts(name: "스쿼시", category: "gym", target: "하체"),
        Workouts(name: "스쿼시", category: "gym", target: "하체")
    ]
}
