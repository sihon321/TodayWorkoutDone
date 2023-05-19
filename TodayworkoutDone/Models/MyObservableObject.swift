//
//  MyObservableObject.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/05/17.
//

import Foundation
import Combine

class MyObservableObject: ObservableObject {
    @Published var isWorkingOutView = false
    @Published var selectionWorkouts: [Excercise] = []
}
