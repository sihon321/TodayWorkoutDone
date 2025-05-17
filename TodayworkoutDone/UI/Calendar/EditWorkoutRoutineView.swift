//
//  EditWorkoutRoutineView.swift
//  TodayworkoutDone
//
//  Created by ocean on 4/22/25.
//

import SwiftUI
import ComposableArchitecture
import Foundation
import SwiftData

@Reducer
struct EditWorkoutRoutineReducer {
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
        
        var workoutRoutine: WorkoutRoutineState
        var workingOutSection: IdentifiedArrayOf<WorkingOutSectionReducer.State>
        
        init(workoutRoutine: WorkoutRoutineState) {
            self.workoutRoutine = workoutRoutine
            self.workingOutSection = IdentifiedArrayOf(
                uniqueElements: workoutRoutine.routines.map {
                    WorkingOutSectionReducer.State(
                        routine: $0,
                        editMode: .active
                    )
                }
            )
        }
    }
    
    enum Action {
        case tappedAdd
        case didUpdateText(String)
        case save(WorkoutRoutineState)
        case dismiss
        case editStartDate(Date)
        case editEndDate(Date)
        
        case workingOutSection(IdentifiedActionOf<WorkingOutSectionReducer>)
        case destination(PresentationAction<Destination.Action>)
    }
    
    @Reducer(state: .equatable)
    enum Destination {
        case addWorkoutCategory(AddWorkoutCategoryReducer)
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .tappedAdd:
                state.destination = .addWorkoutCategory(
                    AddWorkoutCategoryReducer.State(
                        routines: state.workoutRoutine.routines
                    )
                )
                return .none
            case .didUpdateText(let text):
                state.workoutRoutine.name = text
                return .none
            case .save(let workoutRoutine):
                @Dependency(\.workoutRoutineData.fetch) var fetch
                @Dependency(\.workoutRoutineData.save) var save
                
                if let id = workoutRoutine.persistentModelID {
                    let descriptor = FetchDescriptor<WorkoutRoutine>(
                        predicate: #Predicate { $0.persistentModelID == id }
                    )
                    do {
                        if let updateToWorkoutRoutine = try fetch(descriptor).first {
                            updateToWorkoutRoutine.update(from: workoutRoutine)
                            try save()
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                return .send(.dismiss)
            case .dismiss:
                state.destination = .none
                return .run { _ in
                    await self.dismiss()
                }
            case .editStartDate(let date):
                state.workoutRoutine.startDate = date
                let endDate = state.workoutRoutine.endDate
                let difference = endDate.timeIntervalSince(date)
                state.workoutRoutine.routineTime = Int(difference)
                return .none
            case .editEndDate(let date):
                state.workoutRoutine.endDate = date
                let startDate = state.workoutRoutine.startDate
                let difference = date.timeIntervalSince(startDate)
                state.workoutRoutine.routineTime = Int(difference)
                return .none
            case let .workingOutSection(action):
                switch action {
                case let .element(sectionId, action):
                    switch action {
                    case .tappedAddFooter:
                        if let sectionIndex = state.workingOutSection
                            .index(id: sectionId) {
                            let workoutSet = WorkoutSetState()
                            let index = state.workingOutSection[sectionIndex]
                                .workingOutRow.count
                            state.workingOutSection[sectionIndex]
                                .workingOutRow
                                .append(
                                    WorkingOutRowReducer.State(
                                        index: index + 1,
                                        workoutSet: workoutSet,
                                        editMode: .active
                                    )
                                )
                            state.workoutRoutine
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
                                    state.workoutRoutine
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
                                    state.workoutRoutine
                                        .routines[sectionIndex]
                                        .sets[rowIndex]
                                        .weight = weightValue
                                }
                                return .none
                            case .setFocus, .dismissKeyboard:
                                return .none
                            }
                        }
                    case let .workingOutHeader(action):
                        switch action {
                        case .deleteWorkout:
                            if let sectionIndex = state.workingOutSection
                                .index(id: sectionId) {
                                state.workingOutSection.remove(at: sectionIndex)
                                state.workoutRoutine.routines.remove(at: sectionIndex)
                            }
                            return .none
                        case let .tappedWorkoutsType(type):
                            if let sectionIndex = state.workingOutSection
                                .index(id: sectionId) {
                                state.workoutRoutine
                                    .routines[sectionIndex].equipmentType = type
                            }
                            return .none
                        }
                    case .setEditMode:
                        return .none
                    case let .deleteWorkoutSet(indexSet):
                        if let sectionIndex = state.workingOutSection.index(id: sectionId) {
                            state.workoutRoutine.routines[sectionIndex]
                                .sets.remove(atOffsets: indexSet)
                        }
                        return .none
                    }
                }
            case let .destination(.presented(.addWorkoutCategory(.workoutList(.element(_, .dismiss(routines)))))):
                state.workoutRoutine.routines = routines
                state.workingOutSection = IdentifiedArrayOf(
                    uniqueElements: routines.map {
                        WorkingOutSectionReducer.State(
                            routine: $0,
                            editMode: .active
                        )
                    }
                )
                return .none
            case .destination:
                return .none
            }
        }
    }
}

struct EditWorkoutRoutineView: View {
    @Bindable var store: StoreOf<EditWorkoutRoutineReducer>
    @ObservedObject var viewStore: ViewStoreOf<EditWorkoutRoutineReducer>
    
    init(store: StoreOf<EditWorkoutRoutineReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    TextField("타이틀을 입력하세요",
                              text: viewStore.binding(
                                get: \.workoutRoutine.name,
                                send: EditWorkoutRoutineReducer.Action.didUpdateText
                              ))
                    .multilineTextAlignment(.leading)
                    .font(.title)
                    .accessibilityAddTraits(.isHeader)
                    
                    Spacer()
                    DatePicker("시작시간",
                               selection: viewStore.binding(get: \.workoutRoutine.startDate,
                                                            send: EditWorkoutRoutineReducer.Action.editStartDate),
                               displayedComponents: [.date, .hourAndMinute])
                    DatePicker("종료시간",
                               selection: viewStore.binding(get: \.workoutRoutine.endDate,
                                                            send: EditWorkoutRoutineReducer.Action.editEndDate),
                               displayedComponents: [.date, .hourAndMinute])
                }
                .padding([.leading, .trailing], 15)
                Spacer()
                
                ForEach(store.scope(state: \.workingOutSection,
                                    action: \.workingOutSection)) { rowStore in
                    WorkingOutSection(store: rowStore)
                }
                .padding([.bottom], 30)
                
                Button("워크아웃 추가") {
                    viewStore.send(.tappedAdd)
                }
                .buttonStyle(AddWorkoutButtonStyle())
                Spacer().frame(height: 100)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        viewStore.send(.dismiss)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewStore.send(.save(viewStore.workoutRoutine))
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
