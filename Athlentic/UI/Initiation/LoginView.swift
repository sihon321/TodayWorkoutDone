//
//  LoginView.swift
//  TodayworkoutDone
//
//  Created by oceano on 3/2/25.
//

import SwiftUI
import ComposableArchitecture
import AuthenticationServices

@Reducer
struct LoginFeature {
    @ObservableState
    struct State: Equatable {
        var isAuthorizingAppleID = false
        var errorMessage: String?
        var isAuthorizingGoogle = false
        var googleErrorMessage: String?
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case notLogin
        // Apple Sign-In
        case appleSignInButtonTapped
        case appleAuthorizationRequested(ASAuthorizationAppleIDRequest)
        case appleAuthorizationResponse(Result<ASAuthorization, Error>)
        // Google Sign-In
        case googleSignInButtonTapped
        case googleAuthorizationRequested
        case googleAuthorizationResponse(Result<Void, Error>)
        
        case delegate(DelegateAction)
        enum DelegateAction {
            case didLoginSuccessfully
        }
    }
    
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .notLogin:
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                return .none
                
            case .appleSignInButtonTapped:
                state.isAuthorizingAppleID = true
                return .none
                
            case .appleAuthorizationRequested:
                // No state change here; request is configured in the view.
                return .none
                
            case let .appleAuthorizationResponse(result):
                state.isAuthorizingAppleID = false
                switch result {
                case .success(let authorization):
                    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                        UserDefaults.standard.set(appleIDCredential.user, forKey: "appleUserId")
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                        return .send(.delegate(.didLoginSuccessfully))
                    }
                    return .none
                case .failure(let error):
                    state.errorMessage = error.localizedDescription
                    return .none
                }
                
            case .googleSignInButtonTapped:
                state.isAuthorizingGoogle = true
                return .none

            case .googleAuthorizationRequested:
                // Trigger your Google Sign-In flow from the View/Coordinator and report back via googleAuthorizationResponse
                return .none

            case let .googleAuthorizationResponse(result):
                state.isAuthorizingGoogle = false
                switch result {
                case .success:
                    return .none
                case .failure(let error):
                    state.googleErrorMessage = error.localizedDescription
                    return .none
                }
                
            case .delegate:
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
    
    private var isLoading: Bool {
        store.isAuthorizingGoogle || store.isAuthorizingAppleID
    }
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Image(.splash)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 242, height: 100)
                Spacer()
                
                VStack {
                    GoogleSignInButton(
                        onTap: {
                            store.send(.googleSignInButtonTapped)
                            // Start Google sign-in here (presenting UI via SDK), then report request/action
                            store.send(.googleAuthorizationRequested)
                            // When your SDK completes, call store.send(.googleAuthorizationResponse(.success(()))) or failure accordingly.
                        }
                    )
                    .frame(width: 330, height: 55)
                    
                    AppleSignInButton(
                        onRequest: { request in
                            store.send(.appleSignInButtonTapped)
                            request.requestedScopes = [.fullName, .email]
                            store.send(.appleAuthorizationRequested(request))
                        },
                        onCompletion: { result in
                            store.send(.appleAuthorizationResponse(result))
                        }
                    )
                    .frame(width: 330, height: 55)
                    
                    Button("로그인 없이 바로 시작") {
                        store.send(.notLogin)
                    }
                    .buttonStyle(.borderless)
                    .padding()
                    
                    if let message = store.errorMessage {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                    if let gMessage = store.googleErrorMessage {
                        Text(gMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
                .padding(.bottom, 30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.personal)
            
            if isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

private struct AppleSignInButton: View {
    let onRequest: (ASAuthorizationAppleIDRequest) -> Void
    let onCompletion: (Result<ASAuthorization, Error>) -> Void

    var body: some View {
        SignInWithAppleButton(.signIn, onRequest: { request in
            onRequest(request)
        }, onCompletion: { result in
            onCompletion(result)
        })
        .signInWithAppleButtonStyle(.black)
    }
}

private struct GoogleSignInButton: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                // Simple G icon placeholder; replace with your asset if available
                Image(systemName: "g.circle")
                    .imageScale(.large)
                Text("Sign in with Google")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundStyle(Color.black)
            .padding(.horizontal)
        }
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .frame(height: 55)
    }
}
