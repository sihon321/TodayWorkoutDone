//
//  WorkingOutView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/28.
//

import SwiftUI
import Combine

struct WorkingOutView: View {
    @Environment(\.injected) private var injected: DIContainer
    @State private var editMode: EditMode = .inactive
    @State private var isSavedWorkout: Bool = false
    @Binding var isCloseWorking: Bool
    @Binding var hideTabValue: CGFloat
    @Binding var isSavedAlert: Bool
    
    @State var secondsElapsed = 0
    @State var timer: Timer.TimerPublisher = Timer.publish(every: 1, on: .main, in: .common)
    @State var connectedTimer: Cancellable? = nil
    
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
                        editMode: $editMode, isAppendSets: .constant(false)
                    )
                }
                Spacer().frame(height: 100)
            }
            .onAppear {
                self.instantiateTimer()
            }.onDisappear {
                self.cancelTimer()
            }.onReceive(timer) { _ in
                self.secondsElapsed += 1
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        isSavedWorkout.toggle()
                        cancelTimer()
                    }
                }
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(secondsElapsed.secondToHMS)
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
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .alert("워크아웃을 저장하겠습니까?", isPresented: $isSavedWorkout) {
            Button("Close") {
                injected.appState[\.routing.homeView.workingOutView] = false
                isCloseWorking = true
                hideTabValue = 0.0
            }
            Button("Cancel") {
                restartTimer()
            }
            Button("OK") {
                injected.appState[\.routing.homeView.workingOutView] = false
                isCloseWorking = true
                hideTabValue = 0.0
                if !injected.interactors.routineInteractor.find(myRoutine: myRoutine) {
                    isSavedAlert = true
                }
                saveWorkoutRoutine(secondsElapsed)
            }
        } message: {
            Text("새로운 워크아웃을 저장하시겟습니까")
        }
    }
    
    func instantiateTimer() {
        self.timer = Timer.publish(every: 1, on: .main, in: .common)
        self.connectedTimer = self.timer.connect()
        return
    }
    
    func cancelTimer() {
        self.connectedTimer?.cancel()
        return
    }
    
    func resetCounter() {
        self.secondsElapsed = 0
        return
    }
    
    func restartTimer() {
        self.cancelTimer()
        self.instantiateTimer()
        return
    }
}

private extension WorkingOutView {
    func saveWorkoutRoutine(_ routineTime: Int) {
        injected.interactors.routineInteractor.store(
            workoutRoutine: WorkoutRoutine(date: Date(),
                                           routineTime: routineTime,
                                           myRoutine: myRoutine)
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
