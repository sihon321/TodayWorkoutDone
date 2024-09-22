//
//  ExcerciseStartView.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/03/19.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct ExcerciseStarter {
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
    }
    
    enum Action {
        case destination(PresentationAction<Destination.Action>)
        case startButtonTapped
        
        var description: String {
            return "\(self)"
        }
    }
    
    @Reducer(state: .equatable)
    enum Destination {
        case workoutView(WorkoutReducer)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            print(action.description)
            switch action {
            case .startButtonTapped:
                state.destination = .workoutView(WorkoutReducer.State())
                return .none
            case .destination:
              return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) {
          Destination.body
        }
    }
}

struct ExcerciseStartView: View {
    @Bindable var store: StoreOf<ExcerciseStarter>
    @ObservedObject var viewStore: ViewStoreOf<ExcerciseStarter>
    
    init(store: StoreOf<ExcerciseStarter>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        VStack {
            Spacer()
            Button(action: {
                viewStore.send(.startButtonTapped)
            }) {
                Text("워크아웃 시작")
                    .frame(minWidth: 0, maxWidth: .infinity - 30)
                    .padding([.top, .bottom], 5)
                    .background(Color(0xfeb548))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0,
                                                style: .continuous))
            }
            .padding(.horizontal, 30)
            .fullScreenCover(
                item: $store.scope(state: \.destination?.workoutView,
                                   action: \.destination.workoutView)
            ) { store in
                WorkoutView(store: store)
            }
            .offset(y: -15)
        }
    }
}
