//
//  WorkoutListSubview.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/27.
//

import SwiftUI

struct WorkoutListSubview: View {
    var workouts: Workouts
    
    var body: some View {
        HStack {
            Image(uiImage: UIImage(named: "woman")!)
                .resizable()
                .frame(width: 50, height: 50)
                .padding([.leading], 15)
            Text(workouts.name ?? "")
        }
        .frame(minWidth: 0,
               maxWidth: .infinity,
               maxHeight: 60,
               alignment: .leading)
    }
}

struct WorkoutListSubview_Previews: PreviewProvider {
    @StateObject static var dataController = DataController()
    
    static var workouts = {
        let workouts = Workouts(context: dataController.container.viewContext)
        workouts.name = "name"
        workouts.category = "category"
        workouts.target = "target"
        return workouts
    }()
    static var previews: some View {
        WorkoutListSubview(workouts: workouts)
            .environment(\.managedObjectContext, dataController.container.viewContext)
    }
}
