//
//  CategoryWebRepository.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/07/23.
//

import Combine
import Foundation

protocol CategoryWebRepository {
    func loadCategories() -> AnyPublisher<[Category], Error>
}

class RealCategoryWebRepository: CategoryWebRepository {
    func loadCategories() -> AnyPublisher<[Category], Error> {
        let categories: [Category] = load("category.json")
        return Just<[Category]>(categories)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
