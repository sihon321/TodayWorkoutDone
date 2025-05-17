//
//  MainContentDetailView.swift
//  TodayworkoutDone
//
//  Created by ocean on 3/28/24.
//

import SwiftUI
import Charts
import ComposableArchitecture

@Reducer
struct MainContentDetailViewReducer {
    @ObservableState
    struct State: Equatable {
        var stepRecords: [StepRecord] = []
    }
    
    enum Action {
        case fetchStepRecords
        case updateRecords([StepRecord])
    }
    
    struct StepRecord: Equatable, Identifiable {
        var id = UUID()
        let time: Date
        let step: Int
    }
    
    @Dependency(\.healthKitManager) private var healthKitManager
    @Dependency(\.dateManager) private var dateManager
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchStepRecords:
                return .run { send in
                    let hourlySteps = try await healthKitManager.getHealthQuantityTimeSeries(
                        type: .stepCount,
                        from: .midnight,
                        to: .currentDateForDeviceRegion,
                        unit: .count(),
                        interval: DateComponents(hour: 1)
                    )

                    // 1. 시작시간~종료시간까지 모든 시간대 생성
                    var allHours: [Date] = []
                    let calendar = Calendar.current
                    var currentDate = calendar.startOfDay(for: Date()) // 시작일 (자정)

                    while currentDate <= Date() { // 현재 시간까지
                        allHours.append(currentDate)
                        currentDate = calendar.date(byAdding: .hour, value: 1, to: currentDate)!
                    }

                    // 2. 모든 시간대에 대해 데이터 매핑
                    let filledSteps = allHours.map { date in
                        StepRecord(
                            time: date,
                            step: Int(hourlySteps[date] ?? 0) // 데이터 없으면 0
                        )
                    }
                    await send(.updateRecords(filledSteps))
                }
            case let .updateRecords(records):
                state.stepRecords = records
                return .none
            }
        }
    }
}

struct MainContentDetailView: View {
    @Bindable var store: StoreOf<MainContentDetailViewReducer>
    @ObservedObject var viewStore: ViewStoreOf<MainContentDetailViewReducer>
    
    init(store: StoreOf<MainContentDetailViewReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        VStack {
            Chart(viewStore.stepRecords) {
                BarMark(
                    x: .value("시간", $0.time),
                    y: .value("걸음", $0.step)
                )
                .foregroundStyle(Color.personal)
            }
            .frame(minWidth: 0,
                   maxWidth: .infinity,
                   maxHeight: 165)
            .chartXAxis {
                AxisMarks(values: .stride(by: .hour, count: 3)) { value in
                    if let date = value.as(Date.self) {
                        let hour = Calendar.current.component(.hour, from: date)
                        AxisValueLabel {
                            VStack(alignment: .leading) {
                                switch hour {
                                case 0, 12:
                                    Text(date, format: .dateTime.hour())
                                default:
                                    Text(date, format: .dateTime.hour(.defaultDigits(amPM: .omitted)))
                                }
                                if value.index == 0 || hour == 0 {
                                    Text(date, format: .dateTime.month().day())
                                }
                            }
                        }


                        if hour == 0 {
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
                        } else {
                            AxisGridLine()
                            AxisTick()
                        }
                    }
                }
            }
        }
        .onAppear {
            viewStore.send(.fetchStepRecords)
        }
    }
}
