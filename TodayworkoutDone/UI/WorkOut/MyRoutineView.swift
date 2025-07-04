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
        case touchedMakeRoutine
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .myRoutineSubview:
                return .none
            case .touchedMyRoutine:
                return .none
            case .touchedMakeRoutine:
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
            HStack {
                Text("My Routine")
                    .font(.system(size: 20, weight: .medium))
                Spacer()
                Button(action: {
                    viewStore.send(.touchedMakeRoutine)
                }) {
                    HStack {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 15, height: 15)
                        Text("루틴 추가")
                            .font(.system(size: 15))
                    }
                    .frame(width: 100)
                    .padding(5)
                    .background(Color(0x7d7d7d))
                    .cornerRadius(15)
                }
            }
            .padding(.horizontal, 15)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(
                        store.scope(state: \.myRoutineSubview,
                                    action: \.myRoutineSubview)
                    ) { store in
                        Button(action: {
                            viewStore.send(.touchedMyRoutine(store.myRoutine))
                        }) {
                            MyRoutineSubview(store: store)
                        }
                    }
                }
                .offset(x: 15)
                .padding(.trailing, 25)
            }
        }
    }
}

#Preview {
    MyRoutineView(store: Store(initialState: MyRoutineReducer.State(), reducer: {
        MyRoutineReducer()
    }))
}
