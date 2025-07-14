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
        @Shared(.appStorage("weightUnit")) var weightUnit: SettingsReducer.WeightUnit = .meter
        
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
                
                Button(action: {}) {
                    Menu {
                        let types = viewStore.routine.workout.equipment.compactMap { EquipmentType(rawValue: $0) }
                        
                        ForEach(types, id: \.self) { type in
                            Button(action: {
                                viewStore.send(.tappedWorkoutsType(type: type))
                            }) {
                                Label(type.rawValue, systemImage: "pencil")
                            }
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
                    }
                    .tint(Color.todBlack)
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
                
            Text(viewStore.weightUnit.unit)
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
                    .frame(minWidth: 190)
            }
            Text("진행시간")
                .font(.system(size: 17, weight: .medium))
                .frame(maxWidth: .infinity)
                
            if viewStore.editMode == .active {
                Text("휴식시간")
                    .font(.system(size: 17, weight: .medium))
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    @ViewBuilder
    private func stretchingHeader() -> some View {
        HStack {
            if viewStore.editMode == .inactive {
                Text("이전")
                    .font(.system(size: 17, weight: .medium))
                    .frame(maxWidth: .infinity)
            }
            Text("진행시간")
                .font(.system(size: 17, weight: .medium))
                .frame(maxWidth: .infinity)
            Spacer()
                .frame(maxWidth: .infinity)
        }
    }
}
