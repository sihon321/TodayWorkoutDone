//
//  WorkingOutView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/28.
//

import SwiftUI

struct WorkingOutView: View {
    @Environment(\.injected) private var injected: DIContainer
    @State private var editMode: EditMode = .inactive
    @State private var isSavedWorkout: Bool = false
    @Binding var isCloseWorking: Bool
    @Binding var hideTabValue: CGFloat
    @Binding var isSavedAlert: Bool
    
    private let gridLayout: [GridItem] = [GridItem(.flexible())]
    private var myRoutine: MyRoutine {
        injected.appState[\.userData.myRoutine]
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(myRoutine.routines) { routine in
                    WorkingOutSection(
                        routine: .constant(routine),
                        editMode: $editMode
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        isSavedWorkout.toggle()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        editMode = editMode == .active ? .inactive : .active
                    }
                }
            }
            .navigationTitle(myRoutine.name)
            .listStyle(.grouped)
            .padding([.bottom], 60)
        }
        .alert("워크아웃을 저장하겠습니까?", isPresented: $isSavedWorkout) {
            Button("Cancel") { }
            Button("OK") {
                injected.appState[\.routing.homeView.workingOutView] = false
                isCloseWorking = true
                hideTabValue = 0.0
                if !injected.interactors.routineInteractor.find(myRoutine: myRoutine) {
                    isSavedAlert = true
                }
                saveWorkoutRoutine()
            }
        } message: {
            Text("새로운 워크아웃을 저장하시겟습니까")
        }
    }
}

private extension WorkingOutView {
    func saveWorkoutRoutine() {
        injected.interactors.routineInteractor.store(
            workoutRoutine: WorkoutRoutine(date: Date(), myRoutine: myRoutine)
        )
    }
}

struct WorkingOutView_Previews: PreviewProvider {
    @Environment(\.presentationMode) static var presentationmode
    static var previews: some View {
        WorkingOutView(isCloseWorking: .constant(false),
                       hideTabValue: .constant(0.0),
                       isSavedAlert: .constant(false))
    }
}
