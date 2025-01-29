//
//  WorkoutListView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/27.
//

import SwiftUI
import ComposableArchitecture
import Combine

@Reducer
struct WorkoutListReducer {
    @ObservableState
    struct State: Equatable {
        @Shared var myRoutine: MyRoutine
        var workouts: [Workout] = []
        
        var isEmptySelectedWorkouts: Bool {
            var isEmpty = true
            for workouts in workouts {
                if workouts.isSelected {
                    isEmpty = false
                    break
                }
            }
            return isEmpty
        }
        
        var groupedNames: [(key: String, value: [Workout])] {
            let groupedDictionary = Dictionary(grouping: workouts, by: { extractFirstCharacter($0.name) })
            return groupedDictionary.sorted { $0.key < $1.key }
        }
        
        func extractFirstCharacter(_ name: String) -> String {
            guard let first = name.first else { return "#" }
            let unicode = first.unicodeScalars.first!.value

            if unicode >= 0xAC00, unicode <= 0xD7A3 {
                let index = (unicode - 0xAC00) / 28 / 21
                let chosungList = ["ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
                return chosungList[Int(index)]
            }
            
            if first.isLetter {
                return String(first).uppercased()
            }

            return "#"
        }
    }
    
    enum Action {
        case makeWorkoutView([Routine])
        case getWorkouts(String)
        case updateWorkouts([Workout])
    }
}

struct WorkoutListView: View {
    @Bindable var store: StoreOf<WorkoutListReducer>
    @ObservedObject var viewStore: ViewStoreOf<WorkoutListReducer>
    private var categoryName = ""
    
    init(store: StoreOf<WorkoutListReducer>, category name: String) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
        self.categoryName = name
    }
    
    var body: some View {
        List {
            ForEach(store.groupedNames, id: \.key) { section in
                Section(header: Text(section.key)) {
                    ForEach(section.value, id: \.self) { workouts in
                        WorkoutListSubview(store: store, workouts: workouts)
                    }
                }
            }
        }
        .listStyle(.plain)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !viewStore.isEmptySelectedWorkouts {
                    Button(action: {
                        if store.myRoutine.routines.isEmpty == false {
                            var myRoutines: [Routine] = []
                            let myRoutineWorkouts = store.myRoutine.routines.map({ $0.workout })
                            let filteredWorkouts = store.workouts.filter({ $0.isSelected })
                            
                            for workout in filteredWorkouts where !myRoutineWorkouts.contains(workout) {
                                myRoutines.append(Routine(workouts: workout))
                            }
                            
                            store.send(.makeWorkoutView(store.myRoutine.routines + myRoutines))
                        } else {
                            let routines = store.workouts
                                .filter({ $0.isSelected })
                                .compactMap({ Routine(workouts: $0) })
                            store.send(.makeWorkoutView(routines))
                        }
                    }) {
                        let selectedWorkout = viewStore.workouts.filter({ $0.isSelected })
                        Text("Done(\(selectedWorkout.count))")
                    }
                }
            }
        }
        .navigationTitle(categoryName)
        .onAppear {
            store.send(.getWorkouts(categoryName))
        }
    }
}
