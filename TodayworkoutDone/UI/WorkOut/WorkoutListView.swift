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

    @State private var routingState: Routing = .init()
    @State private var workoutsList: Loadable<LazyList<Workouts>>
    @State private var selectWorkouts: [Workouts]
    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.workoutListView)
    }
    
    var category: String
    
    init(workoutsList: Loadable<LazyList<Workouts>> = .notRequested,
         selectWorkouts: [Workouts],
         category: String) {
        self._workoutsList = .init(initialValue: workoutsList)
        self._selectWorkouts = .init(initialValue: selectWorkouts)
        self.category = category
    }
    
    var body: some View {
        self.content
            .navigationTitle(category)
            .onReceive(routingUpdate) { self.routingState = $0 }
            .onReceive(workoutsUpdate) { self.selectWorkouts = $0 }
    }
    
    @ViewBuilder private var content: some View {
        switch workoutsList {
        case .notRequested:
            notRequestedView
        case let .isLoading(last, _):
            loadingView(last)
        case let .loaded(workoutsList):
            loadedView(workoutsList)
        case let .failed(error):
            failedView(error)
        }
    }
}

// MARK: - Side Effects

private extension WorkoutListView {
    func reloadWorkouts() {
        injected.interactors.workoutInteractor
            .load(workouts: $workoutsList)
    }
}

// MARK: - Loading Content

private extension WorkoutListView {
    var notRequestedView: some View {
        Text("").onAppear(perform: reloadWorkouts)
    }
    
    func loadingView(_ previouslyLoaded: LazyList<Workouts>?) -> some View {
        if let workoutsList = previouslyLoaded {
            return AnyView(loadedView(workoutsList))
        } else {
            return AnyView(ActivityIndicatorView().padding())
        }
    }
    
    func failedView(_ error: Error) -> some View {
        ErrorView(error: error, retryAction: {
            self.reloadWorkouts()
        })
    }
}

// MARK: - Displaying Conent

private extension WorkoutListView {
    func loadedView(_ workoutsList: LazyList<Workouts>) -> some View {
        List(workoutsList) { workouts in
            WorkoutListSubview(workouts: workouts,
                               selectWorkouts: $selectWorkouts)
                .inject(injected)
        }
        .listStyle(.plain)
        .toolbar {
            if !selectWorkouts.isEmpty {
                Button(action: {
                    injected.appState[\.routing.workoutListView.makeWorkoutView] = true
                }) {
                    Text("Done(\(selectWorkouts.count))")
                }
                .fullScreenCover(isPresented: routingBinding.makeWorkoutView,
                                 content: {
                    MakeWorkoutView(
                        myRoutine: .constant(MyRoutine(
                            name: "",
                            routines: selectWorkouts.compactMap({ Routine(workouts: $0) }))
                        )
                    )
                })
            }
        }
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
        WorkoutListView(workoutsList: .loaded(Workouts.mockedData.lazyList),
                        selectWorkouts: [],
                        category: "")
            .inject(.preview)
    }
}
