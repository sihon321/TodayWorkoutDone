//
//  MyWorkoutSubview.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct MyWorkoutSubviewReducer {
    @ObservableState
    struct State {
        var myRoutine: MyRoutineState
    }
    
    enum Action {
        case touchedMyRoutine(MyRoutineState)
        case touchedEditMode(MyRoutineState)
        case touchedDelete(MyRoutineState)
    }
}

struct MyWorkoutSubview: View {
    @Bindable var store: StoreOf<MyWorkoutSubviewReducer>
    
    init(store: StoreOf<MyWorkoutSubviewReducer>) {
        self.store = store
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(store.myRoutine.name)
                    .font(.system(size: 18,
                                  weight: .semibold,
                                  design: .default))
                    .padding(.leading, 15)
                    .foregroundColor(.black)
                Spacer()
                Button(action: {}) {
                    Menu {
                        Button(action: {
                            store.send(.touchedEditMode(store.myRoutine))
                        }) {
                            Label("편집", systemImage: "pencil")
                        }
                        Button(action: {
                            store.send(.touchedDelete(store.myRoutine))
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
            
            ForEach(store.myRoutine.routines) { routine in
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
