//
//  WorkingOutView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/28.
//

import SwiftUI

struct WorkingOutView: View {
    private let gridLayout: [GridItem] = [GridItem(.flexible())]
    @State private var editMode: EditMode = .active
    var makeWorkingOutView: Bool
    @Binding var isPresentWorkingOutView: Bool
    @Binding var isPresentWorkoutView: PresentationMode
    @Binding var selectionWorkouts: [Excercise]
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach($selectionWorkouts) { excercise in
                    WorkingOutSection(workouts: excercise,
                                      editMode: $editMode)
                }
            }
            .toolbar {
                if makeWorkingOutView {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            isPresentWorkingOutView = false
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            isPresentWorkingOutView = false
                            isPresentWorkoutView.dismiss()
                        }
                    }
                }
            }
            .navigationTitle("타이틀")
            .listStyle(.grouped)
        }
    }
}

struct WorkingOutView_Previews: PreviewProvider {
    @Environment(\.presentationMode) static var presentationmode
    static var previews: some View {
        WorkingOutView(makeWorkingOutView: true,
                       isPresentWorkingOutView: .constant(true),
                       isPresentWorkoutView: presentationmode,
                       selectionWorkouts: .constant([]))
    }
}
