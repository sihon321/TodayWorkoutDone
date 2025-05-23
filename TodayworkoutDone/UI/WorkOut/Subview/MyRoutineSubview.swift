//
//  MyWorkoutSubview.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct MyRoutineSubviewReducer {
    @ObservableState
    struct State: Equatable, Identifiable {
        let id: UUID
        var myRoutine: MyRoutineState
        
        init(myRoutine: MyRoutineState) {
            self.id = UUID()
            self.myRoutine = myRoutine
        }
    }
    
    enum Action {
        case touchedMyRoutine(MyRoutineState)
        case touchedEditMode(MyRoutineState)
        case touchedDelete(MyRoutineState)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            default:
                return .none
            }
        }
    }
}

struct MyRoutineSubview: View {
    @Bindable var store: StoreOf<MyRoutineSubviewReducer>
    @ObservedObject var viewStore: ViewStoreOf<MyRoutineSubviewReducer>
    
    init(store: StoreOf<MyRoutineSubviewReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(viewStore.myRoutine.name)
                    .font(.system(size: 18,
                                  weight: .semibold,
                                  design: .default))
                    .padding(.leading, 15)
                    .foregroundColor(.black)
                Spacer()
                Button(action: {}) {
                    Menu {
                        Button(action: {
                            viewStore.send(.touchedEditMode(store.myRoutine))
                        }) {
                            Label("편집", systemImage: "pencil")
                        }
                        Button(action: {
                            viewStore.send(.touchedDelete(store.myRoutine))
                        }) {
                            Label("삭제", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .contentShape(Rectangle())
                            .frame(minHeight: 20)
                            .padding(.trailing, 15)
                            .tint(Color(0x939393))
                    }
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 5)
            
            ForEach(viewStore.myRoutine.routines) { routine in
                Text(routine.workout.name)
                    .font(.system(size: 12,
                                  weight: .light,
                                  design: .default))
                    .padding(.leading, 15)
                    .foregroundColor(Color(0x939393))
            }
            
            Spacer()
        }
        .frame(width: 150,
               height: 120,
               alignment: .leading)
        .background(Color.white)
        .cornerRadius(15)
    }
}
