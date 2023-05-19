//
//  MakeWorkoutView.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/05/17.
//

import SwiftUI

struct MakeWorkoutView: View {
    private let gridLayout: [GridItem] = [GridItem(.flexible())]
    @State private var editMode: EditMode = .active
    @Binding var isPresentWorkingOutView: Bool
    @Binding var isPresentWorkoutView: PresentationMode
    @Binding var selectionWorkouts: [Excercise]
    @EnvironmentObject var myObject: MyObservableObject
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach($selectionWorkouts) { excercise in
                    WorkingOutSection(workouts: excercise,
                                      editMode: $editMode)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresentWorkingOutView = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        myObject.selectionWorkouts = selectionWorkouts
                        isPresentWorkingOutView = false
                        myObject.isWorkingOutView.toggle()
                        isPresentWorkoutView.dismiss()
                    }
                }
            }
            .navigationTitle("타이틀")
            .listStyle(.grouped)
        }
    }}

struct MakeWorkoutView_Previews: PreviewProvider {
    @Environment(\.presentationMode) static var presentationmode
    static var previews: some View {
        MakeWorkoutView(isPresentWorkingOutView: .constant(true),
                       isPresentWorkoutView: presentationmode,
                       selectionWorkouts: .constant([]))
    }
}
