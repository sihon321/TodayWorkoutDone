//
//  MainContentEnergyBurn.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2/5/24.
//

import SwiftUI
import Combine

struct MainContentEnergyBurn: View {
    @State private var energyBurned: Int = 0
    
    var body: some View {
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
}

extension MainContentEnergyBurn {
//    private var energyBurn: AnyPublisher<Int, Never> {
//        injected.interactors.healthkitInteractor.activeEnergyBurned(
//            from: Calendar.current.date(byAdding: .day,
//                                        value: -1,
//                                        to: .currentDateForDeviceRegion)!,
//            to: .currentDateForDeviceRegion
//        )
//        .replaceError(with: 0)
//        .eraseToAnyPublisher()
//    }
}

#Preview {
    MainContentEnergyBurn()
}
