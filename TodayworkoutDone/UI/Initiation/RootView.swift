//
//  RootView.swift
//  TodayworkoutDone
//
//  Created by ocean on 5/29/25.
//

import SwiftUI
import ComposableArchitecture
import SwiftData

@Reducer
struct RootFeature {
    @ObservableState
    struct State: Equatable {
        var isActive: Bool = false
        @Shared(.appStorage("isOnBoarding")) var isOnBoarding: Bool = false
        var isLogin: Bool = false
        var onBoarding = OnBoardingFeature.State()
        var login = LoginFeature.State()
    }
    
    enum Action {
        case toggleActive(Bool)
        case onBoarding(OnBoardingFeature.Action)
        case login(LoginFeature.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.onBoarding, action: \.onBoarding) {
            OnBoardingFeature()
        }
        Reduce { state, action in
            switch action {
            case let .toggleActive(isActive):
                state.isActive = isActive
                return .none
            case .onBoarding(.doneTapped):
                state.isOnBoarding = true
                return .none
            case .onBoarding:
                return .none
            case .login(.login):
                state.isLogin = true
                return .none
            }
        }
        
    }
}

struct RootView: View {
    @Bindable var store: StoreOf<RootFeature>
    @ObservedObject var viewStore: ViewStoreOf<RootFeature>
    
    init(store: StoreOf<RootFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        VStack {
            if viewStore.isActive {
                if viewStore.isOnBoarding {
                    if viewStore.isLogin {
                        ContentView(store: Store(initialState: ContentReducer.State()) {
                            ContentReducer()
                        })
                    } else {
                        LoginView(store: store.scope(state: \.login,
                                                     action: \.login))
                    }
                } else {
                    OnBoardingView(store: store.scope(state: \.onBoarding,
                                                      action: \.onBoarding))
                }
            } else {
                SplashView(isActive: viewStore.binding(
                    get: \.isActive,
                    send: { RootFeature.Action.toggleActive($0) })
                )
            }
        }
        .modelContainer(SwiftDataConfigurationProvider.shared.container)
    }
}
