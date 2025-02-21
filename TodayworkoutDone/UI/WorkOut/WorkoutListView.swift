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
        var keyword: String = ""
        var groupedNames: [(key: String, value: [Workout])] {
            let filteredWorkout = workouts.filter { $0.name.hasPrefix(keyword) }
            let groupedDictionary = Dictionary(grouping: filteredWorkout,
                                               by: { extractFirstCharacter($0.name) })
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
        case search(keyword: String)
        case updateMyRoutine(Workout)
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
                if !viewStore.myRoutine.routines.isEmpty {
                    Button(action: {
                        store.send(.makeWorkoutView(store.myRoutine.routines))
                    }) {
                        let selectedWorkoutCount = viewStore.myRoutine.routines.count
                        Text("Done(\(selectedWorkoutCount))")
                    }
                }
            }
        }
        .searchable(text: viewStore.binding(
            get: { $0.keyword },
            send: { WorkoutListReducer.Action.search(keyword: $0) }
        ))
        .navigationTitle(categoryName)
        .onAppear {
            store.send(.getWorkouts(categoryName))
        }
    }
}
