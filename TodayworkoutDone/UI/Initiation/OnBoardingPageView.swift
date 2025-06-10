//
//  OnBoardingPageView.swift
//  TodayworkoutDone
//
//  Created by ocean on 5/29/25.
//

import SwiftUI
import ComposableArchitecture
import Lottie

@Reducer
struct OnBoardingFeature {
    enum Step: Int, CaseIterable {
        case intro
        case healthKit
        case unit
        case profile
        case summary
        case premium
    }
    
    @ObservableState
    struct State: Equatable {
        @Shared(.appStorage("height")) var height: Double?
        @Shared(.appStorage("weight")) var weight: Double?
        @Shared(.appStorage("birthDay")) var birthDayTimeStamp: Double?
        @Shared(.appStorage("distanceUnit")) var distanceUnit: SettingsReducer.DistanceUnit = .meter
        @Shared(.appStorage("weightUnit")) var weightUnit: SettingsReducer.WeightUnit = .meter
        
        var currentStep: Step = .intro
        var isHealthKitAuthorized: Bool = false
        var birthDay: Date = Date()
        
        var manualHeight: String = ""
        var manualWeight: String = ""
    }
    
    enum Action: BindableAction {
        case nextTapped
        case requestHealthKit
        case doneTapped
        case healthKitAuthorizationResponse(Bool)
        case loadProfileFromHealthKit
        case didLoadProfile(height: Double?, weight: Double?)
        case editBirth(Date)
        case saveProfile(height: Double, weight: Double)
        case binding(BindingAction<State>)
    }

    @Dependency(\.healthKitManager) var healthKitManager

    var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .nextTapped:
                if let next = Step(rawValue: state.currentStep.rawValue + 1) {
                    state.currentStep = next
                }
                return .none

            case .requestHealthKit:
                return .run { send in
                    do {
                        let success = try await healthKitManager.authorizeHealthKit(
                            typesToShare: [
                                .quantityType(forIdentifier: .height)!,
                                .quantityType(forIdentifier: .bodyMass)!
                            ],
                            typesToRead: [
                                .quantityType(forIdentifier: .height)!,
                                .quantityType(forIdentifier: .bodyMass)!
                            ]
                        )
                        await send(.healthKitAuthorizationResponse(success))
                        if success {
                            await send(.loadProfileFromHealthKit)
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                
            case .doneTapped:
                return .none

            case .healthKitAuthorizationResponse(let success):
                state.isHealthKitAuthorized = success
                return .none
                
            case .loadProfileFromHealthKit:
                return .run { send in
                    do {
                        let profile = try await healthKitManager.fetchUserProfile()
                        await send(.didLoadProfile(
                            height: profile.height,
                            weight: profile.weight
                        ))
                    } catch {
                        print(error.localizedDescription)
                    }
                }

            case let .didLoadProfile(height, weight):
                state.height = height
                state.weight = weight

                if height == nil || weight == nil {
                    state.currentStep = .profile
                }
                
                return .none
                
            case let .editBirth(date):
                state.birthDay = date
                state.birthDayTimeStamp = date.timeIntervalSince1970
                return .none
                
            case let .saveProfile(height, weight):
                state.height = height
                state.weight = weight
                
                return .run { send in
                    do {
                        try await healthKitManager.saveHeightAndWeight(height: height ,
                                                                       weight: weight)
                    } catch {
                        print(error.localizedDescription)
                    }
                }

            case .binding:
                return .none
            }
        }
    }
}

struct OnBoardingView: View {
    @Bindable var store: StoreOf<OnBoardingFeature>
    @ObservedObject var viewStore: ViewStoreOf<OnBoardingFeature>
    
