//
//  WeeklyChartView.swift
//  TodayWorkoutDone (iOS)
//
//  Created by ocean on 2022/08/05.
//

import SwiftUI
import Charts
import ComposableArchitecture
import Combine

@Reducer
struct WeeklyChart {
    struct Weekly: Identifiable {
        var id = UUID()
        let day: String
        let profit: Double
    }
    
    @ObservableState
    struct State {
        var dailyActiveEnergyBurnes: [Weekly] = []
        var cancellable = Set<AnyCancellable>()
    }
    
    enum Action {
        case fetchDailyActiveEnergyBurnes
    }
    
    @Dependency(\.healthKitManager) private var healthKitManager
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchDailyActiveEnergyBurnes:
                
                return .none
            }
        }
    }
}

struct WeeklyChartView: View {
    struct Weekly: Identifiable {
        var id = UUID()
        let day: String
        let profit: Double
    }
    @Dependency(\.healthKitManager) private var healthKitManager
    
    @State var dailyActiveEnergyBurnes: [Weekly] = []
    @State var cancellables: Set<AnyCancellable> = []
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("주당 워크아웃")
            Chart(dailyActiveEnergyBurnes) {
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
        .padding([.leading, .trailing], 15)
        .onAppear {
            let koreanTimeZone = TimeZone(identifier: "Asia/Seoul")!
            var calendar = Calendar.current
            calendar.timeZone = koreanTimeZone
            let now = Date()
            let currentWeekday = calendar.component(.weekday, from: now)
            let daysFromMonday = (currentWeekday - calendar.firstWeekday + 7) % 7
            let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: calendar.startOfDay(for: now))!
            
            healthKitManager.getWeeklyCalories(from: monday, to: now)
                .replaceError(with: Array(repeating: 7, count: 0))
                .sink(receiveValue: { statistics in
                    guard statistics.count != 0 else {
                        return
                    }
                    let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
                    let activeEnergyBurnes = weekdays
                        .enumerated()
                        .map {
                            let profit = $0.offset >= statistics.count ? 0.0 : statistics[$0.offset]
                            return Weekly(day: $0.element, profit: profit)
                        }
                    self.dailyActiveEnergyBurnes = activeEnergyBurnes
                })
                .store(in: &cancellables)
        }
    }
}
