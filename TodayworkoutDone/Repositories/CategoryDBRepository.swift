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
    func categories() ->  AnyPublisher<LazyList<Category>, Error>
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
    
    func categories() ->  AnyPublisher<LazyList<Category>, Error> {
        let fetchRequest = CategoryMO.categories()
        return persistentStore
            .fetch(fetchRequest) {
                Category(managedObject: $0)
            }
            .eraseToAnyPublisher()
    }
}

extension CategoryMO {
    static func categories() -> NSFetchRequest<CategoryMO> {
        let request = newFetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        request.fetchBatchSize = 10
        return request
    }
    
}
