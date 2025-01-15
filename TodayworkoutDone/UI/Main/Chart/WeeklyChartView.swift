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
            Text("주당 소모 칼로리")
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
            let monday = calendar.date(byAdding: .day,
                                       value: -daysFromMonday,
                                       to: calendar.startOfDay(for: now))!
            
            healthKitManager.getWeeklyCalories(from: monday, to: now)
                .replaceError(with: createWeeklyDateDictionary(from: monday))
                .sink(receiveValue: { dailyCalories in
                    let weekdays = createWeekDates(from: monday)
                    let activeEnergyBurnes = weekdays
                        .sorted(by: { $0 < $1 })
                        .map {
                            if let calorie = dailyCalories[$0] {
                                return Weekly(day: getWeekdayString(from: $0),
                                              profit: calorie)
                            } else {
                                return Weekly(day: getWeekdayString(from: $0),
                                              profit: 0.0)
                            }
                        }
                    self.dailyActiveEnergyBurnes = activeEnergyBurnes
                })
                .store(in: &cancellables)
        }
    }
    
    func createWeeklyDateDictionary(from startDate: Date) -> [Date: Double] {
        var dateDictionary: [Date: Double] = [:]
        
        let calendar = Calendar.current
        
        for i in 0...6 {
            if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
                let startOfDay = calendar.startOfDay(for: date)
                dateDictionary[startOfDay] = 0.0
            }
        }
        
        return dateDictionary
    }
    
    func createWeekDates(from startDate: Date) -> [Date] {
        var dates: [Date] = []
        let calendar = Calendar.current
        
        for i in 0...6 {
            if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
                let startOfDay = calendar.startOfDay(for: date)
                dates.append(startOfDay)
            }
        }
        
        return dates
    }
    
    func getWeekdayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}
