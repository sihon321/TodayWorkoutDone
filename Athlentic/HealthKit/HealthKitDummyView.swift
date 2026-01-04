//
//  HealthKitDummyView.swift
//  TodayworkoutDone
//
//  Created by ocean on 4/29/25.
//

import SwiftUI
import HealthKit

public struct HealthKitDummyView: View {
    @StateObject private var viewModel = HealthKitDummyViewModel()
    
    public init() {}
    
    public var body: some View {
        Form {
            Section("랜덤 데이터") {
                Section {
                    Button("데이터 생성하기") {
                        Task {
                            await viewModel.insertWeeklyDummyData()
                        }
                    }
                }
            }
            
            Section("데이터 입력") {
                Picker("타입", selection: $viewModel.selectedType) {
                    ForEach(HealthKitDummyViewModel.SupportedType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                
                TextField("값", text: $viewModel.valueString)
                    .keyboardType(.decimalPad)
                
                DatePicker("날짜", selection: $viewModel.selectedDate, displayedComponents: [.date, .hourAndMinute])
            }
            
            Section {
                Button("데이터 저장하기") {
                    Task {
                        await viewModel.save()
                    }
                }
            }
        }
        .alert(item: $viewModel.alert) { alert in
            Alert(title: Text(alert.title), message: Text(alert.message), dismissButton: .default(Text("확인")))
        }
    }
}

final class HealthKitDummyViewModel: ObservableObject {
    enum SupportedType: CaseIterable {
        case stepCount
        case distanceWalkingRunning
        case activeEnergyBurned
        
        var identifier: HKQuantityTypeIdentifier {
            switch self {
            case .stepCount: return .stepCount
            case .distanceWalkingRunning: return .distanceWalkingRunning
            case .activeEnergyBurned: return .activeEnergyBurned
            }
        }
        
        var unit: HKUnit {
            switch self {
            case .stepCount: return .count()
            case .distanceWalkingRunning: return .meter()
            case .activeEnergyBurned: return .kilocalorie()
            }
        }
        
        var displayName: String {
            switch self {
            case .stepCount: return "걸음 수"
            case .distanceWalkingRunning: return "걷기/달리기 거리"
            case .activeEnergyBurned: return "활동 에너지 소모량"
            }
        }
    }
    
    @Published var selectedType: SupportedType = .stepCount
    @Published var valueString: String = ""
    @Published var selectedDate: Date = Date()
    @Published var alert: AlertItem?
    
    private let manager = HealthKitDummyManager()
    
    @MainActor
    func save() async {
        guard let value = Double(valueString) else {
            alert = AlertItem(title: "입력 오류", message: "값을 올바르게 입력해 주세요.")
            return
        }
        
        do {
            try await manager.insertDummyQuantity(
                type: selectedType.identifier,
                value: value,
                date: selectedDate.dateForDeviceRegion,
                unit: selectedType.unit
            )
            alert = AlertItem(title: "성공", message: "데이터가 저장되었습니다.")
        } catch {
            alert = AlertItem(title: "에러", message: error.localizedDescription)
        }
    }
    
    @MainActor
    func insertWeeklyDummyData() async {
        let store = HKHealthStore()
        
        // 1. 저장하려는 모든 데이터 타입 정의
        let stepListIdentifiers: [(HKQuantityTypeIdentifier, HKUnit)] = [
            (.stepCount, .count()),
            (.distanceWalkingRunning, .meter()),
            (.walkingSpeed, .meter().unitDivided(by: HKUnit.second())),
            (.walkingStepLength, .meter()),
        ]
        
        let energyBurnIdentifiers: [(HKQuantityTypeIdentifier, HKUnit)] = [
            (.activeEnergyBurned, .kilocalorie()),
            (.basalEnergyBurned, .kilocalorie()),
            (.heartRate, .count().unitDivided(by: .minute())),
            (.restingHeartRate, .count().unitDivided(by: .minute()))
        ]
        
        let allIdentifiers = stepListIdentifiers + energyBurnIdentifiers
        
        // 2. 권한 요청 (Authorization Request)
        // 저장하려는 타입들의 Set을 만듭니다.
        let typesToShare = Set(allIdentifiers.compactMap { HKQuantityType.quantityType(forIdentifier: $0.0) })
        let typesToRead = typesToShare // 읽기 권한도 같이 요청 (필요 시)
        
        do {
            // 사용자에게 권한 허용 팝업을 띄웁니다.
            try await store.requestAuthorization(toShare: typesToShare, read: typesToRead)
        } catch {
            print("❌ 권한 요청 실패: \(error.localizedDescription)")
            self.alert = AlertItem(title: "권한 오류", message: "HealthKit 권한을 얻지 못했습니다.")
            return
        }
        
        // 3. 데이터 생성 및 일괄 저장 로직
        print("권한 확인 완료. 데이터 생성 시작...")
        
        let calendar = Calendar.current
        let today = Date.currentDateForDeviceRegion
        var samplesToSave: [HKSample] = []
        
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            
            for (typeIdentifier, unit) in allIdentifiers {
                let randomValue: Double
                switch typeIdentifier {
                case .stepCount: randomValue = Double.random(in: 100...900)
                case .heartRate, .restingHeartRate: randomValue = Double.random(in: 60...120)
                case .distanceWalkingRunning: randomValue = Double.random(in: 1000...2000)
                case .walkingSpeed: randomValue = Double.random(in: 1.0...2.0)
                case .walkingStepLength: randomValue = Double.random(in: 0.5...0.8)
                case .basalEnergyBurned, .activeEnergyBurned: randomValue = Double.random(in: 200...1000)
                default: randomValue = Double.random(in: 1...100)
                }
                
                guard let quantityType = HKQuantityType.quantityType(forIdentifier: typeIdentifier) else { continue }
                let quantity = HKQuantity(unit: unit, doubleValue: randomValue)
                
                let sample = HKQuantitySample(
                    type: quantityType,
                    quantity: quantity,
                    start: date,
                    end: date
                )
                
                samplesToSave.append(sample)
            }
        }
        
        // 4. 저장 실행
        do {
            if !samplesToSave.isEmpty {
                try await store.save(samplesToSave)
                print("✅ 모든 더미 데이터 입력 작업 완료 (총 \(samplesToSave.count)개)")
                self.alert = AlertItem(title: "완료", message: "7일치 데이터가 성공적으로 저장되었습니다.")
            } else {
                print("⚠️ 저장할 데이터가 없습니다.")
            }
        } catch {
            print("❌ 저장 실패: \(error.localizedDescription)")
            self.alert = AlertItem(title: "실패", message: "권한이 없거나 저장 중 오류가 발생했습니다. 설정 > 건강 앱에서 권한을 확인해주세요.")
        }
    }
}

struct AlertItem: Identifiable {
    var id: UUID = UUID()
    let title: String
    let message: String
}
