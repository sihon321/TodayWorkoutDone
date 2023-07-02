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
    @FetchRequest(sortDescriptors: []) var workoutsList: FetchedResults<Workouts>
    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.workoutListView)
    }
    @State private var routingState: Routing = .init()
    
    var category: String
    @Binding var selectionList: [Int]
    @Binding var selectionWorkouts: [Excercise]
    
    var body: some View {
        List(Array(zip(workoutsList.indices, workoutsList)), id: \.0) { index, workouts in
            WorkoutListSubview(workouts: workouts,
                               index: index,
                               selectionList: $selectionList,
                               selectionWorkouts: $selectionWorkouts)
        }
        .listStyle(.plain)
        .navigationTitle(category)
        .toolbar {
            if !selectionList.isEmpty {
                Button(action: {
                    injected.appState[\.routing.workoutListView.makeWorkoutView] = true
                }) {
                    Text("Done(\(selectionList.count))")
                }
                .fullScreenCover(isPresented: routingBinding.makeWorkoutView,
                                 content: {
                    MakeWorkoutView(selectionWorkouts: $selectionWorkouts)
                })
            }
        }
        .onReceive(routingUpdate) { self.routingState = $0 }
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
}

struct WorkoutListView_Previews: PreviewProvider {
    @Environment(\.presentationMode) static var presentationmode
    static var previews: some View {
        WorkoutListView(category: "category",
                        selectionList: .constant([]),
                        selectionWorkouts: .constant([]))
    }
}
