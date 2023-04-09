//
//  WorkingOutSection.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/02/13.
//

import SwiftUI

struct WorkingOutSection: View {
    @Binding var workouts: Excercise
    @Binding var editMode: EditMode
    
    var body: some View {
        VStack {
            Section {
                ForEach(0..<1) { _ in
                    WorkingOutRow(workouts: $workouts, editMode: $editMode)
                        .padding(.bottom, 2)
                }
            } header: {
                WorkingOutHeader(workouts: $workouts)
            }
        }
    }
}

struct WorkingOutSection_Previews: PreviewProvider {
    static var previews: some View {
        WorkingOutSection(workouts: .constant(Excercise()),
                          editMode: .constant(.active))
    }
}