    init(store: StoreOf<OnBoardingFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        VStack {
            switch viewStore.currentStep {
            case .intro:
                VStack(spacing: 20) {
                    Text("당신의 운동 여정, 이제 시작입니다!")
                        .font(.system(size: 30, weight: .bold))
                        .multilineTextAlignment(.center)
                    Text("나만을 위한 맞춤형 운동 기록으로, 건강한 변화를 만들어보세요.")
                        .foregroundStyle(.secondary)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                    LottieView(filename: "dumbel", loopMode: .loop)
                        .frame(width: 200, height: 300)
                }
                .padding(.top, 100)
            case .healthKit:
                VStack(spacing: 20) {
                    Text("더 정확한 맞춤 운동을 위해, 건강 데이터를 연동해주세요!")
                        .font(.system(size: 30, weight: .bold))
                        .multilineTextAlignment(.center)
                    Text("운동 기록을 자동으로 불러오려면 Apple 건강 앱과의 연동이 필요합니다.")
                        .foregroundStyle(.secondary)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                    HStack {
                        Image("app_icon")
                            .resizable()
                            .frame(width: 80, height: 80)
                        Image(systemName: "xmark")
                        Image("apple_health")
                            .padding(.leading, 8)
                    }
                    .frame(width: 200, height: 300)
                    
                    if viewStore.isHealthKitAuthorized {
                        Text("✅ 권한이 허용되었습니다.")
                            .foregroundColor(.green)
                    }
                }
                .padding(.top, 100)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        viewStore.send(.requestHealthKit)
                    }
                }
            
            case .unit:
                VStack(spacing: 20) {
                    Text("어떤 단위를 사용하시겠어요?")
                        .font(.system(size: 30, weight: .bold))
                        .multilineTextAlignment(.center)
                    Text("더욱 정확하고 익숙한 운동 기록을 위해, 주로 사용하시는 단위를 선택해주세요.")
                        .foregroundStyle(.secondary)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        
                    Spacer()
                    
                    Picker("Unit", selection: $store.distanceUnit) {
                        ForEach(SettingsReducer.DistanceUnit.allCases, id: \.rawValue) { unit in
                            Text(unit.rawValue)
                                .tag(unit)
                        }
                    }
                    .pickerStyle(.segmented)
                    .foregroundStyle(Color.personal)
                    
                    Picker("Unit", selection: $store.weightUnit) {
                        ForEach(SettingsReducer.WeightUnit.allCases, id: \.rawValue) { unit in
                            Text(unit.rawValue)
                                .tag(unit)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Spacer()
                }
                .padding(.top, 100)
            case .profile:
                VStack(spacing: 20) {
                    Text("걱정 마세요! 몇 가지 정보만 알려주시면 돼요.")
                        .font(.system(size: 30, weight: .bold))
                        .multilineTextAlignment(.center)
                    Text("입력해주신 정보는 오직 당신만을 위한 맞춤 운동 분석에 활용됩니다.")
                        .foregroundStyle(.secondary)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 16)
                    
                    VStack {
                        DatePicker("생년월일",
                                   selection: viewStore.binding(get: \.birthDay,
                                                                send: OnBoardingFeature.Action.editBirth),
                                   displayedComponents: .date
                        )
                        HStack {
                            Text("키")
                            TextField("(\(viewStore.distanceUnit.unit))", text: $store.manualHeight)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Text("몸무게")
                            TextField("(\(viewStore.weightUnit.unit))", text: $store.manualWeight)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    .frame(width: 200, height: 300)
                }
                .padding(.top, 100)
            case .summary:
                VStack(spacing: 20) {
                    Text("나만의 루틴을 만들어 운동을 시작해볼까요?")
                        .font(.system(size: 30, weight: .bold))
                        .multilineTextAlignment(.center)
                    Text("자주 하는 운동들을 '나만의 루틴'으로 저장하고, 손쉽게 운동을 기록하고 관리해보세요.")
                        .foregroundStyle(.secondary)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                    LottieView(filename: "archive", loopMode: .loop)
                        .frame(width: 300, height: 400)
                }
                .padding(.top, 100)
            case .premium:
                VStack(spacing: 20) {
                    Text("프리미엄으로 당신의 운동 잠재력을 최대로 끌어올리세요!")
                        .font(.system(size: 30, weight: .bold))
                        .multilineTextAlignment(.center)
                    Text("더 깊이 있는 운동 분석, 광고 없는 환경, 지금 바로 업그레이드하고, 차원이 다른 운동 관리를 시작해보세요!")
                        .foregroundStyle(.secondary)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                    
                    VStack {
                        LottieView(filename: "pro", loopMode: .loop)
                            .frame(width: 50, height: 50)
                            .padding(.bottom, -20)
                        LottieView(filename: "premium", loopMode: .loop)
                            .frame(width: 150, height: 150)
                    }
                }
                .padding(.top, 100)
            }

            Spacer()

            Button(action: {
                if viewStore.currentStep == .profile,
                   let height = Double(viewStore.manualHeight),
                   let weight = Double(viewStore.manualWeight) {
                    viewStore.send(.saveProfile(height: height, weight: weight))
                    viewStore.send(.nextTapped)
                } else if viewStore.currentStep == .premium {
                    viewStore.send(.doneTapped)
                } else {
                    viewStore.send(.nextTapped)
                }
            }) {
                Text(viewStore.currentStep == .premium ? "시작하기" : "다음")
                    .frame(maxWidth: .infinity, minHeight: 45)
                    .background(Color.personal)
                    .foregroundStyle(.white)
                    .cornerRadius(20)
                    .padding(.horizontal, 15)
            }
            .disabled(viewStore.currentStep == .healthKit ? !viewStore.isHealthKitAuthorized : false)
            .padding(.bottom, 30)
        }
        .padding(.horizontal, 15)
    }
}

#Preview {
    OnBoardingView(store: Store(initialState: OnBoardingFeature.State()) {
        OnBoardingFeature()
    })
}
