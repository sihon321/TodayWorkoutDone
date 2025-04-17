//
//  MyWorkoutView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct MyRoutineReducer {
    @ObservableState
    struct State: Equatable {
        var text: String = ""
        var myRoutineSubview: IdentifiedArrayOf<MyRoutineSubviewReducer.State> = []
        var selectedRoutine: MyRoutineState?
    }
    
    enum Action {
        case myRoutineSubview(IdentifiedActionOf<MyRoutineSubviewReducer>)
        case touchedMyRoutine(MyRoutineState)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .myRoutineSubview:
                return .none
            case .touchedMyRoutine:
                return .none
            }
        }
        .forEach(\.myRoutineSubview, action: \.myRoutineSubview) {
            MyRoutineSubviewReducer()
        }
    }
}

struct MyRoutineView: View {
    @Bindable var store: StoreOf<MyRoutineReducer>
    @ObservedObject var viewStore: ViewStoreOf<MyRoutineReducer>
    
    init(store: StoreOf<MyRoutineReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("My Routine")
                .font(.system(size: 20, weight: .medium))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(store.scope(state: \.myRoutineSubview,
                                        action: \.myRoutineSubview)) { store in
                        Button(action: {
                            viewStore.send(.touchedMyRoutine(store.myRoutine))
                        }) {
                            MyRoutineSubview(store: store)
                        }
                    }
                }
            }
        }
        .padding([.leading, .trailing], 15)
    }
}
