//
//  FixedTimeTextFieldView.swift
//  TodayworkoutDone
//
//  Created by ocean on 5/19/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct FixedTimeInputReducer {
    @ObservableState
    struct State: Equatable {
        var inputText: String = ""
        var rawInput: String = ""
        var formattedTime: String {
            let digitsOnly = rawInput.filter { $0.isNumber }
            let number = Int(digitsOnly) ?? 0
            let minutes = number / 100
            let seconds = number % 100
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    enum Action {
        case textChanged(String)
        case textEditingEnded
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .textChanged(newValue):
                let digits = newValue.filter { $0.isNumber }
                state.inputText = String(digits.prefix(4)) // 최대 4자리 제한
                return .none
            case .textEditingEnded:
                state.rawInput = state.inputText
                return .none
            }
        }
    }
}

struct FixedTimeTextFieldView: View {
    @Bindable var store: StoreOf<FixedTimeInputReducer>
    @ObservedObject var viewStore: ViewStoreOf<FixedTimeInputReducer>
    @FocusState private var isFocused: Bool
    
    init(store: StoreOf<FixedTimeInputReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        VStack {
            TextField(
                "시간 입력",
                text: viewStore.binding(
                    get: \.formattedTime,
                    send: FixedTimeInputReducer.Action.textChanged
                )
            )
            .focused($isFocused)
            .onChange(of: isFocused) { _, newValue in
                if !newValue {
                    self.store.send(.textEditingEnded)
                }
            }
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .font(.system(size: 20))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
        }
        .padding()
    }
}
