//
//  MainContentStepView.swift
//  TodayWorkoutDone (iOS)
//
//  Created by ocean on 2022/08/19.
//

import SwiftUI
import Combine
import Dependencies

struct MainContentStepView: View {
    @State private var step: Int = 0
    @State var cancellables: Set<AnyCancellable> = []
    
    @Dependency(\.healthKitManager) private var healthKitManager
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("\(step)")
                .font(.system(size: 22,
                              weight: .bold,
                              design: .default))
            Text("걸음")
                .font(.system(size: 12,
                              weight: .semibold,
                              design: .default))
                .foregroundColor(Color(0x7d7d7d))
                .padding(.leading, -5)
        }
        .onAppear {
            healthKitManager.stepCount(
                from: .midnight,
                to: .currentDateForDeviceRegion
            )
            .replaceError(with: 0)
            .sink(receiveValue: { stepCount in
                step = stepCount
            })
            .store(in: &cancellables)
        }
    }
}
