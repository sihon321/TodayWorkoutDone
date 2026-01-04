//
//  WorkingOutSection.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/02/13.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct WorkingOutSectionReducer {
    @ObservableState
    struct State: Equatable, Identifiable {
        let id: UUID
        var editMode: EditMode
        var routine: RoutineState
        var categoryType: WorkoutCategoryState.WorkoutCategoryType
        var workingOutRow: IdentifiedArrayOf<WorkingOutRowReducer.State>
        var workingOutHeader: WorkingOutHeaderReducer.State
        
        init(routine: RoutineState, editMode: EditMode) {
            self.id = routine.id
            self.routine = routine
            self.editMode = editMode
            let type = WorkoutCategoryState.WorkoutCategoryType(rawValue: routine.workout.categoryName) ?? .strength
            self.categoryType = type
            self.workingOutRow = IdentifiedArrayOf(
                uniqueElements: routine.sets.enumerated().map {
                    WorkingOutRowReducer.State(
                        categoryType: type,
                        workoutSet: $0.element,
                        editMode: editMode
                    )
                }
            )
            self.workingOutHeader = WorkingOutHeaderReducer.State(
                routine: routine,
                editMode: editMode
            )
        }
        
        mutating func toggleEditMode() {
            if editMode == .active {
                editMode = .inactive
            } else {
                editMode = .active
            }
            for index in workingOutRow.indices {
                workingOutRow[index].editMode = editMode
            }
            workingOutHeader.editMode = editMode
        }
    }
    
    enum Action {
        case tappedAddFooter
        case setEditMode(EditMode)
        case deleteWorkoutSet(IndexSet)
        
        case workingOutRow(IdentifiedActionOf<WorkingOutRowReducer>)
        case workingOutHeader(WorkingOutHeaderReducer.Action)
    }
    
    @Dependency(\.continuousClock) var clock
    
    var body: some Reducer<State, Action> {
        Scope(state: \.workingOutHeader, action: \.workingOutHeader) {
            WorkingOutHeaderReducer()
        }
        Reduce { state, action in
            switch action {
            case .tappedAddFooter:
                return .none
            case .workingOutRow(let action):
                switch action {
                case let .element(rowId, action):
                    switch action {
                    case .touchState(_):
                        var order = 0
                        for (index, _) in state.workingOutRow.enumerated() {
                            if state.workingOutRow[index].workoutSet.setState == .set {
                                order += 1
                                state.workingOutRow[index].workoutSet.order = order
                            } else {
                                state.workingOutRow[index].workoutSet.order = 0
                            }
                        }
                        return .none
                    default:
                        return .none
                    }
                }
            case .setEditMode:
                return .none
            case .workingOutHeader:
                return .none
            case let .deleteWorkoutSet(indexSet):
                state.workingOutRow.remove(atOffsets: indexSet)
                var order = 0
                for (index, _) in state.workingOutRow.enumerated() {
                    if state.workingOutRow[index].workoutSet.setState == .set {
                        order += 1
                        state.workingOutRow[index].workoutSet.order = order
                    }
                }
                return .none
            }
        }
        .forEach(\.workingOutRow, action: \.workingOutRow) {
            WorkingOutRowReducer()
        }
    }
}

struct WorkingOutSection: View {
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    @Bindable var store: StoreOf<WorkingOutSectionReducer>
    
    init(store: StoreOf<WorkingOutSectionReducer>) {
        self.store = store
    }
    
    var body: some View {
        VStack {
            WorkingOutHeader(store: store.scope(state: \.workingOutHeader,
                                                action: \.workingOutHeader),
                             equipmentType: .init(wrappedValue: store.routine.equipmentType))
            ForEach(store.scope(state: \.workingOutRow, action: \.workingOutRow)) { rowStore in
                if store.editMode == .active && store.categoryType != .stretching {
                    SwipeView(content: {
                        WorkingOutRow(store: rowStore)
                    }, onDelete: {
                        if let index = store.workingOutRow
                            .firstIndex(where: { $0.id == rowStore.id }) {
                            store.send(.deleteWorkoutSet(IndexSet(integer: index)))
                        }
                    })
                } else {
                    WorkingOutRow(store: rowStore)
                }
            }
            if store.editMode == .active && store.categoryType != .stretching {
                Button(action: {
                    store.send(.tappedAddFooter)
                }) {
                    WorkingOutFooter()
                }
                Spacer().frame(height: 15)
            } else {
                Spacer()
            }
        }
        .padding(.horizontal, 15)
        .environment(\.editMode, Binding(
            get: { store.editMode },
            set: { store.send(.setEditMode($0)) }
        ))
    }
}

#Preview {
    let myRoutine = MyRoutineState(model: MyRoutine.mockedData)
    WorkingOutSection(
        store: Store(initialState: WorkingOutSectionReducer.State(routine: myRoutine.routines.first!, editMode: .inactive)) {
            WorkingOutSectionReducer()
        }
    )
}

