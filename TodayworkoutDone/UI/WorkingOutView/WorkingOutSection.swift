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
        var workingOutRow: IdentifiedArrayOf<WorkingOutRowReducer.State>
        var workingOutHeader: WorkingOutHeaderReducer.State
        
        init(routine: RoutineState, editMode: EditMode) {
            self.id = routine.id
            self.routine = routine
            self.editMode = editMode
            self.workingOutRow = IdentifiedArrayOf(
                uniqueElements: routine.sets.enumerated().map {
                    WorkingOutRowReducer.State(
                        category: routine.workout.category,
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
            case .workingOutRow:
                return .none
            case .setEditMode:
                return .none
            case .workingOutHeader:
                return .none
            case let .deleteWorkoutSet(indexSet):
                state.workingOutRow.remove(atOffsets: indexSet)
                for (index, _) in state.workingOutRow.enumerated() {
                    state.workingOutRow[index].workoutSet.order = index + 1
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
    @ObservedObject var viewStore: ViewStoreOf<WorkingOutSectionReducer>
    
    init(store: StoreOf<WorkingOutSectionReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        VStack {
            WorkingOutHeader(store: store.scope(state: \.workingOutHeader,
                                                action: \.workingOutHeader),
                             equipmentType: .init(wrappedValue: store.routine.equipmentType))
            ForEach(store.scope(state: \.workingOutRow, action: \.workingOutRow)) { rowStore in
                if viewStore.editMode == .active && viewStore.routine.workout.category.categoryType != .stretching {
                    SwipeView(content: {
                        WorkingOutRow(store: rowStore)
                    }, onDelete: {
                        if let index = viewStore.workingOutRow
                            .firstIndex(where: { $0.id == rowStore.id }) {
                            viewStore.send(.deleteWorkoutSet(IndexSet(integer: index)))
                        }
                    })
                } else {
                    WorkingOutRow(store: rowStore)
                }
            }
            if viewStore.editMode == .active && viewStore.routine.workout.category.categoryType != .stretching {
                Button(action: {
                    viewStore.send(.tappedAddFooter)
                }) {
                    WorkingOutFooter()
                }
            } else {
                Spacer()
            }
        }
        .padding(.horizontal, 15)
        .environment(\.editMode, viewStore.binding(get: \.editMode,
                                                   send: WorkingOutSectionReducer.Action.setEditMode))
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

