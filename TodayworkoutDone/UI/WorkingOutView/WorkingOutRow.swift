//
//  WorkingOutRow.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/02/13.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct WorkingOutRowReducer {
    @ObservableState
    struct State: Equatable, Identifiable {
        let id: UUID
        var workingOutRowView: WorkingOutRowViewReducer.State
        var editMode: EditMode
        
        init(workoutSet: WorkoutSet = .init(), editMode: EditMode = .inactive) {
            self.id = workoutSet.id
            self.editMode = editMode
            self.workingOutRowView = WorkingOutRowViewReducer.State(workoutSet: workoutSet,
                                                                    editMode: editMode)
        }
    }
    
    enum Action {
        
    }

}

struct WorkingOutRow: View {
    @Bindable var store: StoreOf<WorkingOutRowReducer>
    @ObservedObject var viewStore: ViewStoreOf<WorkingOutRowReducer>
    
    init(store: StoreOf<WorkingOutRowReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        WorkingOutRowView(store: Store(initialState: store.workingOutRowView) {
            WorkingOutRowViewReducer()
        })
    }
}
