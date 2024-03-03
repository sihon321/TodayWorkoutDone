//
//  MainContentStepView.swift
//  TodayWorkoutDone (iOS)
//
//  Created by ocean on 2022/08/19.
//

import SwiftUI
import Combine

struct MainContentStepView: View {
    @Environment(\.injected) private var injected: DIContainer
    @State private var step: Int = 0
    
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
        .onReceive(stepCount) { step in
            self.step = step
        }
    }
}

extension MainContentStepView {
    private var stepCount: AnyPublisher<Int, Never> {
        injected.interactors.healthkitInteractor.stepCount(
            from: Calendar.current.date(byAdding: .day,
                                        value: -1,
                                        to: .currentDateForDeviceRegion)!,
            to: .currentDateForDeviceRegion
        )
        .replaceError(with: 0)
        .eraseToAnyPublisher()
    }
}

struct MainContentStepView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentStepView()
    }
}
