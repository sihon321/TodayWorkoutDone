//
//  LoginView.swift
//  TodayworkoutDone
//
//  Created by oceano on 3/2/25.
//

import SwiftUI
import ComposableArchitecture
import AuthenticationServices
import GoogleSignIn

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
        case appleSignInStarted
        case appleAuthorizationResponse(Result<ASAuthorization, Error>)
        // Google Sign-In
        case googleSignInButtonTapped
        case googleAuthorizationResponse(Result<GIDGoogleUser, Error>)
        
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
                return .send(.delegate(.didLoginSuccessfully))
                
            case .appleSignInStarted:
                state.isAuthorizingAppleID = true
                return .none
                
            case let .appleAuthorizationResponse(result):
                state.isAuthorizingAppleID = false
                switch result {
                case .success(let authorization):
                    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                        UserDefaults.standard.set(appleIDCredential.user, forKey: "appleUserId")
                        if let email = appleIDCredential.email {
                            UserDefaults.standard.set(email, forKey: "appleUserEmail")
                        }
                        if let fullName = appleIDCredential.fullName {
                            let name = [fullName.givenName, fullName.familyName]
                                .compactMap { $0 }
                                .joined(separator: " ")
                            if !name.isEmpty {
                                UserDefaults.standard.set(name, forKey: "appleUserName")
                            }
                        }
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                        return .send(.delegate(.didLoginSuccessfully))
                    }
                    return .none
                case .failure(let error):
                    // 사용자가 취소한 경우는 에러 메시지를 표시하지 않음
                    if (error as NSError).code == ASAuthorizationError.canceled.rawValue {
                        return .none
                    }
                    state.errorMessage = error.localizedDescription
                    return .none
                }
                
            case .googleSignInButtonTapped:
                state.isAuthorizingGoogle = true
                return .run { send in
                    do {
                        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
                              let rootViewController = await windowScene.windows.first?.rootViewController else {
                            await send(.googleAuthorizationResponse(.failure(GoogleSignInError.noRootViewController)))
                            return
                        }
                        
                        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
                        await send(.googleAuthorizationResponse(.success(result.user)))
                    } catch {
                        await send(.googleAuthorizationResponse(.failure(error)))
                    }
                }
                
            case let .googleAuthorizationResponse(result):
                state.isAuthorizingGoogle = false
                switch result {
                case .success(let user):
                    UserDefaults.standard.set(user.userID, forKey: "googleUserId")
                    UserDefaults.standard.set(user.profile?.email, forKey: "googleUserEmail")
                    UserDefaults.standard.set(user.profile?.name, forKey: "googleUserName")
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    return .send(.delegate(.didLoginSuccessfully))
                case .failure(let error):
                    // 사용자가 취소한 경우는 에러 메시지를 표시하지 않음
                    if (error as NSError).code == GIDSignInError.canceled.rawValue {
                        return .none
                    }
                    state.googleErrorMessage = error.localizedDescription
                    return .none
                }
                
            case .delegate:
                return .none
            }
        }
    }
}

enum GoogleSignInError: LocalizedError {
    case noRootViewController
    
    var errorDescription: String? {
        switch self {
        case .noRootViewController:
            return "화면을 찾을 수 없습니다. 다시 시도해주세요."
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
                        }
                    )
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                    
                    AppleSignInButton(
                        onRequest: { request in
                            store.send(.appleSignInStarted)
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            store.send(.appleAuthorizationResponse(result))
                        }
                    )
                    .padding(.horizontal, 30)
                    
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
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .cornerRadius(10)
    }
}

private struct GoogleSignInButton: View {
    let onTap: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image("GoogleLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                
                Text("Sign in with Google")
                    .font(.system(size: 19, weight: .semibold))
                // 2. 글자색: 다크모드면 흰색, 라이트모드면 검은색
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            // 3. 배경색: 다크모드면 검은색(혹은 다크그레이), 라이트모드면 흰색
            .background(colorScheme == .dark ? .black : .white)
            .cornerRadius(10)
            // 4. 테두리: 다크모드일 때는 흰색 테두리가 살짝 있어야 버튼 구분이 잘 됨
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(colorScheme == .dark ? .white.opacity(0.2) : .gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}
