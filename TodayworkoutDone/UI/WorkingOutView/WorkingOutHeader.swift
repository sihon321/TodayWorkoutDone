//
//  WorkingOutHeader.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/02/13.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct WorkingOutHeaderReducer {
    @ObservableState
    struct State: Equatable {
        var routine: RoutineState
        var editMode: EditMode
        
        init(routine: RoutineState, editMode: EditMode) {
            self.routine = routine
            self.editMode = editMode
        }
    }
    
    enum Action {
        case tappedWorkoutsType(type: EquipmentType)
        case deleteWorkout
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .tappedWorkoutsType(type):
                state.routine.equipmentType = type
                return .none
            case .deleteWorkout:
                return .none
            }
        }
    }
}

struct WorkingOutHeader: View {
    @Bindable var store: StoreOf<WorkingOutHeaderReducer>
    @ObservedObject var viewStore: ViewStoreOf<WorkingOutHeaderReducer>
    @State private var showingOptions = false
    
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
                
                switch viewStore.routine.workout.category.categoryType {
                case .strength:
                    strengthEquipmentButton()
                case .pilates:
                    pilatesEquipmentButton()
                default:
                    EmptyView()
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
                    }
            }
            
            switch viewStore.routine.workout.category.categoryType {
            case .strength:
                strengthHeader()
            case .cardio, .pilates, .yoga:
                durationHeader()
            case .stretching:
                stretchingHeader()
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private func strengthEquipmentButton() -> some View {
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
    }
    
    @ViewBuilder
    private func pilatesEquipmentButton() -> some View {
        Button(action: {}) {
            Menu {
                Button(action: {
                    viewStore.send(.tappedWorkoutsType(type: .machine))
                }) {
                    Label("매트", systemImage: "pencil")
                }
                Button(action: {
                    viewStore.send(.tappedWorkoutsType(type: .barbel))
                }) {
                    Label("리포머", systemImage: "pencil")
                }
                Button(action: {
                    viewStore.send(.tappedWorkoutsType(type: .dumbbel))
                }) {
                    Label("캐딜락", systemImage: "pencil")
                }
                Button(action: {
                    viewStore.send(.tappedWorkoutsType(type: .cable))
                }) {
                    Label("체어", systemImage: "pencil")
                }
                Button(action: {
                    viewStore.send(.tappedWorkoutsType(type: .cable))
                }) {
                    Label("바렐", systemImage: "pencil")
                }
                Button(action: {
                    viewStore.send(.tappedWorkoutsType(type: .cable))
                }) {
                    Label("스프링보드", systemImage: "pencil")
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
    }
    
    @ViewBuilder
    private func strengthHeader() -> some View {
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
                .frame(minWidth: viewStore.editMode == .inactive ? 85 : 110)
                
            Text("kg")
                .font(.system(size: 17, weight: .medium))
                .frame(minWidth: viewStore.editMode == .inactive ? 85 : 100)
                
            if viewStore.editMode == .active {
                Text("휴식시간")
                    .font(.system(size: 17, weight: .medium))
                    .frame(minWidth: 100)
            }
        }
    }
    
    @ViewBuilder
    private func durationHeader() -> some View {
        HStack {
            Text("세트")
                .font(.system(size: 17, weight: .medium))
            if viewStore.editMode == .inactive {
                Text("이전")
                    .font(.system(size: 17, weight: .medium))
                    .frame(minWidth: 140)
            }
            Text("진행시간")
                .font(.system(size: 17, weight: .medium))
                .frame(minWidth: viewStore.editMode == .inactive ? 85 : 110)
                
            if viewStore.editMode == .active {
                Text("휴식시간")
                    .font(.system(size: 17, weight: .medium))
                    .frame(minWidth: 100)
            }
        }
    }
    
    @ViewBuilder
    private func stretchingHeader() -> some View {
        HStack {
            if viewStore.editMode == .inactive {
                Text("이전")
                    .font(.system(size: 17, weight: .medium))
                    .frame(minWidth: 140)
            }
            Text("진행시간")
                .font(.system(size: 17, weight: .medium))
                .frame(minWidth: viewStore.editMode == .inactive ? 85 : 110)
        }
    }
}
