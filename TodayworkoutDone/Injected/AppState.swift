//
//  AppState.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/05/29.
//

import Foundation

struct AppState: Equatable {
    var userData = UserData()
}

extension AppState {
    struct UserData: Equatable {
        var isWorkingOutView = false
        var selectionWorkouts: [Excercise] = []
    }
}
