//
//  MainContentEnergyBurn.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2/5/24.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct EnergyBurnFeature {
    @ObservableState
    struct State: Equatable {
        var energyBurned: Int = 0
    }
    
    enum Action {
        case fetchEnergyBurned(from: Date, to: Date)
        case updateEnergyBurned(Int)
    }
    
    @Dependency(\.healthKitManager) private var healthKitManager
    
    var body: Reduce<State, Action> {
        Reduce { state, action in
            switch action {
                case let .fetchEnergyBurned(from, to):
                return .run { send in
                    do {
                        let energy = try await healthKitManager.getHealthQuantityData(
                            type: .activeEnergyBurned,
                            from: from,
                            to: to,
                            unit: .kilocalorie()
                        )
                        await send(.updateEnergyBurned(Int(energy)))
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            case .updateEnergyBurned(let energyBurned):
                state.energyBurned = energyBurned
                return .none
            }
        }
    }
}

struct MainContentEnergyBurn: View {
    @Bindable var store: StoreOf<EnergyBurnFeature>
    @ObservedObject var viewStore: ViewStoreOf<EnergyBurnFeature>
    
    init(store: StoreOf<EnergyBurnFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        HStack {
            Text("\(viewStore.energyBurned)")
                .font(.system(size: 22,
                              weight: .bold,
                              design: .default))
                .foregroundStyle(Color.todBlack)
            Text("kcal")
                .font(.system(size: 12,
                              weight: .semibold,
                              design: .default))
                .foregroundStyle(Color(0x7d7d7d))
                .padding(.leading, -5)
                .padding(.top, 2)
        }
        .onAppear {
            store.send(.fetchEnergyBurned(from: .midnight, to: .currentDateForDeviceRegion))
        }
    }
}
