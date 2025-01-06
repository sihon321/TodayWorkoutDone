//
//  MainContentEnergyBurn.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2/5/24.
//

import SwiftUI
import Combine
import Dependencies

struct MainContentEnergyBurn: View {
    @Dependency(\.healthKitManager) private var healthKitManager
    
    @State private var energyBurned: Int = 0
    @State var cancellables: Set<AnyCancellable> = []
    
    var body: some View {
        HStack {
            Text("\(energyBurned)")
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
            healthKitManager.getHealthQuantityData(
                type: .activeEnergyBurned,
                from: .midnight,
                to: .currentDateForDeviceRegion
            )
            .replaceError(with: 0)
            .sink(receiveValue: { energyBurned in
                self.energyBurned = energyBurned
            })
            .store(in: &cancellables)
        }
    }
}
