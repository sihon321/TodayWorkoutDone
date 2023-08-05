//
//  RoutinesInteractor.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/08/04.
//

import Foundation

protocol RoutinesInteractor {
    func load(routines: LoadableSubject<LazyList<Routines>>)
}

struct RealRoutinesInteractor: RoutinesInteractor {
    func load(routines: LoadableSubject<LazyList<Routines>>) {
        
    }
}
