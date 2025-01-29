//
//  AddWorkoutCategoryView.swift
//  TodayworkoutDone
//
//  Created by ocean on 10/14/24.
//


import SwiftUI
import Dependencies
import ComposableArchitecture

@Reducer
struct AddWorkoutCategoryReducer {
    @ObservableState
    struct State: Equatable {
        @Shared var myRoutine: MyRoutine?
        
        var keyword: String = ""
        var categories: Categories = []

        var workoutList: WorkoutListReducer.State
    }
    
    enum Action {
        case getCategories
        case updateCategories(Categories)
        case workoutList(WorkoutListReducer.Action)
        case dismissWorkoutCategory
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

struct AddWorkoutCategoryView: View {
    @Bindable var store: StoreOf<AddWorkoutCategoryReducer>
    @ObservedObject var viewStore: ViewStoreOf<AddWorkoutCategoryReducer>
    
    init(store: StoreOf<AddWorkoutCategoryReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
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
                                category: category.name
                            )
                        } label: {
                            WorkoutCategorySubview(category: category)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        self.store.send(.dismissWorkoutCategory)
                    }
                }
            }
        }
        .padding([.leading, .trailing], 15)
        .onAppear {
            store.send(.getCategories)
        }
    }
}

