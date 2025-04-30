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
            Section("데이터 입력") {
                Picker("타입", selection: $viewModel.selectedType) {
                    ForEach(HealthKitDummyViewModel.SupportedType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                
                TextField("값", text: $viewModel.valueString)
                    .keyboardType(.decimalPad)
                
                DatePicker("날짜", selection: $viewModel.selectedDate, displayedComponents: .date)
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
}

struct AlertItem: Identifiable {
    var id: UUID = UUID()
    let title: String
    let message: String
}
