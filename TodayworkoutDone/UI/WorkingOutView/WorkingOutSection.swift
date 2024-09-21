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
        var routine: Routine
        var editMode: EditMode
    }
    
    enum Action {
        
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                
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
        VStack {
            Section {
                List {
                    ForEach(viewStore.routine.sets) { sets in
                        WorkingOutRow(sets: .constant(sets),
                                      editMode: .constant(viewStore.editMode))
                            .padding(.bottom, 2)
                    }
                    .onDelete { indexSet in
                        deleteItems(atOffsets: indexSet)
                    }
                }
                .frame(minHeight: minRowHeight * CGFloat(viewStore.routine.sets.count))
                .listStyle(PlainListStyle())
            } header: {
                WorkingOutHeader(routine: .constant(viewStore.routine))
            } footer: {
                WorkingOutFooter()
                    .onTapGesture {
                        viewStore.routine.sets.append(Sets())
                    }
            }
        }
    }
    
    func deleteItems(atOffsets offset: IndexSet) {
        store.routine.sets.remove(atOffsets: offset)
    }
}
