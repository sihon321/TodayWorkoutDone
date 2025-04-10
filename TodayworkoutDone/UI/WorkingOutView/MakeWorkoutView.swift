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

        var myRoutine: MyRoutine
        var titleSmall: Bool = false
        var categories: Categories = []
        var selectionWorkouts: [Workout] = []
        var isEdit: Bool = false
        var deletedSectionIndex: Int?
        var changedTypes: [Int: WorkoutsType] = [:]
        var workingOutSection: IdentifiedArrayOf<WorkingOutSectionReducer.State>
        
        init(myRoutine: MyRoutine,
             categories: Categories,
             isEdit: Bool) {
            self.myRoutine = myRoutine
            self.categories = categories
            self.isEdit = isEdit
            workingOutSection = IdentifiedArrayOf(
                uniqueElements: myRoutine.routines.map {
                    WorkingOutSectionReducer.State(
                        routine: $0,
                        editMode: .active
                    )
                }
            )
        }
    }
    
    enum Action {
        case dismissMakeWorkout
        case tappedDone(MyRoutine)
        case save(MyRoutine)
        case didUpdateText(String)
        
        case tappedAdd
        case destination(PresentationAction<Destination.Action>)
        case workingOutSection(IdentifiedActionOf<WorkingOutSectionReducer>)
    }
    
    @Reducer(state: .equatable)
    enum Destination {
        case addWorkoutCategory(AddWorkoutCategoryReducer)
    }
    
    @Dependency(\.myRoutineData) var myRoutineContext
    @Dependency(\.dismiss) var dismiss
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .dismissMakeWorkout:
                state.destination = .none
                return .run { _ in
                    await self.dismiss()
                }
            case .tappedDone(let myRoutine):
                state.myRoutine = myRoutine
                state.myRoutine.isRunning = true

                return .run { send in
                    await send(.dismissMakeWorkout)
                }
            case .save(let myRoutine):
                if let sectionIndex = state.deletedSectionIndex {
                    state.myRoutine
                        .routines.remove(at: sectionIndex)
                }
                if state.changedTypes.isEmpty == false {
                    for (index, type) in state.changedTypes {
                        state.myRoutine.routines[index].workoutsType = type
                    }
                }
                return .run { send in
                    try myRoutineContext.save()
                    await send(.dismissMakeWorkout)
                }
            case .didUpdateText(let text):
                state.myRoutine.name = text
                return .none
            case .tappedAdd:
                state.destination = .addWorkoutCategory(
                    AddWorkoutCategoryReducer.State(
                        myRoutine: state.myRoutine,
                        workoutList: IdentifiedArrayOf(
                            uniqueElements: state.categories.compactMap {
                                WorkoutListReducer.State(id: UUID(),
                                                         isAddWorkoutPresented: true,
                                                         myRoutine: state.myRoutine,
                                                         categoryName: $0.name,
                                                         categories: state.categories)
                            }
                        )
                    )
                )
                return .none
            case .destination(.presented(.addWorkoutCategory(let action))):
                return .none
            case .destination:
                return .none

            case let .workingOutSection(action):
                switch action {
                case let .element(sectionId, action):
                    switch action {
                    case .tappedAddFooter:
                        if let sectionIndex = state.workingOutSection
                            .index(id: sectionId) {
                            let workoutSet = WorkoutSet()
                            state.workingOutSection[sectionIndex]
                                .workingOutRow
                                .append(
                                    WorkingOutRowReducer.State(workoutSet: workoutSet,
                                                               editMode: .active)
                                )
                            state.myRoutine
                                .routines[sectionIndex]
                                .sets
                                .append(workoutSet)
                        }
                        return .none
                    case let .workingOutRow(action):
                        switch action {
                        case let .element(rowId, action):
                            switch action {
                            case .toggleCheck:
                                return .none
                            case let .typeLab(lab):
                            if let sectionIndex = state.workingOutSection
                                    .index(id: sectionId),
                                   let rowIndex = state.workingOutSection[sectionIndex]
                                    .workingOutRow
                                    .index(id: rowId),
                                   let labValue = Int(lab) {
                                    state.myRoutine
                                        .routines[sectionIndex]
                                        .sets[rowIndex]
                                        .reps = labValue
                                }
                                return .none
                            case let .typeWeight(weight):
                                if let sectionIndex = state.workingOutSection
                                    .index(id: sectionId),
                                   let rowIndex = state.workingOutSection[sectionIndex]
                                    .workingOutRow
                                    .index(id: rowId),
                                   let weightValue = Double(weight) {
                                    state.myRoutine
                                        .routines[sectionIndex]
                                        .sets[rowIndex]
                                        .weight = weightValue
                                }
                                return .none
                            }
                        }
                    case let .workingOutHeader(action):
                        switch action {
                        case .deleteWorkout:
                            if let sectionIndex = state.workingOutSection
                                .index(id: sectionId) {
                                state.deletedSectionIndex = sectionIndex
                                state.workingOutSection.remove(at: sectionIndex)
                            }
                            return .none
                        case let .tappedWorkoutsType(type):
                            if let sectionIndex = state.workingOutSection
                                .index(id: sectionId) {
                                state.changedTypes[sectionIndex] = type
                            }
                            return .none
                        }
                    case .setEditMode:
                        return .none
                    }
                }
            }
        }
        .forEach(\.workingOutSection, action: \.workingOutSection) {
            WorkingOutSectionReducer()
        }
        .ifLet(\.$destination, action: \.destination) {
          Destination.body
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
                
                ForEach(store.scope(state: \.workingOutSection,
                                    action: \.workingOutSection)) { rowStore in
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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        store.send(.dismissMakeWorkout)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if store.isEdit {
                        Button("Save") {
                            store.send(.save(store.myRoutine))
                        }
                    } else {
                        Button("Done") {
                            store.send(.tappedDone(store.myRoutine))
                        }
                    }
                }
            }
            .fullScreenCover(
                item: $store.scope(state: \.destination?.addWorkoutCategory,
                                   action: \.destination.addWorkoutCategory)
            ) { store in
                AddWorkoutCategoryView(store: store)
            }

        }
    }
    
}
