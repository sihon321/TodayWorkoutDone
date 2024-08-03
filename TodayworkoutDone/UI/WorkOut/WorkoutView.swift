//
//  WorkoutCategoryView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/25.
//

import SwiftUI
import Combine
import ComposableArchitecture

@Reducer
struct WorkoutPresent {
    enum Action {
        case dismiss
    }
}

@Reducer
struct WorkoutReducer {
    @ObservableState
    struct State: Equatable {
        var workoutsList: [Workout] = []
        var keyword: String = ""
        var workoutCategory = WorkoutCategoryReducer.State()
    }
    
    enum Action {
        case search(keyword: String)
        case workoutCategory(WorkoutCategoryReducer.Action)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .search(let keyword):
                state.keyword = keyword
                return .none
            case .workoutCategory(.setText(let keyword)):
                state.workoutCategory.keyword = keyword
                return .none
            }
        }
    }
}

struct WorkoutView: View {
    @Bindable var store: StoreOf<WorkoutReducer>
    @ObservedObject var viewStore: ViewStoreOf<WorkoutReducer>
    @Bindable var presentStore: StoreOf<WorkoutPresent>
    
    @Environment(\.injected) private var injected: DIContainer
    
    @State private var workoutsList: Loadable<LazyList<Workout>> = .notRequested
    @State private var routingState: Routing = .init()
    
    init(store: StoreOf<WorkoutReducer>,
         presentStore: StoreOf<WorkoutPresent>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
        self.presentStore = presentStore
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    MyWorkoutView(workoutsList: $workoutsList)
                        .padding(.top, 10)
                    WorkoutCategoryView(
                        store: store.scope(state: \.workoutCategory,
                                           action: \.workoutCategory),
                        workoutsList: workoutsList,
                        selectWorkouts: injected.appState[\.userData].selectionWorkouts)
                    .inject(injected)
                    .padding(.top, 10)
                }
            }
            .background(Color(0xf4f4f4))
            .navigationBarTitle("workout", displayMode: .inline)
            .toolbar(content: {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        presentStore.send(.dismiss)
                    }, label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    })
                }
            })
        }
        .searchable(text: viewStore.binding(
            get: { $0.keyword },
            send: { WorkoutReducer.Action.search(keyword: $0) }
        ))
        .onReceive(routingUpdate) { self.routingState = $0 }
        .onAppear {
            injected.appState[\.userData.selectionWorkouts].removeAll()
        }
    }
}

extension WorkoutView {
    func reloadWorkouts() {
        injected.interactors.workoutInteractor
            .load(workouts: $workoutsList)
    }
}

extension WorkoutView {
    struct Routing: Equatable {
        var workoutCategoryView: Bool = false
    }
}

private extension WorkoutView {
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.workoutView)
    }
}


//struct WorkoutView_Previews: PreviewProvider {
//    static var previews: some View {
//        WorkoutView(store: Store(initialState: WorkoutReducer.State()) {
//            WorkoutReducer()
//        })
//        .background(Color.gray)
//    }
//}
