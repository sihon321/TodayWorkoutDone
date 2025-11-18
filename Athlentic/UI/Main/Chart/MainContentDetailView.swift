//
//  MainContentDetailView.swift
//  TodayworkoutDone
//
//  Created by ocean on 3/28/24.
//

import SwiftUI
import Charts
import ComposableArchitecture
import HealthKit

@Reducer
struct MainContentDetailViewReducer {
    @ObservableState
    struct State: Equatable {
        let contentType: MainContentFeature.MainContentType
        var chartRecords: [ChartRecord] = []
        var listRecords: [HKQuantityTypeIdentifier: Double] = [:]
    }
    
    enum Action {
        case requestAuthorization([(HKQuantityTypeIdentifier, HKUnit)])
        case fetchChartRecords
        case updateRecords([ChartRecord])
        
        case fetchListRecords(HKQuantityTypeIdentifier, HKUnit)
        case updateListRecords(HKQuantityTypeIdentifier, Double)
    }
    
    struct ChartRecord: Equatable, Identifiable {
        var id = UUID()
        let time: Date
        let value: Int
    }
    
    @Dependency(\.healthKitManager) private var healthKitManager
    @Dependency(\.dateManager) private var dateManager
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .requestAuthorization(ids):
                return .run { @Sendable send in
                    do {
                        let typesToRead = Set(ids.map({ HKObjectType.quantityType(forIdentifier: $0.0)! }))
                        let isSuccess = try await healthKitManager.authorizeHealthKit(
                            typesToShare: [],
                            typesToRead: typesToRead
                        )
                        if isSuccess {
                            for (id, unit) in ids {
                                await send(.fetchListRecords(id, unit))
                            }
                        }
                        print("HealthKit authorization" + isSuccess.description)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                
            case .fetchChartRecords:
                return .run { [contentType = state.contentType] send in
                    var type: HKQuantityTypeIdentifier = .stepCount
                    var unit: HKUnit = .count()
                    switch contentType {
                    case .stepCount:
                        type = .stepCount
                        unit = .count()
                    case .energyBurn:
                        type = .activeEnergyBurned
                        unit = .kilocalorie()
                    case .workoutTime:
                        type = .appleExerciseTime
                        unit = .minute()
                    }
                    do {
                        let hourlyRecords = try await healthKitManager.getHealthQuantityTimeSeries(
                            type: type,
                            from: .midnight,
                            to: .currentDateForDeviceRegion,
                            unit: unit,
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
                        let filledValues = allHours.map { date in
                            ChartRecord(
                                time: date,
                                value: Int(hourlyRecords[date] ?? 0) // 데이터 없으면 0
                            )
                        }
                        await send(.updateRecords(filledValues))
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            case let .updateRecords(records):
                state.chartRecords = records
                return .none
                
            case let .fetchListRecords(id, unit):
                return .run { send in
                    do {
                        switch id {
                        case .distanceWalkingRunning:
                            let value = try await healthKitManager.getHealthQuantityData(
                                type: id,
                                from: .midnight,
                                to: .currentDateForDeviceRegion,
                                unit: unit
                            )
                            
                            await send(.updateListRecords(id, value))
                        default:
                            let value = try await healthKitManager.getAverageHealthSampleData(
                                type: id,
                                from: .midnight,
                                to: .currentDateForDeviceRegion,
                                unit: unit
                            )
                            
                            await send(.updateListRecords(id, value))
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            case let .updateListRecords(id, value):
                state.listRecords[id] = value
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
        ScrollView {
            VStack {
                chartView()
                    .onAppear {
                        viewStore.send(.fetchChartRecords)
                    }
                Spacer(minLength: 30)
                let listData = listIdentifiers(viewStore.contentType)
                ForEach(listData, id: \.0) { (id, unit) in
                    listView(id)
                }
                .onAppear {
                    viewStore.send(.requestAuthorization(listData))
                }
                Spacer()
            }
        }
        .padding(.horizontal, 15)
        .background(Color.background)
    }
    
    func listIdentifiers(_ type: MainContentFeature.MainContentType) -> [(HKQuantityTypeIdentifier, HKUnit)] {
        let stepListIdentifiers: [(HKQuantityTypeIdentifier, HKUnit)] = [
            (.distanceWalkingRunning, .meter()),
            (.walkingSpeed, .meter().unitDivided(by: HKUnit.second())),
            (.walkingAsymmetryPercentage, .percent()),
            (.walkingStepLength, .meter()),
            (.walkingDoubleSupportPercentage, .percent())
        ]
        let energyBurnIdentifiers: [(HKQuantityTypeIdentifier, HKUnit)] = [
            (.basalEnergyBurned, .kilocalorie()),
            (.heartRate, .count().unitDivided(by: .minute())),
            (.restingHeartRate, .count().unitDivided(by: .minute()))
        ]
        let workoutTimeIdentifiers: [(HKQuantityTypeIdentifier, HKUnit)] = [
            (.appleMoveTime, .minute()),
            (.appleStandTime, .minute())
        ]
        switch type {
        case .stepCount:
            return stepListIdentifiers
        case .energyBurn:
            return energyBurnIdentifiers
        case .workoutTime:
            return workoutTimeIdentifiers
        }
    }
    
    private func iconName(_ id: HKQuantityTypeIdentifier) -> String {
        switch id {
        case .distanceWalkingRunning, .walkingStepLength: return "ruler"
        case .walkingSpeed, .walkingAsymmetryPercentage, .walkingDoubleSupportPercentage: return "figure.walk.motion"
        case .appleMoveTime: return "figure.walk"
        case .appleStandTime: return "figure.stand"
        case .basalEnergyBurned: return "sun.min"
        case .heartRate: return "bolt.heart"
        case .restingHeartRate: return "suit.heart"
        default:
            return ""
        }
    }
    
    private func headerTitle(_ id: HKQuantityTypeIdentifier) -> String {
        switch id {
        case .distanceWalkingRunning: return "걸음 기반 이동 거리"
        case .walkingSpeed: return "보행 속도"
        case .walkingAsymmetryPercentage: return "좌우 비대칭 걸음 비율"
        case .walkingStepLength: return "걸음 보폭"
        case .walkingDoubleSupportPercentage: return "양발이 동시에 땅에 닿아있는 비율"
        case .appleMoveTime: return "움직임 시간"
        case .appleStandTime: return "서 있는 시간"
        case .basalEnergyBurned: return "휴식 에너지"
        case .heartRate: return "심박수"
        case .restingHeartRate: return "안정시 심박수"
        default:
            return ""
        }
    }
    
    private func unit(_ id: HKQuantityTypeIdentifier) -> String {
        switch id {
        case .distanceWalkingRunning, .walkingStepLength: return "m"
        case .walkingSpeed: return "m/s"
        case .walkingAsymmetryPercentage, .walkingDoubleSupportPercentage: return "%"
        case .appleMoveTime, .appleStandTime: return "분"
        case .basalEnergyBurned: return "kcal"
        case .heartRate, .restingHeartRate: return "bpm"
        default:
            return ""
        }
    }
}

extension MainContentDetailView {
    func chartView() -> some View {
        Chart(viewStore.chartRecords) {
            BarMark(
                x: .value("시간", $0.time),
                y: .value("값", $0.value)
            )
            .foregroundStyle(Color.personal)
        }
        .frame(minWidth: 0,
               maxWidth: .infinity,
               minHeight: 165)
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
    
    func listView(_ id: HKQuantityTypeIdentifier) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: iconName(id))
                Text(headerTitle(id))
                    .font(.system(size: 15,
                                  weight: .semibold,
                                  design: .default))
                    .foregroundStyle(Color.todBlack)
            }
            .padding(.horizontal, 15)
            HStack {
                Text("평균")
                    .font(.system(size: 18,
                                  weight: .bold,
                                  design: .default))
                    .foregroundStyle(Color(0x7d7d7d))
                Text(String(format: "%.2f", viewStore.listRecords[id] ?? 0.0))
                    .font(.system(size: 22,
                                  weight: .bold,
                                  design: .default))
                    .foregroundStyle(Color.todBlack)
                Text(unit(id))
                    .font(.system(size: 12,
                                  weight: .semibold,
                                  design: .default))
                    .foregroundStyle(Color(0x7d7d7d))
                    .padding(.leading, -5)
                    .padding(.top, 2)
            }
            .padding(.top, 5)
            .padding(.horizontal, 15)
        }
        .frame(maxWidth: .infinity,
               minHeight: 80,
               alignment: .leading)
        .background(Color.contentBackground)
        .cornerRadius(15)
        .tint(Color.todBlack)
    }
}
