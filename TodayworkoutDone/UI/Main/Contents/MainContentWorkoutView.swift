//
//  MainContentWorkoutView.swift
//  TodayWorkoutDone (iOS)
//
//  Created by ocean on 2022/08/19.
//

import SwiftUI
import Combine
import Dependencies

struct MainContentWorkoutView: View {
    @Dependency(\.healthKitManager) private var healthKitManager
    
    @State private var exerciseTime: Int = 0
    @State var cancellables: Set<AnyCancellable> = []
    
    private var hour: Int {
        return exerciseTime / 60
    }
    private var minute: Int {
        return exerciseTime % 60
    }
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("\(hour)")
                .font(.system(size: 22,
                              weight: .bold,
                              design: .default))
            Text("시간")
                .font(.system(size: 12,
                              weight: .semibold,
                              design: .default))
                .foregroundColor(Color(0x7d7d7d))
                .padding(.leading, -5)
            Text("\(minute)")
                .font(.system(size: 22,
                              weight: .bold,
                              design: .default))
                .padding(.leading, -5)
            Text("분")
                .font(.system(size: 12,
                              weight: .semibold,
                              design: .default))
                .foregroundColor(Color(0x7d7d7d))
                .padding(.leading, -5)
        }
        .onAppear {
            healthKitManager.appleExerciseTime(
                from: Calendar.current.date(byAdding: .day,
                                            value: -1,
                                            to: .currentDateForDeviceRegion)!,
                to: .currentDateForDeviceRegion
            )
            .replaceError(with: 0)
            .sink(receiveValue: { appleExerciseTime in
                self.exerciseTime = appleExerciseTime
            })
            .store(in: &cancellables)
        }
    }
}
