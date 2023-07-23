//
//  WorkoutListView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/27.
//

import SwiftUI
import Combine

struct WorkoutListView: View {
    @Environment(\.injected) private var injected: DIContainer
//    @FetchRequest(sortDescriptors: []) var workoutsList: FetchedResults<Workouts>

    @State private var routingState: Routing = .init()
    
    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.workoutListView)
    }
    
    var category: String
    @Binding var selectionWorkouts: [Workouts]
    
    var body: some View {
        List(workoutsList) { workouts in
            WorkoutListSubview(workouts: .constant(workouts))
                .inject(injected)
        }
        .listStyle(.plain)
        .navigationTitle(category)
        .toolbar {
            if !selectionWorkouts.isEmpty {
                Button(action: {
                    injected.appState[\.routing.workoutListView.makeWorkoutView] = true
                }) {
                    Text("Done(\(selectionWorkouts.count))")
                }
                .fullScreenCover(isPresented: routingBinding.makeWorkoutView,
                                 content: {
                    MakeWorkoutView(selectionWorkouts: $selectionWorkouts)
                })
            }
        }
        .onReceive(routingUpdate) { self.routingState = $0 }
        .onReceive(workoutsUpdate) { self.selectionWorkouts = $0 }
    }
}

extension WorkoutListView {
    struct Routing: Equatable {
        var makeWorkoutView: Bool = false
    }
}

private extension WorkoutListView {
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.workoutListView)
    }
    
    var workoutsUpdate: AnyPublisher<[Workouts], Never> {
        injected.appState.updates(for: \.userData.selectionWorkouts)
    }
}

struct WorkoutListView_Previews: PreviewProvider {
    @Environment(\.presentationMode) static var presentationmode
    static var previews: some View {
        WorkoutListView(category: "category",
                        selectionWorkouts: .constant([]))
    }
}
