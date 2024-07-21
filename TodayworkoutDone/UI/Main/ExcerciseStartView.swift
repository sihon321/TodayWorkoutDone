//
//  ExcerciseStartView.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/03/19.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct ExcerciseStarter {
    @ObservableState
    struct State: Equatable {
        var isWorkoutPresented = false
        var workoutPresent = WorkoutPresent.State()
    }
    
    enum Action {
        case setSheet(isPresented: Bool)
        case workoutPresent(WorkoutPresent.Action)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .setSheet(let isPresented):
                state.isWorkoutPresented = isPresented
                return .none
            case .workoutPresent(.dismiss):
                state.isWorkoutPresented = false
                return .none
            }
        }
    }
}

struct ExcerciseStartView: View {
    @Bindable var store: StoreOf<ExcerciseStarter>

    var body: some View {
        VStack {
            Spacer()
            Button(action: {
                store.send(.setSheet(isPresented: true))
            }) {
                Text("워크아웃 시작")
                    .frame(minWidth: 0, maxWidth: .infinity - 30)
                    .padding([.top, .bottom], 5)
                    .background(Color(0xfeb548))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0,
                                                style: .continuous))
            }
            .padding(.horizontal, 30)
            .fullScreenCover(isPresented: $store.isWorkoutPresented.sending(\.setSheet)) {
                WorkoutView(
                    store: Store(
                        initialState: WorkoutReducer.State()) {
                            WorkoutReducer()
                        },
                    presentStore: store.scope(state: \.workoutPresent,
                                              action: \.workoutPresent))
            }
            .offset(y: -15)
        }
    }
}

#Preview {
    NavigationStack {
        let state = ExcerciseStarter.State()
        let store = Store(initialState: state, reducer: { ExcerciseStarter() })
        ExcerciseStartView(store: store)
    }
}

