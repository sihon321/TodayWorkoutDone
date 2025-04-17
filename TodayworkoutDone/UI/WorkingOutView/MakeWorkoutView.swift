//
//  MakeWorkoutView.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/05/17.
//

import SwiftUI
import ComposableArchitecture
import Dependencies
import SwiftData

@Reducer
struct MakeWorkoutReducer {
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?

        var myRoutine: MyRoutineState
        var isEdit: Bool = false
        
        var changedTypes: [Int: EquipmentType] = [:]
        var workingOutSection: IdentifiedArrayOf<WorkingOutSectionReducer.State>
        
        init(myRoutine: MyRoutineState,
             isEdit: Bool) {
            self.myRoutine = myRoutine
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
        case tappedDone(MyRoutineState)
        case save(MyRoutineState)
        case didUpdateText(String)

        case tappedAdd
        case destination(PresentationAction<Destination.Action>)
        case workingOutSection(IdentifiedActionOf<WorkingOutSectionReducer>)
    }
    
    @Reducer(state: .equatable)
    enum Destination {
        case addWorkoutCategory(AddWorkoutCategoryReducer)
    }
    
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
                @Dependency(\.myRoutineData.fetch) var fetch
                @Dependency(\.myRoutineData.save) var save
                
                if let id = myRoutine.persistentModelID {
                    let descriptor = FetchDescriptor<MyRoutine>(
                        predicate: #Predicate { $0.persistentModelID == id }
                    )
                    do {
                        if let updateToMyRoutine = try fetch(descriptor).first {
                            updateToMyRoutine.update(from: myRoutine)
                            try save()
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                return .send(.dismissMakeWorkout)
                
            case .didUpdateText(let text):
                state.myRoutine.name = text
                return .none

            case .tappedAdd:
                state.destination = .addWorkoutCategory(
                    AddWorkoutCategoryReducer.State(
                        myRoutine: state.myRoutine
                    )
                )
                return .none
            case let .destination(.presented(.addWorkoutCategory(.workoutList(.element(_, .dismiss(myRoutine)))))):
                state.myRoutine = myRoutine
                state.workingOutSection = IdentifiedArrayOf(
                    uniqueElements: myRoutine.routines.map {
                        WorkingOutSectionReducer.State(
                            routine: $0,
                            editMode: .active
                        )
                    }
                )
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
                            let workoutSet = WorkoutSetState()
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
                                state.workingOutSection.remove(at: sectionIndex)
                                state.myRoutine.routines.remove(at: sectionIndex)
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
                    case .deleteWorkoutSet:
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
                    viewStore.send(.tappedAdd)
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
                        viewStore.send(.dismissMakeWorkout)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if store.isEdit {
                        Button("Save") {
                            viewStore.send(.save(viewStore.myRoutine))
                        }
                    } else {
                        Button("Done") {
                            viewStore.send(.tappedDone(viewStore.myRoutine))
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
            .tint(.black)
        }
    }
    
}
