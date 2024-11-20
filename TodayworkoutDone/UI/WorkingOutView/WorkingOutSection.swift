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
    struct State: Equatable {
        var routines: [Routine]
        var editMode: EditMode
        var workingOutRow = WorkingOutRowReducer.State()
    }
    
    enum Action {
        case tappedAddFooter(Routine)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .tappedAddFooter(let routine):
                state.routines.first(where: { $0.id == routine.id})?.sets.append(Sets())
                return .none
            }
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
        ForEach(viewStore.routines) { routine in
            Section {
                List {
                    ForEach(routine.sets) { sets in
                        WorkingOutRow(sets: .constant(sets),
                                      editMode: .constant(viewStore.editMode))
                            .padding(.bottom, 2)
                    }
                    .onDelete { indexSet in
                        deleteItems(atOffsets: indexSet)
                    }
                }
                .frame(minHeight: minRowHeight * CGFloat(routine.sets.count))
                .listStyle(PlainListStyle())
            } header: {
                WorkingOutHeader(routine: .constant(routine))
            } footer: {
                WorkingOutFooter()
                    .onTapGesture {
                        viewStore.send(.tappedAddFooter(routine))
                    }
            }
        }
    }
    
    func deleteItems(atOffsets offset: IndexSet) {
//        store.routine.sets.remove(atOffsets: offset)
    }
}
