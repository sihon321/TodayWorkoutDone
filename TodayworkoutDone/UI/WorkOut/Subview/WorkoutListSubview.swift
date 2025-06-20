//
//  WorkoutListSubview.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/27.
//

import SwiftUI
import ComposableArchitecture
import PopupView

@Reducer
struct WorkoutListSubviewReducer {
    @ObservableState
    struct State: Equatable, Identifiable {
        let id: UUID
        var workout: WorkoutState
        var isPopupShown: Bool = false
    }
    
    enum Action {
        case didTapped
        case popUpShown(Bool)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .didTapped:
                state.workout.isSelected = !state.workout.isSelected
                return .none
            case .popUpShown(let isShown):
                state.isPopupShown = isShown
                return .none
            }
        }
    }
}

struct WorkoutListSubview: View {
    @Bindable var store: StoreOf<WorkoutListSubviewReducer>
    @ObservedObject var viewStore: ViewStoreOf<WorkoutListSubviewReducer>
    
    init(store: StoreOf<WorkoutListSubviewReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        VStack {
            Button(action: {
                viewStore.send(.didTapped)
            }) {
                HStack {
                    if let image = UIImage(named: "default") {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .cornerRadius(10)
                    }
                    Text(viewStore.workout.name)
                        .font(.system(size: 15, weight: .light))
                        .foregroundStyle(.black)
                    Spacer()
                    if viewStore.workout.isSelected {
                        Image(systemName: "checkmark")
                            .foregroundStyle(Color.personal)
                    } else {
                        Button(action: {
                            viewStore.send(.popUpShown(true))
                        }) {
                            Image(systemName: "info.circle")
                        }
                    }
                }
            }
        }
        .frame(minWidth: 0,
               maxWidth: .infinity,
               maxHeight: 60,
               alignment: .leading)
        .popup(isPresented: viewStore.binding(
            get: \.isPopupShown,
            send: WorkoutListSubviewReducer.Action.popUpShown
        )) {
            WorkoutInfoView(workout: store.workout)
        } customize: {
            $0
            .appearFrom(.centerScale)
            .closeOnTap(true)
            .allowTapThroughBG(false)
            .backgroundColor(.black.opacity(0.4))
        }
    }
}
