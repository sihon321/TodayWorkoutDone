//
//  StopWatchView.swift
//  TodayworkoutDone
//
//  Created by ocean on 6/19/25.
//
import SwiftUI
import ComposableArchitecture

@Reducer
struct StopWatchFeature {
    struct State: Equatable {
        var elapsedTime: TimeInterval = 0
        var isRunning = false
        var laps: [TimeInterval] = []
    }

    enum Action: Equatable {
        case start
        case pause
        case reset
        case recordLap
        case ticked
        case close
    }

    enum CancelID { case timer }

    @Dependency(\.continuousClock) var clock
    @Dependency(\.dismiss) var dismiss
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .start:
                state.isRunning = true
                return .run { send in
                    for await _ in self.clock.timer(interval: .milliseconds(10)) {
                        await send(.ticked)
                    }
                }
                .cancellable(id: CancelID.timer)

            case .pause:
                state.isRunning = false
                return .cancel(id: CancelID.timer)

            case .reset:
                state = State()
                return .cancel(id: CancelID.timer)

            case .recordLap:
                state.laps.append(state.elapsedTime)
                return .none

            case .ticked:
                guard state.isRunning else { return .none }
                state.elapsedTime += 0.01
                return .none
            case .close:
                return .run { _ in
                    await self.dismiss()
                }
            }
        }
    }
}

struct StopWatchView: View {
    let store: StoreOf<StopWatchFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 20) {
                Text(formatted(time: viewStore.elapsedTime))
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .padding(.top, 40)

                HStack(spacing: 20) {
                    Button("Reset") {
                        viewStore.send(.reset)
                    }
                    .disabled(viewStore.elapsedTime == 0)

                    Button(viewStore.isRunning ? "Pause" : "Start") {
                        viewStore.send(viewStore.isRunning ? .pause : .start)
                    }

                    Button("Lap") {
                        viewStore.send(.recordLap)
                    }
                    .disabled(!viewStore.isRunning)
                }
                .font(.title2)

                List(viewStore.laps.indices.reversed(), id: \.self) { index in
                    let lapTime = viewStore.laps[index]
                    Text("Lap \(viewStore.laps.count - index): \(formatted(time: lapTime))")
                        .font(.system(.body, design: .monospaced))
                }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("close") {
                        viewStore.send(.close)
                    }
                }
            }
        }
    }

    private func formatted(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time - floor(time)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
}

#Preview {
    StopWatchView(store: .init(initialState: StopWatchFeature.State()) {
        StopWatchFeature()
    })
}
