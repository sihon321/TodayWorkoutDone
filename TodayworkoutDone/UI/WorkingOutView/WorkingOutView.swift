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
    @Binding var isPresentWorkingOutView: Bool
    @Binding var isPresentWorkoutView: PresentationMode
    @Environment(\.injected) private var injected: DIContainer
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(injected.appState[\.userData.selectionWorkouts]) { excercise in
                    WorkingOutSection(workouts: .constant(excercise),
                                      editMode: $editMode)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {

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
        WorkingOutView(isPresentWorkingOutView: .constant(true),
                       isPresentWorkoutView: presentationmode)
    }
}
