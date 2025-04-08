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

        var workoutList: WorkoutListReducer.State
    }
    
    enum Action {
        case setText(keyword: String)
        case getCategories
        case updateCategories(Categories)
        case workoutList(WorkoutListReducer.Action)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            default:
                return .none
            }
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
        VStack(alignment: .leading)  {
            Text("category")
                .font(.system(size: 20, weight: .medium))
            let categories = viewStore.categories.filter {
                $0.name.hasPrefix(store.keyword)
            }
            ForEach(categories) { category in
                NavigationLink {
                    WorkoutListView(
                        store: store.scope(state: \.workoutList,
                                           action: \.workoutList),
                        category: category.name
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
