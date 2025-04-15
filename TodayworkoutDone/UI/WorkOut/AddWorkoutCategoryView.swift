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
        var myRoutine: MyRoutineState
        var keyword: String = ""
        var categories: [WorkoutCategoryState] = []
        
        var workoutList: IdentifiedArrayOf<WorkoutListReducer.State>

        init(myRoutine: MyRoutineState,
             keyword: String = "",
             categories: [WorkoutCategoryState] = [],
             workoutList: IdentifiedArrayOf<WorkoutListReducer.State>) {
            self.myRoutine = myRoutine
            self.keyword = keyword
            self.categories = categories
            self.workoutList = workoutList
        }
    }
    
    enum Action {
        case getCategories
        case updateCategories([WorkoutCategoryState])
        case dismissWorkoutCategory
        case workoutList(IdentifiedActionOf<WorkoutListReducer>)
    }
    
    @Dependency(\.categoryAPI) var categoryRepository
    @Dependency(\.workoutAPI) var workoutRepository
    @Dependency(\.dismiss) var dismiss
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .getCategories:
                return .run { send in
                    let categories = categoryRepository.loadCategories()
                    await send(.updateCategories(categories))
                }
            case .updateCategories(let categories):
                state.categories = categories
                return .none
            case .dismissWorkoutCategory:
                return .run { _ in
                    await self.dismiss()
                }
            case .workoutList:
                return .none
            }
        }
        .forEach(\.workoutList, action: \.workoutList) {
            WorkoutListReducer()
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
                        .font(.system(size: 20, weight: .medium))
                        .padding(.leading, 15)
                    ForEachStore(
                        store.scope(state: \.workoutList, action: \.workoutList)
                    ) { rowStore in
                        if rowStore.categoryName.hasPrefix(viewStore.keyword) {
                            NavigationLink {
                                WorkoutListView(store: rowStore)
                            } label: {
                                WorkoutCategorySubview(
                                    category: WorkoutCategoryState(name: rowStore.categoryName)
                                )
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        viewStore.send(.dismissWorkoutCategory)
                    }
                }
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .onAppear {
            if viewStore.categories.isEmpty {
                viewStore.send(.getCategories)
            }
        }
        .tint(.black)
    }
}

