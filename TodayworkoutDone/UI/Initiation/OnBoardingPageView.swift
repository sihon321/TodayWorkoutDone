//
//  OnBoardingPageView.swift
//  TodayworkoutDone
//
//  Created by ocean on 5/29/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct OnBoardingFeature {
    enum Step: Int, CaseIterable {
        case intro
        case healthKit
        case goal
        case summary
    }

    @ObservableState
    struct State: Equatable {
        var currentStep: Step = .intro
        var isHealthKitAuthorized: Bool = false
    }

    enum Action: BindableAction {
        case nextTapped
        case requestHealthKit
        case doneTapped
        case healthKitAuthorizationResponse(Bool)
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
                
            case .doneTapped:
                
                return .none

            case .requestHealthKit:
                return .run { send in
                    let success = try await healthKitManager.requestAuthorization()
                    await send(.healthKitAuthorizationResponse(success))
                }

            case .healthKitAuthorizationResponse(let success):
                state.isHealthKitAuthorized = success
                return .none

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
        VStack(spacing: 40) {
            Spacer()

            switch viewStore.currentStep {
            case .intro:
                Text("👋 TOD에 오신 걸 환영합니다.\n운동 기록을 쉽고 정확하게 관리하세요.")
                    .multilineTextAlignment(.center)

            case .healthKit:
                VStack(spacing: 20) {
                    Text("📲 건강 앱과 연동하기")
                        .font(.title2)
                    Text("운동 기록을 자동으로 불러오려면\nApple 건강 앱과의 연동이 필요합니다.")
                        .multilineTextAlignment(.center)
                    Button("HealthKit 권한 요청") {
                        viewStore.send(.requestHealthKit)
                    }
                    .buttonStyle(.borderedProminent)
                    if viewStore.isHealthKitAuthorized {
                        Text("✅ 권한이 허용되었습니다.")
                            .foregroundColor(.green)
                    }
                }

            case .goal:
                Text("🏃 하루 목표를 설정해보세요!\n목표 걸음 수, 운동시간을 설정하면\n더 나은 분석이 가능해요.")
                    .multilineTextAlignment(.center)

            case .summary:
                VStack {
                    Text("📊 TOD가 준비되었습니다!")
                        .font(.title2)
                    Text("이제 운동 기록을 시작해보세요.")
                        .multilineTextAlignment(.center)
                    Button("TOD 시작하기") {
                        viewStore.send(.doneTapped)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }

            Spacer()

            if viewStore.currentStep != .summary {
                Button("다음") {
                    viewStore.send(.nextTapped)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
}
