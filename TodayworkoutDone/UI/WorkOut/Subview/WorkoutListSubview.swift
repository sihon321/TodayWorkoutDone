//
//  WorkoutListSubview.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/27.
//

import SwiftUI
import ComposableArchitecture

struct WorkoutListSubview: View {
    @Bindable var store: StoreOf<WorkoutListReducer>
    var workouts: Workout

    var body: some View {
        VStack {
            Button(action: {
                workouts.isSelected = !workouts.isSelected
                store.send(.updateMyRoutine(workouts))
            }) {
                HStack {
                    if let image = UIImage(named: "default") {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .cornerRadius(10)
                            .padding([.leading], 15)
                    }
                    Text(workouts.name)
                    Spacer()
                    if store.myRoutine.routines.contains(where: { $0.workout.id == workouts.id }) {
                        Image(systemName:"checkmark")
                    }
                }
            }
        }
        .frame(minWidth: 0,
               maxWidth: .infinity,
               maxHeight: 60,
               alignment: .leading)
    }
}
