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
        var routine: Routine
    }
    
    enum Action {
        case tappedWorkoutsType(type: WorkoutsType)
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
    @State private var showingOptions = false
    
    init(store: StoreOf<WorkingOutHeaderReducer>) {
        self.store = store
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(store.routine.workout.name)
                    .font(.title2)
                
                Button(action: {}) {
                    Menu {
                        Button(action: {
                            store.send(.tappedWorkoutsType(type: .machine))
                        }) {
                            Label("머신", systemImage: "pencil")
                        }
                        Button(action: {
                            store.send(.tappedWorkoutsType(type: .barbel))
                        }) {
                            Label("바벨", systemImage: "pencil")
                        }
                        Button(action: {
                            store.send(.tappedWorkoutsType(type: .dumbbel))
                        }) {
                            Label("덤벨", systemImage: "pencil")
                        }
                        Button(action: {
                            store.send(.tappedWorkoutsType(type: .cable))
                        }) {
                            Label("케이블", systemImage: "pencil")
                        }
                    } label: {
                        Text(store.routine.workoutsType.kor)
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
                Text("횟수")
                    .padding(.leading, 30)
                Text("무게")
                    .padding(.leading, 60)
            }
        }
    }
}
