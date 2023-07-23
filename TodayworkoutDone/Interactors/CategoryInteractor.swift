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
    func load(countries: LoadableSubject<LazyList<Category>>)
}

class RealCategoryInteractor: CategoryInteractor {
    let dbRepository: CategoryDBRepository
    let appState: Store<AppState>
    
    init(dbRepository: CategoryDBRepository, appState: Store<AppState>) {
        self.dbRepository = dbRepository
        self.appState = appState
    }
    
    func load(countries: LoadableSubject<LazyList<Category>>) {
        let cancelBag = CancelBag()
        
        Just<Void>
            .withErrorType(Error.self)
            .flatMap { [dbRepository] _ -> AnyPublisher<Bool, Error> in
                dbRepository.hasLoadedCategory()
            }
            .flatMap { [dbRepository] hasLoaded -> AnyPublisher<Void, Error> in
                if hasLoaded {
                    return Just<Void>.withErrorType(Error.self)
                } else {
                    return dbRepository.categories()
                }
            }
            .sinkToLoadable { countries.wrappedValue = $0 }
            .store(in: cancelBag)
    }
}

struct StubCategoryInteractor: CategoryInteractor {
    func load(countries: LoadableSubject<LazyList<Category>>, search: String) { }
}
