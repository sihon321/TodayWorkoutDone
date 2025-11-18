//
//  MainContentWorkoutView.swift
//  TodayWorkoutDone (iOS)
//
//  Created by ocean on 2022/08/19.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct ExerciseTimeFeature {
    @ObservableState
    struct State: Equatable {
        var exerciseTime: Int = 0
    }
    
    enum Action {
        case fetchExerciseTime(from: Date, to: Date)
        case updateExerciseTime(Int)
    }
    
    @Dependency(\.healthKitManager) private var healthKitManager
    
    var body: Reduce<State, Action> {
        Reduce { state, action in
            switch action {
                case let .fetchExerciseTime(from, to):
                return .run { send in
                    do {
                        let time = try await healthKitManager.getHealthQuantityData(
                            type: .appleExerciseTime,
                            from: from,
                            to: to,
                            unit: .minute()
                        )
                        await send(.updateExerciseTime(Int(time)))
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            case .updateExerciseTime(let exerciseTime):
                state.exerciseTime = exerciseTime
                return .none
            }
        }
    }
}

struct MainContentWorkoutView: View {
    @Bindable var store: StoreOf<ExerciseTimeFeature>
    @ObservedObject var viewStore: ViewStoreOf<ExerciseTimeFeature>
    
    init(store: StoreOf<ExerciseTimeFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("\(viewStore.exerciseTime / 60)")
                .font(.system(size: 22,
                              weight: .bold,
                              design: .default))
                .foregroundStyle(Color.todBlack)
            Text("시간")
                .font(.system(size: 12,
                              weight: .semibold,
                              design: .default))
                .foregroundStyle(Color(0x7d7d7d))
                .padding(.leading, -5)
            Text("\(viewStore.exerciseTime % 60)")
                .font(.system(size: 22,
                              weight: .bold,
                              design: .default))
                .foregroundStyle(Color.todBlack)
                .padding(.leading, -5)
            Text("분")
                .font(.system(size: 12,
                              weight: .semibold,
                              design: .default))
                .foregroundStyle(Color(0x7d7d7d))
                .padding(.leading, -5)
        }
        .onAppear {
            store.send(.fetchExerciseTime(from: .midnight, to: .currentDateForDeviceRegion))
        }
    }
}
