//
//  MainContentStepView.swift
//  TodayWorkoutDone (iOS)
//
//  Created by ocean on 2022/08/19.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct StepFeature {
    @ObservableState
    struct State: Equatable {
        var stepCount: Int = 0
    }
    
    enum Action {
        case fetchStep(from: Date, to: Date)
        case updateStep(Int)
    }
    
    @Dependency(\.healthKitManager) private var healthKitManager
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                case let .fetchStep(from, to):
                return .run { send in
                    do {
                        let stepCount = try await healthKitManager.getHealthQuantityData(
                            type: .stepCount,
                            from: from,
                            to: to,
                            unit: .count()
                        )
                        await send(.updateStep(stepCount))
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            case .updateStep(let step):
                state.stepCount = step
                return .none
            }
        }
    }
}

struct MainContentStepView: View {
    @Bindable var store: StoreOf<StepFeature>
    @ObservedObject var viewStore: ViewStoreOf<StepFeature>
    
    init(store: StoreOf<StepFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("\(viewStore.stepCount)")
                .font(.system(size: 22,
                              weight: .bold,
                              design: .default))
                .foregroundStyle(.black)
            Text("걸음")
                .font(.system(size: 12,
                              weight: .semibold,
                              design: .default))
                .foregroundColor(Color(0x7d7d7d))
                .padding(.leading, -5)
        }
        .onAppear {
            store.send(.fetchStep(from: .midnight, to: .currentDateForDeviceRegion))
        }
    }
}
