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
        var workoutName: String
        var equipmentType: EquipmentType
        var editMode: EditMode
    }
    
    enum Action {
        case tappedWorkoutsType(type: EquipmentType)
        case deleteWorkout
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .tappedWorkoutsType:
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
    
    @State private var equipmentType: EquipmentType
    @State private var showingOptions = false
    
    init(store: StoreOf<WorkingOutHeaderReducer>,
         equipmentType: State<EquipmentType>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
        self._equipmentType = equipmentType
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(store.workoutName)
                    .font(.system(size: 20, weight: .semibold))
                
                Button(action: {}) {
                    Menu {
                        Button(action: {
                            store.send(.tappedWorkoutsType(type: .machine))
                            equipmentType = .machine
                        }) {
                            Label("머신", systemImage: "pencil")
                        }
                        Button(action: {
                            store.send(.tappedWorkoutsType(type: .barbel))
                            equipmentType = .barbel
                        }) {
                            Label("바벨", systemImage: "pencil")
                        }
                        Button(action: {
                            store.send(.tappedWorkoutsType(type: .dumbbel))
                            equipmentType = .dumbbel
                        }) {
                            Label("덤벨", systemImage: "pencil")
                        }
                        Button(action: {
                            store.send(.tappedWorkoutsType(type: .cable))
                            equipmentType = .cable
                        }) {
                            Label("케이블", systemImage: "pencil")
                        }
                    } label: {
                        Text(equipmentType.kor)
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
