//
//  RestTimerView.swift
//  TodayworkoutDone
//
//  Created by ocean on 5/19/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct RestTimerViewReducer {
    @ObservableState
    struct State: Equatable {
        var workoutTimeText: FixedTimeInputReducer.State
        var setTimeText: FixedTimeInputReducer.State
        
        init(workoutRestTime: Int, setRestTime: Int) {
            workoutTimeText = .init(rawInput: "\(workoutRestTime)")
            setTimeText = .init(rawInput: "\(setRestTime)")
        }
    }
    
    enum Action {
        case confirmRestTime(Int, Int)
        case workoutTimeText(FixedTimeInputReducer.Action)
        case setTimeText(FixedTimeInputReducer.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.workoutTimeText, action: \.workoutTimeText) {
            FixedTimeInputReducer()
        }
        Scope(state: \.setTimeText, action: \.setTimeText) {
            FixedTimeInputReducer()
        }
        Reduce { state, action in
            switch action {
            case .confirmRestTime:
                return .none
            case .workoutTimeText:
                return .none
            case .setTimeText:
                return .none
            }
        }
    }
}

struct RestTimerView: View {
    @Bindable var store: StoreOf<RestTimerViewReducer>
    @ObservedObject var viewStore: ViewStoreOf<RestTimerViewReducer>

    init(store: StoreOf<RestTimerViewReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        VStack {
            Spacer(minLength: 25)
            HStack {
                Text("워크아웃 휴식")
                    .frame(width: 100)
                FixedTimeTextFieldView(store: Store(initialState: viewStore.workoutTimeText) {
                    FixedTimeInputReducer()
                })
            }
            HStack {
                Text("세트 휴식")
                    .frame(width: 100)
                FixedTimeTextFieldView(store: Store(initialState: viewStore.setTimeText) {
                    FixedTimeInputReducer()
                })
            }
            Spacer()
            Button("확인") {
                let workoutTime = timeStringToSeconds(viewStore.workoutTimeText.rawInput)
                let setTime = timeStringToSeconds(viewStore.setTimeText.rawInput)
                viewStore.send(.confirmRestTime(workoutTime, setTime))
            }
            .frame(maxWidth: .infinity, minHeight: 30)
            
        }
        .padding()
        .frame(width: 300, height: 200)
        .background(Color.white)
        .mask(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 20)
    }

    func timeStringToSeconds(_ time: String) -> Int {
        let components = time.split(separator: ":")
        guard components.count == 2,
              let minutes = Int(components[0]),
              let seconds = Int(components[1]) else {
            return 0
        }
        return minutes * 60 + seconds
    }
}
