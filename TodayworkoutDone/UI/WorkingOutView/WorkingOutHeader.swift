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
    
    init(store: StoreOf<WorkingOutHeaderReducer>, equipmentType: State<EquipmentType>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
        self._equipmentType = equipmentType
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(store.workoutName)
                    .font(.title2)
                
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
                            .foregroundStyle(.black)
                            .background(.gray)
                            .cornerRadius(3.0)
                            .padding(.top, 8)
                    }
                }
                Spacer()
                Image(systemName: "ellipsis")
                    .onTapGesture {
                        showingOptions = true
                    }
                    .confirmationDialog("select", isPresented: $showingOptions) {
                        Button("삭제") {
                            store.send(.deleteWorkout)
                        }
                    }
            }
            .padding()
            HStack {
                Text("세트")
                    .padding(.leading, 17)
                Text("이전")
                    .padding(.leading, 70)
                Text("랩")
                    .padding(.leading, 65)
                Text("KG")
                    .padding(.leading, 50)
            }
        }
    }
}
