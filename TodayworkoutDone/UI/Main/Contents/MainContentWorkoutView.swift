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
        case fetchExerciseTime
        case updateExerciseTime(Int)
    }
    
    @Dependency(\.healthKitManager) private var healthKitManager
    
    var body: Reduce<State, Action> {
        Reduce { state, action in
            switch action {
                case .fetchExerciseTime:
                return .run { send in
                    do {
                        let time = try await healthKitManager.getHealthQuantityData(
                            type: .appleExerciseTime,
                            from: .midnight,
                            to: .currentDateForDeviceRegion,
                            unit: .minute()
                        )
                        await send(.updateExerciseTime(time))
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
            Text("\(store.exerciseTime / 60)")
                .font(.system(size: 22,
                              weight: .bold,
                              design: .default))
                .foregroundStyle(.black)
            Text("시간")
                .font(.system(size: 12,
                              weight: .semibold,
                              design: .default))
                .foregroundColor(Color(0x7d7d7d))
                .padding(.leading, -5)
            Text("\(store.exerciseTime % 60)")
                .font(.system(size: 22,
                              weight: .bold,
                              design: .default))
                .foregroundStyle(.black)
                .padding(.leading, -5)
            Text("분")
                .font(.system(size: 12,
                              weight: .semibold,
                              design: .default))
                .foregroundColor(Color(0x7d7d7d))
                .padding(.leading, -5)
        }
        .onAppear {
            store.send(.fetchExerciseTime)
        }
    }
}
