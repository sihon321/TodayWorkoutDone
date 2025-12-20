//
//  CountdownTimerView.swift
//  TodayworkoutDone
//
//  Created by ocean on 5/21/25.
//

import SwiftUI
import ComposableArchitecture
import UIKit

@Reducer
struct CountdownTimerReducer {
    @ObservableState
    struct State: Equatable {
        var totalTime: Int = 0
        var timeRemaining: Int = 0
        var isRunning: Bool = false
        
        init(totalTime: Int) {
            if totalTime == 0 {
                self.totalTime = 100
            } else {
                self.totalTime = totalTime
            }
            self.timeRemaining = totalTime
        }
    }
    
    enum Action {
        case start
        case stop
        case tick
        case onAppear
        case terminate
        case calculateTimeRemaining(Int)
    }
    
    private enum CancelID { case restTimer }
    @Dependency(\.continuousClock) var clock
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isRunning = true
                return .send(.start)

            case .start:
                return .run { send in
                    for await _ in self.clock.timer(interval: .seconds(1)) {
                        await send(.tick, animation: .default)
                    }
                }
                .cancellable(id: CancelID.restTimer, cancelInFlight: true)

            case .stop:
                state.isRunning = false
                return .cancel(id: CancelID.restTimer)

            case .tick:
                guard state.isRunning else { return .none }
                if state.timeRemaining > 0 {
                    state.timeRemaining -= 1
                } else {
                    state.isRunning = false
                    return .merge(
                        .cancel(id: CancelID.restTimer),
                        .run { _ in
                            let generator = await UINotificationFeedbackGenerator()
                            await generator.notificationOccurred(.success)
                        }
                    )
                }
                return .none
                
            case .terminate:
                state.timeRemaining = 0
                return .none
            case let .calculateTimeRemaining(seconds):
                state.timeRemaining -= seconds
                if state.timeRemaining < 0 {
                    state.timeRemaining = 0
                }
                return .none
            }
        }
    }
}

struct CountdownTimerView: View {
    @Bindable var store: StoreOf<CountdownTimerReducer>
    
    init(store: StoreOf<CountdownTimerReducer>) {
        self.store = store
    }

    var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color(uiColor: .secondarySystemFill))
                    .frame(width: 100, height: 25)
                Rectangle()
                    .fill(Color.personal.opacity(0.6))
                    .frame(width: 100, height: 25)
                    .cornerRadius(6.5)
                Rectangle()
                    .fill(Color.personal)
                    .frame(
                        width: CGFloat(store.timeRemaining) / CGFloat(store.totalTime) * 100,
                        height: 25
                    )
                    .cornerRadius(6.5)
                    .animation(.linear(duration: 1.0), value: store.timeRemaining)
                Text("\(store.timeRemaining.secondToHMS)")
                    .font(.system(size: 13))
                    .foregroundStyle(.white)
                    .monospacedDigit()
                    .frame(width: 100)
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

