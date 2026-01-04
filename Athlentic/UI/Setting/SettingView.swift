//
//  SettingView.swift
//  TodayworkoutDone
//
//  Created by ocean on 6/9/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct SettingsReducer {
    enum DistanceUnit: String, CaseIterable, Equatable {
        case meter = "미터법(cm)"
        case yardpound = "야드파운드(in)"
        
        var unit: String {
            switch self {
            case .meter:
                return "cm"
            case .yardpound:
                return "in"
            }
        }
    }
    
    enum WeightUnit: String, CaseIterable, Equatable {
        case meter = "미터법(kg)"
        case yardpound = "파운드(lb)"
        
        var unit: String {
            switch self {
            case .meter:
                return "kg"
            case .yardpound:
                return "lb"
            }
        }
    }
    
    enum AppTheme: String, CaseIterable, Equatable {
        case light, dark, system
    }
    
    @ObservableState
    struct State: Equatable {
        @Shared(.appStorage("birthDay")) var birthDayTimeStamp: Double?
        @Shared(.appStorage("height")) var height: Double?
        @Shared(.appStorage("weight")) var weight: Double?
        
        var birthDay: Date = Date()
        var manualHeight: String = ""
        var manualWeight: String = ""
        
        @Shared(.appStorage("distanceUnit")) var distanceUnit: DistanceUnit = .meter
        @Shared(.appStorage("weightUnit")) var weightUnit: WeightUnit = .meter
        @Shared(.appStorage("theme")) var theme: AppTheme = .system
        @Shared(.appStorage("isHealthKitSyncEnabled")) var isHealthKitSyncEnabled: Bool = true
        @Shared(.appStorage("isNotificationEnabled")) var isNotificationEnabled: Bool = true
    }
    
    enum Action: BindableAction {
        case profileChanged
        case loadProfile
        case editBirth(Date)
        case distanceUnitChanged(DistanceUnit)
        case weightUnitChanged(WeightUnit)
        case themeChanged(AppTheme)
        case healthKitSyncToggled(Bool)
        case notificationToggled(Bool)
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .profileChanged:
                state.$height.withLock { $0 = Double(state.manualHeight) }
                state.$weight.withLock { $0 = Double(state.manualWeight) }
                return .none
            case .loadProfile:
                if let height = state.height {
                    state.manualHeight = String(height)
                }
                if let weight = state.weight {
                    state.manualWeight = String(weight)
                }
                if let birthDayTimeStamp = state.birthDayTimeStamp {
                    state.birthDay = Date(timeIntervalSince1970: birthDayTimeStamp)
                }
                return .none
            case let .editBirth(date):
                state.birthDay = date
                state.$birthDayTimeStamp.withLock { $0 = date.timeIntervalSince1970 }
                return .none
                
            case let .distanceUnitChanged(unit):
                if state.distanceUnit != unit, let height = Double(state.manualHeight) {
                    if unit == .meter {
                        state.manualHeight = String(format: "%.2f", height * 2.54)
                    } else {
                        state.manualHeight = String(format: "%.2f", height * 0.3937)
                    }
                }
                state.$distanceUnit.withLock { $0 = unit }
                return .none
                
            case let .weightUnitChanged(unit):
                if state.weightUnit != unit, let weight = Double(state.manualWeight) {
                    if unit == .meter {
                        state.manualWeight = String(format: "%.2f", weight * 0.4536)
                    } else {
                        state.manualWeight = String(format: "%.2f", weight * 2.2046)
                    }
                }
                state.$weightUnit.withLock { $0 = unit }
                return .none
                
            case let .themeChanged(theme):
                state.$theme.withLock { $0 = theme }
                return .none
                
            case let .healthKitSyncToggled(enabled):
                state.$isHealthKitSyncEnabled.withLock { $0 = enabled }
                return .none
                
            case let .notificationToggled(enabled):
                state.$isNotificationEnabled.withLock { $0 = enabled }
                return .none
                
            case .binding:
                return .none
            }
        }
    }
}

struct SettingsView: View {
    @Bindable var store: StoreOf<SettingsReducer>
    
    @FocusState private var focusedField: FocusField?
    
    #if DEBUG
    @State private var showHealthKitDummy = false
    #endif

    private enum FocusField: Hashable {
        case height
        case weight
    }
    
    init(store: StoreOf<SettingsReducer>) {
        self.store = store
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("프로필 설정")) {
                    DatePicker("생년월일",
                               selection: $store.birthDay.sending(\.editBirth),
                               displayedComponents: .date
                    )
                    HStack {
                        Text("키")
                        TextField("(\(store.distanceUnit.unit))", text: $store.manualHeight)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .height)
                    }
                    HStack {
                        Text("몸무게")
                        TextField("(\(store.weightUnit.unit))", text: $store.manualWeight)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .weight)
                    }
                }
                
                Section(header: Text("단위 설정")) {
                    Picker("길이", selection: $store.distanceUnit.sending(\.distanceUnitChanged)) {
                        ForEach(SettingsReducer.DistanceUnit.allCases, id: \.self) {
                            Text($0.rawValue.capitalized)
                        }
                    }
                    
                    Picker("중량", selection: $store.weightUnit.sending(\.weightUnitChanged)) {
                        ForEach(SettingsReducer.WeightUnit.allCases, id: \.self) {
                            Text($0.rawValue.capitalized)
                        }
                    }
                }
                
                Section(header: Text("테마")) {
                    Picker("앱 테마", selection: $store.theme.sending(\.themeChanged)) {
                        ForEach(SettingsReducer.AppTheme.allCases, id: \.self) {
                            Text($0.rawValue.capitalized)
                        }
                    }
                }
                
                Section(header: Text("기타")) {
                    Toggle("HealthKit 동기화", isOn: $store.isHealthKitSyncEnabled.sending(\.healthKitSyncToggled))
                    .tint(Color.personal)
                    
                    Toggle("알림 설정", isOn: $store.isNotificationEnabled.sending(\.notificationToggled))
                    .tint(Color.personal)
                }
                
                #if DEBUG
                Section(header: Text("헬스 데이터")) {
                    Button {
                        showHealthKitDummy = true
                    } label: {
                        HStack {
                            Image(systemName: "heart.text.square")
                            Text("HealthKit 더미 보기")
                        }
                    }
                }
                #endif
            }
            .contentMargins(.bottom, 150, for: .scrollContent)
            .navigationTitle("설정")
            .scrollContentBackground(.hidden)
            .background(Color.background)
            .scrollDismissesKeyboard(.interactively)
            .contentShape(Rectangle())
            .sheet(isPresented: $showHealthKitDummy) {
                HealthKitDummyView()
            }
        }
        .onAppear {
            store.send(.loadProfile)
        }
        .onDisappear {
            store.send(.profileChanged)
        }
    }
}

