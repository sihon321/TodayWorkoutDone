//
//  CategoryDBRepository.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/07/22.
//

import CoreData
import Combine

protocol CategoryDBRepository {
    func hasLoadedCategory() -> AnyPublisher<Bool, Error>
    func categories() -> AnyPublisher<LazyList<Category>, Error>
    func store(categories: [Category]) -> AnyPublisher<Void, Error>
}

struct RealCategoryDBRepository: CategoryDBRepository {
    let persistentStore: PersistentStore
    
    func hasLoadedCategory() -> AnyPublisher<Bool, Error> {
        let fetchRequest = CategoryMO.categories()
        return persistentStore
            .count(fetchRequest)
            .map { $0 > 0 }
            .eraseToAnyPublisher()  
    }
    
    func categories() -> AnyPublisher<LazyList<Category>, Error> {
        let fetchRequest = CategoryMO.categories()
        return persistentStore
            .fetch(fetchRequest) {
                Category(managedObject: $0)
            }
            .eraseToAnyPublisher()
    }
    
    func store(categories: [Category]) -> AnyPublisher<Void, Error> {
        return persistentStore
            .update { context in
                categories.forEach {
                    $0.store(in: context)
                }
            }
    }
}

extension CategoryMO {
    static func categories() -> NSFetchRequest<CategoryMO> {
        let request = newFetchRequest()
        request.fetchBatchSize = 10
        return request
    }
    
}
