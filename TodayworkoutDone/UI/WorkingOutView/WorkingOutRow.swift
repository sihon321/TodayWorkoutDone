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
    struct State: Equatable {
        var sets: IdentifiedArrayOf<WorkingOutRowViewReducer.State>
        var editMode: EditMode
    }
    
    enum Action {
        case sets(IdentifiedActionOf<WorkingOutRowViewReducer>)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .sets:
                return .none
            }
        }
        .forEach(\.sets, action: \.sets) {
            WorkingOutRowViewReducer()
        }
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
        ForEach(store.scope(state: \.sets, action: \.sets)) { setStore in
            WorkingOutRowView(store: setStore)
        }
    }
}
