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
        case touchedMakeRoutine
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .myRoutineSubview:
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
    
    init(store: StoreOf<MyRoutineReducer>) {
        self.store = store
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("My Routine")
                    .font(.system(size: 20, weight: .medium))
                Spacer()
                Button(action: {
                    store.send(.touchedMakeRoutine)
                }) {
                    HStack {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .foregroundStyle(.white)
                        Text("루틴 추가")
                            .font(.system(size: 15))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 100)
                    .padding(5)
                    .background(Color.personal)
                    .cornerRadius(15)
                }
            }
            .padding(.horizontal, 15)
            if store.myRoutineSubview.isEmpty {
                VStack {
                    Text("루틴 추가를 누르거나 운동을 선택해 루틴을 만드세요.")
                        .font(.system(size: 15))
                        .foregroundColor(Color.grayC3)
                }
                .frame(maxWidth: .infinity,
                       minHeight: 120,
                       alignment: .center)
                .background(Color.contentBackground)
                .cornerRadius(15)
                .padding(.horizontal, 15)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(
                            store.scope(state: \.myRoutineSubview,
                                        action: \.myRoutineSubview)
                        ) { store in
                            Button(action: {
                                store.send(.touchedMyRoutine(store.myRoutine))
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
}

#Preview {
    MyRoutineView(store: Store(initialState: MyRoutineReducer.State(), reducer: {
        MyRoutineReducer()
    }))
}
