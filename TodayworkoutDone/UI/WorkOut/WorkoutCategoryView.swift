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
        var keyword: String = ""
        var categories: Categories = []

        var myRoutine: MyRoutine?

        var workoutList: WorkoutListReducer.State
        
        init(_ myRoutine: MyRoutine?) {
            self.myRoutine = myRoutine
            self.workoutList = WorkoutListReducer.State(myRoutine: myRoutine)
        }
    }
    
    enum Action {
        case setText(keyword: String)
        case getCategories
        case updateCategories(Categories)
        case workoutList(WorkoutListReducer.Action)
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
        VStack(alignment: .leading)  {
            Text("category")
            let filteredCategory = viewStore.workoutList.workouts
                .filter({ $0.name.hasPrefix(store.keyword) })
                .compactMap({ $0.category })
                .uniqued()
            let categories = viewStore.categories.filter {
                if filteredCategory.isEmpty {
                    return true
                } else if filteredCategory.contains($0.name) {
                    return true
                } else {
                    return false
                }
            }
            ForEach(categories) { category in
                NavigationLink {
                    WorkoutListView(
                        store: store.scope(state: \.workoutList,
                                           action: \.workoutList),
                        category: category
                    )
                } label: {
                    WorkoutCategorySubview(category: category)
                }
            }
        }
        .padding([.leading, .trailing], 15)
        .onAppear {
            store.send(.getCategories)
        }
    }
}
