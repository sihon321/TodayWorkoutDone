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
        @Shared(.appStorage("theme")) var theme: SettingsReducer.AppTheme = .system
        @Shared(.appStorage("isOnBoarding")) var isOnBoarding: Bool = false
        
        var isActive: Bool = false
        var isLogin: Bool = false
        var onBoarding = OnBoardingFeature.State()
        var login = LoginFeature.State()
        var content = ContentReducer.State()
    }
    
    enum Action {
        case toggleActive(Bool)
        case onBoarding(OnBoardingFeature.Action)
        case login(LoginFeature.Action)
        case content(ContentReducer.Action)
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
            case .content:
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
                        ContentView(store: store.scope(state: \.content, action: \.content))
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
        .preferredColorScheme(viewStore.theme == .dark ? .dark : viewStore.theme == .light ? .light : nil)
    }
}
