//
//  WorkoutListSubview.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/27.
//

import SwiftUI
import Combine

struct WorkoutListSubview: View {
    @Environment(\.injected) private var injected: DIContainer
    @Binding var workouts: Workouts
    
    var body: some View {
        HStack {
            Button(action: {
                if injected.interactors.workoutInteractor.contains(workouts) {
                    injected.interactors.workoutInteractor.remove(workouts)
                } else {
                    injected.interactors.workoutInteractor.append(workouts)
                }
            }) {
                HStack {
                    Image(uiImage: UIImage(named: "woman")!)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .padding([.leading], 15)
                    Text(workouts.name ?? "")
                    Spacer()
                    if injected.interactors.workoutInteractor.contains(workouts) {
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

struct WorkoutListSubview_Previews: PreviewProvider {
    static var workouts = {
        let excercises = Workouts(name: "test", category: "test_category", target: "test_target")
        return excercises
    }()
    static var previews: some View {
        WorkoutListSubview(workouts: .constant(workouts))
    }
}
