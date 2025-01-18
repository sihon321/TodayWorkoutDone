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
        case fetchEnergyBurned
        case updateEnergyBurned(Int)
    }
    
    @Dependency(\.healthKitManager) private var healthKitManager
    
    var body: Reduce<State, Action> {
        Reduce { state, action in
            switch action {
                case .fetchEnergyBurned:
                return .run { send in
                    do {
                        let energy = try await healthKitManager.getHealthQuantityData(
                            type: .activeEnergyBurned,
                            from: .midnight,
                            to: .currentDateForDeviceRegion,
                            unit: .kilocalorie()
                        )
                        await send(.updateEnergyBurned(energy))
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
            Text("kcal")
                .font(.system(size: 12,
                              weight: .semibold,
                              design: .default))
                .foregroundColor(Color(0x7d7d7d))
                .padding(.leading, -5)
        }
        .onAppear {
            store.send(.fetchEnergyBurned)
        }
    }
}
