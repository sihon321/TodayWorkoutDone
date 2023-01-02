//
//  WorkoutListView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/27.
//

import SwiftUI

struct WorkoutListView: View {
    var body: some View {
        List(0..<10) { _ in
            WorkoutListSubview()
        }
        .listStyle(.plain)
    }
}

struct WorkoutListView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutListView()
    }
}
