//
//  MakeWorkoutView.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/05/17.
//

import SwiftUI
import ComposableArchitecture
import Dependencies

@Reducer
struct MakeWorkoutReducer {
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?

        @Shared var myRoutine: MyRoutine
        var titleSmall: Bool = false
        var selectionWorkouts: [Workout] = []
        var isEdit: Bool = false
        
        var addWorkoutCategory: AddWorkoutCategoryReducer.State
        var workingOutSection: IdentifiedArrayOf<WorkingOutSectionReducer.State>
        
        init(myRoutine: Shared<MyRoutine>,
             isEdit: Bool) {
            self._myRoutine = myRoutine
            self.isEdit = isEdit
            addWorkoutCategory = AddWorkoutCategoryReducer.State(
                myRoutine: myRoutine,
                workoutList: WorkoutListReducer.State(myRoutine: myRoutine)
            )
            let elements = myRoutine.routines.wrappedValue.map {
                WorkingOutSectionReducer.State(
                    routine: $0,
                    editMode: .active
                )
            }
            workingOutSection = IdentifiedArrayOf(
                uniqueElements: elements
            )
        }
    }
    
    enum Action {
        case destination(PresentationAction<Destination.Action>)

        case dismiss(MyRoutine)
        case tappedDone
        case save(MyRoutine)
        case didUpdateText(String)
        
        case addWorkoutCategory(AddWorkoutCategoryReducer.Action)
        case tappedAdd
        
        indirect case workingOutSection(IdentifiedActionOf<WorkingOutSectionReducer>)
    }
    
    @Reducer(state: .equatable)
    enum Destination {
        case addWorkoutCategory(AddWorkoutCategoryReducer)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .dismiss:
                state.destination = .none
                return .none
            default:
                return .none
            }
        }
        .forEach(\.workingOutSection, action: \.workingOutSection) {
            WorkingOutSectionReducer()
        }
    }
}

struct MakeWorkoutView: View {
    @Bindable var store: StoreOf<MakeWorkoutReducer>
    @ObservedObject var viewStore: ViewStoreOf<MakeWorkoutReducer>

    private let gridLayout: [GridItem] = [GridItem(.flexible())]
    
    init(store: StoreOf<MakeWorkoutReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                TextField("타이틀을 입력하세요",
                          text: viewStore.binding(
                            get: \.myRoutine.name,
                            send: MakeWorkoutReducer.Action.didUpdateText
                          ))
                .multilineTextAlignment(.leading)
                .font(.title)
                .accessibilityAddTraits(.isHeader)
                .padding([.leading], 15)
                
                ForEach(store.scope(state: \.workingOutSection, action: \.workingOutSection)) { rowStore in
                    WorkingOutSection(store: rowStore)
                }
                .padding([.bottom], 30)
                
                Button(action: {
                    store.send(.tappedAdd)
                }) {
                    Text("add")
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(.gray)
                        .padding([.leading, .trailing], 15)
                }
                Spacer().frame(height: 100)
            }
            .listStyle(.grouped)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        store.send(.dismiss(store.myRoutine))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if store.isEdit {
                        Button("Save") {
                            store.send(.save(store.myRoutine))
                        }
                    } else {
                        Button("Done") {
                            store.send(.tappedDone)
                        }
                    }
                }
            }
            .fullScreenCover(
                item: $store.scope(state: \.destination?.addWorkoutCategory,
                                   action: \.destination.addWorkoutCategory)
            ) { _ in
                workoutCategoryView(self.store.scope(state: \.addWorkoutCategory,
                                                     action: \.addWorkoutCategory))
            }

        }
    }
    
    func workoutCategoryView(_ store: StoreOf<AddWorkoutCategoryReducer>) -> some View {
        NavigationView {
            ScrollView {
                AddWorkoutCategoryView(store: store)
            }
        }
    }
}
