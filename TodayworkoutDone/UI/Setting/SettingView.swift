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
    }

    enum WeightUnit: String, CaseIterable, Equatable {
        case meter = "미터법(kg)"
        case yardpound = "파운드(lb)"
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
                state.height = Double(state.manualHeight)
                state.weight = Double(state.manualWeight)
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
                state.birthDayTimeStamp = date.timeIntervalSince1970
                return .none
                
            case let .distanceUnitChanged(unit):
                state.distanceUnit = unit
                return .none

            case let .weightUnitChanged(unit):
                state.weightUnit = unit
                return .none

            case let .themeChanged(theme):
                state.theme = theme
                return .none

            case let .healthKitSyncToggled(enabled):
                state.isHealthKitSyncEnabled = enabled
                return .none
                
            case let .notificationToggled(enabled):
                state.isNotificationEnabled = enabled
                return .none
                
            case .binding:
                return .none
            }
        }
    }
}

struct SettingsView: View {
    @Bindable var store: StoreOf<SettingsReducer>
    @ObservedObject var viewStore: ViewStoreOf<SettingsReducer>
    
    init(store: StoreOf<SettingsReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("프로필 설정")) {
                    DatePicker("생년월일",
                               selection: viewStore.binding(get: \.birthDay,
                                                            send: SettingsReducer.Action.editBirth),
                               displayedComponents: .date
                    )
                    HStack {
                        Text("키")
                        TextField("(cm)", text: $store.manualHeight)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("몸무게")
                        TextField("(kg)", text: $store.manualWeight)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section(header: Text("단위 설정")) {
                    Picker("길이", selection: viewStore.binding(
                        get: \.distanceUnit,
                        send: SettingsReducer.Action.distanceUnitChanged
                    )) {
                        ForEach(SettingsReducer.DistanceUnit.allCases, id: \.self) {
                            Text($0.rawValue.capitalized)
                        }
                    }

                    Picker("중량", selection: viewStore.binding(
                        get: \.weightUnit,
                        send: SettingsReducer.Action.weightUnitChanged
                    )) {
                        ForEach(SettingsReducer.WeightUnit.allCases, id: \.self) {
                            Text($0.rawValue.capitalized)
                        }
                    }
                }

                Section(header: Text("테마")) {
                    Picker("앱 테마", selection: viewStore.binding(
                        get: \.theme,
                        send: SettingsReducer.Action.themeChanged
                    )) {
                        ForEach(SettingsReducer.AppTheme.allCases, id: \.self) {
                            Text($0.rawValue.capitalized)
                        }
                    }
                }

                Section(header: Text("기타")) {
                    Toggle("HealthKit 동기화", isOn: viewStore.binding(
                        get: \.isHealthKitSyncEnabled,
                        send: SettingsReducer.Action.healthKitSyncToggled
                    ))
                    .tint(Color.personal)

                    Toggle("알림 설정", isOn: viewStore.binding(
                        get: \.isNotificationEnabled,
                        send: SettingsReducer.Action.notificationToggled
                    ))
                    .tint(Color.personal)
                }
            }
            .navigationTitle("설정")
        }
        .onAppear {
            viewStore.send(.loadProfile)
        }
        .onDisappear {
            viewStore.send(.profileChanged)
        }
    }
}
