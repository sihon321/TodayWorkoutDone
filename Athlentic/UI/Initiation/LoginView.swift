//
//  LoginView.swift
//  TodayworkoutDone
//
//  Created by oceano on 3/2/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct LoginFeature {
    @ObservableState
    struct State: Equatable {
        
    }
    
    enum Action {
        case login
    }
    
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .login:
                return .none
            }
        }
    }
}

struct LoginView: View {
    @Bindable var store: StoreOf<LoginFeature>
    
    init(store: StoreOf<LoginFeature>) {
        self.store = store
    }
    
    var body: some View {
        VStack {
            Spacer()
            Image(.splash)
                .resizable()
                .scaledToFit()
                .frame(width: 242, height: 100)
            Spacer()
            
            VStack {
                Button(action: {
                    store.send(.login)
                }) {
                    Text("Google Login")
                }
                .frame(width: 330, height: 55)
                .background(Color.white)
                .cornerRadius(10)
                
                Button(action: {
                    store.send(.login)
                }) {
                    Text("Apple Login")
                }
                .frame(width: 330, height: 55)
                .background(Color.white)
                .cornerRadius(10)
                
                Button("로그인 없이 바로 시작") {
                    store.send(.login)
                }
                .buttonStyle(.borderless)
                .padding()
            }
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.personal)
        .edgesIgnoringSafeArea(.all)
    }
}
