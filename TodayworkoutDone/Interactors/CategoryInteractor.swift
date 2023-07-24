//
//  CategoryInteractor.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/07/22.
//

import Combine
import Foundation
import SwiftUI

protocol CategoryInteractor {
    func load(categories: LoadableSubject<LazyList<Category>>)
}

class RealCategoryInteractor: CategoryInteractor {
    let webRepository: CategoryWebRepository
    let dbRepository: CategoryDBRepository
    let appState: Store<AppState>
    
    init(webRepository: CategoryWebRepository,
         dbRepository: CategoryDBRepository,
         appState: Store<AppState>) {
        self.webRepository = webRepository
        self.dbRepository = dbRepository
        self.appState = appState
    }
    
    func load(categories: LoadableSubject<LazyList<Category>>) {
        
        let cancelBag = CancelBag()
        categories.wrappedValue.setIsLoading(cancelBag: cancelBag)
        
        Just<Void>
            .withErrorType(Error.self)
            .flatMap { [dbRepository] _ -> AnyPublisher<Bool, Error> in
                dbRepository.hasLoadedCategory()
            }
            .flatMap { hasLoaded -> AnyPublisher<Void, Error> in
                if hasLoaded {
                    return Just<Void>.withErrorType(Error.self)
                } else {
                    return self.refreshCategoriesList()
                }
            }
            .flatMap { [dbRepository] in
                dbRepository.categories()
            }
            .sinkToLoadable { categories.wrappedValue = $0 }
            .store(in: cancelBag)
    }
    
    func refreshCategoriesList() -> AnyPublisher<Void, Error> {
        return webRepository
            .loadCategories()
            .flatMap { [dbRepository] in
                dbRepository.store(categories: $0)
            }
            .eraseToAnyPublisher()
    }
}

struct StubCategoryInteractor: CategoryInteractor {
    func load(categories: LoadableSubject<LazyList<Category>>) { }
}
