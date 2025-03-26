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
        var routine: Routine
        var workingOutRow: IdentifiedArrayOf<WorkingOutRowReducer.State>
        let workingOutHeader: WorkingOutHeaderReducer.State
        
        init(routine: Routine, editMode: EditMode) {
            self.id = routine.id
            self.routine = routine
            self.editMode = editMode
            self.workingOutRow = IdentifiedArrayOf(
                uniqueElements: routine.sets.map {
                    WorkingOutRowReducer.State(workoutSet: $0,
                                               editMode: editMode)
                }
            )
            self.workingOutHeader = WorkingOutHeaderReducer.State(
                workoutName: routine.workout.name,
                workoutType: routine.workoutsType
            )
        }
    }
    
    enum Action {
        case tappedAddFooter
        case setEditMode(EditMode)
        
        indirect case workingOutRow(IdentifiedActionOf<WorkingOutRowReducer>)
        case workingOutHeader(WorkingOutHeaderReducer.Action)
    }
    
    var body: some Reducer<State, Action> {
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
        Section {
            List {
                ForEach(store.scope(state: \.workingOutRow, action: \.workingOutRow)) { rowStore in
                    WorkingOutRow(store: rowStore)
                        .padding(.bottom, 2)
                }
                .onDelete { indexSet in
                    deleteItems(atOffsets: indexSet)
                }
            }
            .frame(minHeight: minRowHeight * CGFloat(store.workingOutRow.count))
            .listStyle(PlainListStyle())
        } header: {
            WorkingOutHeader(store: store.scope(state: \.workingOutHeader,
                                                action: \.workingOutHeader),
                             type: .init(wrappedValue: store.routine.workoutsType))
            
        } footer: {
            if viewStore.editMode == .active {
                WorkingOutFooter()
                    .onTapGesture {
                        store.send(.tappedAddFooter)
                    }
            }
        }
        .environment(\.editMode, viewStore.binding(get: \.editMode, send: WorkingOutSectionReducer.Action.setEditMode))
    }
    
    func deleteItems(atOffsets offset: IndexSet) {
        store.routine.sets.remove(atOffsets: offset)
    }
}

#Preview {
    let workingOutRowStores = WorkoutSet.mockedData.map {
        WorkingOutRowReducer.State(workoutSet: $0)
    }
    Section {
        List {
            ForEach(workingOutRowStores) { state in
                WorkingOutRow(store: Store(initialState: state){
                    WorkingOutRowReducer()
                })
            }
        }
        .listStyle(PlainListStyle())
    } header: {
        WorkingOutHeader(store: Store(
            initialState: WorkingOutHeaderReducer.State(workoutName: "test",
                                                        workoutType: .barbel)
        ) {
            WorkingOutHeaderReducer()
        }, type: .init(initialValue: .barbel))
    }
}
