//
//  WorkingOutHeader.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/02/13.
//

import SwiftUI
import ComposableArchitecture
import PopupView

@Reducer
struct WorkingOutHeaderReducer {
    @ObservableState
    struct State: Equatable {
        var routine: RoutineState
        var editMode: EditMode
        var restTimer: RestTimerViewReducer.State
        
        init(routine: RoutineState, editMode: EditMode) {
            self.routine = routine
            self.editMode = editMode
            self.restTimer = RestTimerViewReducer.State(
                workoutRestTime: routine.restTime,
                setRestTime: routine.sets.first?.restTime ?? 0
            )
        }
    }
    
    enum Action {
        case tappedWorkoutsType(type: EquipmentType)
        case deleteWorkout
        case restTimer(RestTimerViewReducer.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.restTimer, action: \.restTimer) {
            RestTimerViewReducer()
        }
        Reduce { state, action in
            switch action {
            case let .tappedWorkoutsType(type):
                state.routine.equipmentType = type
                return .none
            case .deleteWorkout:
                return .none
            case .restTimer:
                return .none
            }
        }
    }
}

struct WorkingOutHeader: View {
    @Bindable var store: StoreOf<WorkingOutHeaderReducer>
    @ObservedObject var viewStore: ViewStoreOf<WorkingOutHeaderReducer>
    @State private var showingOptions = false
    @State var showPopup = false
    
    init(store: StoreOf<WorkingOutHeaderReducer>,
         equipmentType: State<EquipmentType>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(viewStore.routine.workout.name)
                    .font(.system(size: 20, weight: .semibold))
                
                Button(action: {}) {
                    Menu {
                        Button(action: {
                            viewStore.send(.tappedWorkoutsType(type: .machine))
                        }) {
                            Label("머신", systemImage: "pencil")
                        }
                        Button(action: {
                            viewStore.send(.tappedWorkoutsType(type: .barbel))
                        }) {
                            Label("바벨", systemImage: "pencil")
                        }
                        Button(action: {
                            viewStore.send(.tappedWorkoutsType(type: .dumbbel))
                        }) {
                            Label("덤벨", systemImage: "pencil")
                        }
                        Button(action: {
                            viewStore.send(.tappedWorkoutsType(type: .cable))
                        }) {
                            Label("케이블", systemImage: "pencil")
                        }
                    } label: {
                        Text(viewStore.routine.equipmentType.kor)
                            .padding([.leading, .trailing], 5)
                            .padding([.top, .bottom], 3)
                            .font(.system(size: 11))
                            .foregroundStyle(.white)
                            .background(Color.personal.opacity(0.6))
                            .cornerRadius(3.0)
                    }
                }
                Spacer()
                Image(systemName: "ellipsis")
                    .resizable()
                    .frame(width: 15, height: 4)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 7)
                    .foregroundStyle(Color.personal)
                    .background(Color.personal.opacity(0.3))
                    .cornerRadius(3.0)
                    .onTapGesture {
                        showingOptions = true
                    }
                    .confirmationDialog("select", isPresented: $showingOptions) {
                        Button("삭제") {
                            store.send(.deleteWorkout)
                        }
                        Button("휴식시간 설정") {
                            showPopup.toggle()
                        }
                        .popup(isPresented: $showPopup) {
                            RestTimerView(store: Store(initialState: viewStore.restTimer) {
                                RestTimerViewReducer()
                            })
                        } customize: {
                            $0
                                .closeOnTap(false)
                                .backgroundColor(.black.opacity(0.4))
                                .appearFrom(.centerScale)
                        }
                    }
            }
            HStack {
                Text("세트")
                    .font(.system(size: 17, weight: .medium))
                if viewStore.editMode == .inactive {
                    Text("이전")
                        .font(.system(size: 17, weight: .medium))
                        .frame(minWidth: 140)
                }
                Text("랩")
                    .font(.system(size: 17, weight: .medium))
                    .frame(minWidth: viewStore.editMode == .inactive ? 85 : 160)
                Text("kg")
                    .font(.system(size: 17, weight: .medium))
                    .frame(minWidth: viewStore.editMode == .inactive ? 85 : 160)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
