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
        var routines: [RoutineState] = []
        var keyword: String = ""
        
        var workoutList: IdentifiedArrayOf<WorkoutListReducer.State>

        init(routines: [RoutineState],
             keyword: String = "",
             workoutList: IdentifiedArrayOf<WorkoutListReducer.State> = []) {
            self.routines = routines
            self.keyword = keyword
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
                state.workoutList = IdentifiedArrayOf(
                    uniqueElements: categories.compactMap {
                        WorkoutListReducer.State(isAddWorkoutPresented: true,
                                                 routines: state.routines,
                                                 categoryName: $0.name)
                    }
                )
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
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(
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
                    Button(action: {
                        viewStore.send(.dismissWorkoutCategory)
                    }, label: {
                        Image(systemName: "xmark")
                    })
                }
            }
            .navigationTitle("Category")
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .onAppear {
            viewStore.send(.getCategories)
        }
        .tint(.todBlack)
    }
}

