//
//  WorkoutCategoryView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/25.
//

import SwiftUI
import Dependencies
import ComposableArchitecture

@Reducer
struct WorkoutCategoryReducer {
    @ObservableState
    struct State: Equatable {
        var myRoutine: MyRoutineState?
        var keyword: String = ""
        var workoutList: IdentifiedArrayOf<WorkoutListReducer.State> = []
        
        init(myRoutine: MyRoutineState? = nil,
             keyword: String = "",
             workoutList: IdentifiedArrayOf<WorkoutListReducer.State> = []) {
            self.myRoutine = myRoutine
            self.keyword = keyword
            self.workoutList = workoutList
        }
    }
    
    enum Action {
        case setText(keyword: String)
        case workoutList(IdentifiedActionOf<WorkoutListReducer>)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .setText(let keyword):
                state.keyword = keyword
                return .none
            case .workoutList:
                return .none
            }
        }
        .forEach(\.workoutList, action: \.workoutList) {
            WorkoutListReducer()
        }
    }
}

struct WorkoutCategoryView: View {
    @Bindable var store: StoreOf<WorkoutCategoryReducer>
    @ObservedObject var viewStore: ViewStoreOf<WorkoutCategoryReducer>
    
    init(store: StoreOf<WorkoutCategoryReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("category")
                .font(.system(size: 20, weight: .medium))
            ForEach(
                store.scope(state: \.workoutList, action: \.workoutList)
            ) { rowStore in
                if rowStore.category.name.hasPrefix(store.keyword) {
                    NavigationLink {
                        WorkoutListView(store: rowStore)
                    } label: {
                        WorkoutCategorySubview(
                            category: rowStore.category
                        )
                    }
                }
            }
        }
        .padding([.leading, .trailing], 15)
    }
}
