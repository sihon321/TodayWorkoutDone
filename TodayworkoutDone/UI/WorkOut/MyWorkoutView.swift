//
//  MyWorkoutView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/25.
//

import SwiftUI
import Combine
import ComposableArchitecture

@Reducer
struct MyWorkoutReducer {
    @ObservableState
    struct State: Equatable {
        var text: String
    }
    
    enum Action {
        
    }
}

struct MyWorkoutView: View {
    @State private(set) var myRoutines: [MyRoutine]
    @State private var selectedRoutine: MyRoutine?
    @Binding var workoutsList: [Workout]
    
    init(myRoutines: [MyRoutine],
         workoutsList: Binding<[Workout]> = .constant([])) {
        self._myRoutines = .init(initialValue: myRoutines)
        self._workoutsList = .init(projectedValue: workoutsList)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("my workout")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(myRoutines) { myRoutine in
                        Button(action: {
//                            injected.appState[\.routing.myWorkoutView.alertMyWorkout] = true
                            selectedRoutine = MyRoutine(name: myRoutine.name,
                                                        routines:  myRoutine.routines)
                        }) {
                            MyWorkoutSubview(myRoutine: myRoutine)
                        }
                    }
                    .alert("루틴을 시작하겠습니까?", isPresented: .constant(false)) {
                        Button("Cancel") {
//                            injected.appState[\.routing.myWorkoutView.alertMyWorkout] = false
                        }
                        Button("OK") {
//                            injected.appState[\.routing.myWorkoutView.alertMyWorkout] = false
//                            injected.appState[\.routing.homeView.workingOutView] = true
                            if let selectedRoutine = selectedRoutine {
//                                injected.appState[\.userData.myRoutine] = selectedRoutine
                            }
                        }
                    } message: {
                        if let selectedRoutine = selectedRoutine {
                            let message = selectedRoutine.routines
                                .map({ "\($0.workouts.name)" })
                                .joined(separator: "\n")
                            Text(message)
                        }
                    }
                    .fullScreenCover(isPresented: .constant(false),
                                     content: {
                        if let routine = selectedRoutine {
                            MakeWorkoutView(myRoutine: .constant(routine),
                                            myRoutines: $myRoutines,
                                            workoutsList: $workoutsList,
                                            isEdit: true)
                        }
                    })
                }
            }
        }
        .padding([.leading, .trailing], 15)
        .onAppear(perform: reloadRoutines)
    }
}

// MARK: - Side Effects

private extension MyWorkoutView {
    func reloadRoutines() {
//        injected.interactors.routineInteractor
//            .load(myRoutines: $myRoutines)
    }
}
