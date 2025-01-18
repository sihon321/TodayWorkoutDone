//
//  WeeklyChartView.swift
//  TodayWorkoutDone (iOS)
//
//  Created by ocean on 2022/08/05.
//

import SwiftUI
import Charts
import ComposableArchitecture

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
        let dateManager = DateManager()
    }
    
    enum Action {
        case fetchDailyActiveEnergyBurnes
        case weeklyCaloriesResponse(Result<[Weekly], Error>)
    }
    
    @Dependency(\.healthKitManager) private var healthKitManager
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchDailyActiveEnergyBurnes:
                let now = Date()
                guard let monday = state.dateManager.getMondayOfCurrentWeek(from: now) else {
                    return .none
                }
                
                return .run { [dateManager = state.dateManager] send in
                    do {
                        let dailyCalories = try await healthKitManager.getWeeklyCalories(from: monday,
                                                                                     to: now)
                        let weekdays = dateManager.createWeekDates(from: monday)
                        let activeEnergyBurnes = weekdays
                            .sorted(by: { $0 < $1 })
                            .map {
                                if let calorie = dailyCalories[$0] {
                                    return Weekly(day: dateManager.getWeekdayString(from: $0),
                                                  profit: calorie)
                                } else {
                                    return Weekly(day: dateManager.getWeekdayString(from: $0),
                                                  profit: 0.0)
                                }
                            }
                        await send(.weeklyCaloriesResponse(.success(activeEnergyBurnes)))
                    } catch {
                        await send(.weeklyCaloriesResponse(.failure(error)))
                    }
                }
            case let .weeklyCaloriesResponse(.success(dailyCalories)):
                state.dailyActiveEnergyBurnes = dailyCalories
                return .none
            case let.weeklyCaloriesResponse(.failure(error)):
                let now = Date()
                guard let monday = state.dateManager.getMondayOfCurrentWeek(from: now) else {
                    return .none
                }
                state.dailyActiveEnergyBurnes = state.dateManager.createWeeklyDateDictionary(from: monday)
                    .sorted(by: { $0 < $1 })
                    .map {
                        Weekly(day: state.dateManager.getWeekdayString(from: $0.key),
                               profit: 0.0)
                    }

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
    
    @Bindable var store: StoreOf<WeeklyChart>
    
    init(store: StoreOf<WeeklyChart>) {
        self.store = store
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("주당 소모 칼로리")
            Chart(store.dailyActiveEnergyBurnes) {
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
            store.send(.fetchDailyActiveEnergyBurnes)
        }
    }
}
