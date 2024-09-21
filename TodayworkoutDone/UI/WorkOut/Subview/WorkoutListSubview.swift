//
//  WorkoutListSubview.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/27.
//

import SwiftUI
import Combine

struct WorkoutListSubview: View {
    var workouts: Workout
    
    var body: some View {
        VStack {
            Button(action: {
                workouts.isSelected = !workouts.isSelected
            }) {
                HStack {
                    Image(uiImage: UIImage(named: "woman")!)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .padding([.leading], 15)
                    Text(workouts.name)
                    Spacer()
                    if workouts.isSelected {
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
