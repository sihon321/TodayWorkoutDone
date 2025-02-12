//
//  MyWorkoutSubview.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/25.
//

import SwiftUI
import ComposableArchitecture

struct MyWorkoutSubview: View {
    @Bindable var store: StoreOf<MyRoutineReducer>
    private var myRoutine: MyRoutine
    
    init(store: StoreOf<MyRoutineReducer>, myRoutine: MyRoutine) {
        self.store = store
        self.myRoutine = myRoutine
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(myRoutine.name)
                    .font(.system(size: 18,
                                  weight: .semibold,
                                  design: .default))
                    .padding(.leading, 15)
                    .foregroundColor(.black)
                Spacer()
                Button(action: {}) {
                    Menu {
                        Button(action: {
                            store.send(.touchedEditMode(myRoutine))
                        }) {
                            Label("편집", systemImage: "pencil")
                        }
                        Button(action: {
                            store.send(.touchedDelete(myRoutine))
                        }) {
                            Label("삭제", systemImage: "pencil")
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
            VStack(alignment: .leading) {
                ForEach(myRoutine.routines) { routine in
                    Text(routine.workout.name)
                        .font(.system(size: 12,
                                      weight: .light,
                                      design: .default))
                        .padding(.leading, 15)
                        .foregroundColor(Color(0x939393))
                }
            }
            .padding(.top, 1)
        }
        .frame(width: 150,
               height: 120,
               alignment: .leading)
        .background(Color.white)
        .cornerRadius(15)
    }
}
