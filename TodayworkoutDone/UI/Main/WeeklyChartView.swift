//
//  WeeklyChartView.swift
//  TodayWorkoutDone (iOS)
//
//  Created by ocean on 2022/08/05.
//

import SwiftUI
import Combine
import Charts

struct WeeklyChartView: View {
    @Environment(\.injected) private var injected: DIContainer
    @State private var exerciseTime: Int = 0
    
    struct Weekly: Identifiable {
        var id = UUID()
        let day: String
        let profit: Double
    }
    
    let data: [Weekly] = [
        Weekly(day: "mon", profit: 40.0),
        Weekly(day: "tue", profit: 50.0),
        Weekly(day: "wed", profit: 30.0),
        Weekly(day: "thu", profit: 70.0),
        Weekly(day: "fri", profit: 100.0),
        Weekly(day: "sat", profit: 90.0),
        Weekly(day: "sun", profit: 80.0)
    ]
    
    var body: some View {
        VStack {
            Text("")
            Chart(data) {
                BarMark(
                    x: .value("Weekly", $0.day),
                    y: .value("Profit", $0.profit)
                )
                .foregroundStyle(Color(0xfeb548))
            }
        }
        .frame(minWidth: 0,
               maxWidth: .infinity,
               minHeight: 165)
    }
}

extension WeeklyChartView {
    private var appleExerciseTime: AnyPublisher<Int, Never> {
        var dateComponents = DateComponents()
        dateComponents.weekOfYear = -1
        return injected.interactors.healthkitInteractor.appleExerciseTime(
            from: Calendar.current.date(byAdding: .day,
                                        value: -1,
                                        to: .currentDateForDeviceRegion)!,
            to: .currentDateForDeviceRegion
        )
            .replaceError(with: 0)
            .eraseToAnyPublisher()
    }
}

struct WeeklyChartView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyChartView()
    }
}
