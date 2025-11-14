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
        case complete
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
            case .close, .complete:
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
            NavigationStack {
                VStack {
                    Text(formatted(time: viewStore.elapsedTime))
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .padding(.top, 40)

                    HStack(spacing: 20) {
                        Spacer()
                        Button(action: {
                            viewStore.send(.reset)
                        }, label: {
                            TitledImageView(systemImageName: "clock.arrow.trianglehead.counterclockwise.rotate.90",
                                            title: "reset",
                                            padding: 15)
                        })
                        .frame(width: 65, height: 85)
                        .disabled(viewStore.elapsedTime == 0)
                    
                        Button(action: {
                            viewStore.send(viewStore.isRunning ? .pause : .start)
                        }, label: {
                            viewStore.isRunning ? TitledImageView(systemImageName: "pause",
                                                                  title: "",
                                                                  padding: 25)
                            : TitledImageView(systemImageName: "play.fill",
                                              title: "",
                                              padding: 25)
                        })
                        .frame(width: 105, height: 105)

                        Button(action: {
                            viewStore.send(.recordLap)
                        }, label: {
                            TitledImageView(systemImageName: "arrow.trianglehead.clockwise",
                                            title: "Lap",
                                            padding: 15)
                        })
                        .frame(width: 65, height: 85)
                        .disabled(!viewStore.isRunning)
                        Spacer()
                    }
                    .font(.title2)

                    ScrollView {
                        ForEach(viewStore.laps.indices.reversed(), id: \.self) { index in
                            HStack {
                                Image(systemName: "flag.fill")
                                    .foregroundStyle(Color.personal.opacity(0.5))
                                let lapTime = viewStore.laps[index]
                                Text("Lap \(index + 1)")
                                Spacer()
                                Text("\(formatted(time: lapTime))")
                                    .font(.system(size: 15))
                                let prevLapTime = viewStore.laps[safe: index - 1] ?? 0
                                Spacer()
                                Text("+\(formatted(time: lapTime - prevLapTime))")
                                    .font(.system(size: 15))
                            }
                            .padding()
                            .background(Color.personal.opacity(0.1))
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            viewStore.send(.close)
                        }) {
                            Image(systemName: "xmark")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            viewStore.send(.complete)
                        }) {
                            Text("complete")
                        }
                    }
                }
                .tint(Color.todBlack)
                .background(Color.background)
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

private struct TitledImageView: View {
    let systemImageName: String
    let title: String
    let padding: CGFloat
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: systemImageName)
                .resizable()
                .padding(padding)
                .scaledToFit()
                .foregroundStyle(Color.personal)
                .background(Color.personal.opacity(0.1))
                .clipShape(Circle())
            
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(Color.gray.opacity(0.4))
        }
    }
}

#Preview {
    StopWatchView(store: .init(initialState: StopWatchFeature.State()) {
        StopWatchFeature()
    })
}
