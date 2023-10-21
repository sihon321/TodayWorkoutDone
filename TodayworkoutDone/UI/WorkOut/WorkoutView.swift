//
//  WorkoutCategoryView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/25.
//

import SwiftUI
import Combine

struct WorkoutView: View {
    @Environment(\.injected) private var injected: DIContainer
    @State private var workoutsList: Loadable<LazyList<Workouts>> = .notRequested
    @State private var routingState: Routing = .init()
    @State private var text: String = ""
    
    var body: some View {
        content
        .onReceive(routingUpdate) { self.routingState = $0 }
        .onAppear {
            injected.appState[\.userData.selectionWorkouts].removeAll()
        }
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

extension WorkoutView {
    func reloadWorkouts() {
        injected.interactors.workoutInteractor
            .load(workouts: $workoutsList)
    }
}

// MARK: - Loading Content

private extension WorkoutView {
    var notRequestedView: some View {
        Text("")
            .onAppear(perform: reloadWorkouts)
    }
    
    func loadingView(_ previouslyLoaded: LazyList<Workouts>?) -> some View {
        if let workouts = previouslyLoaded {
            return AnyView(loadedView(workouts))
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

private extension WorkoutView {
    func loadedView(_ workouts: LazyList<Workouts>) -> some View {
        NavigationView {
            ScrollView {
                VStack {
                    SearchBar(text: $text)
                        .padding(.top, 10)
                    MyWorkoutView(search: $text)
                        .padding(.top, 10)
                    WorkoutCategoryView(workoutsList: workoutsList,
                                        selectWorkouts: injected.appState[\.userData].selectionWorkouts,
                                        search: $text)
                        .inject(injected)
                        .padding(.top, 10)
                }
            }
            .background(Color(0xf4f4f4))
            .navigationBarTitle("workout", displayMode: .inline)
            .toolbar(content: {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        injected.appState[\.routing.excerciseStartView.workoutView] = false
                    }, label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    })
                }
            })
        }
    }
}

extension WorkoutView {
    struct Routing: Equatable {
        var workoutCategoryView: Bool = false
    }
}

private extension WorkoutView {
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.workoutView)
    }
}


struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutView()
            .background(Color.gray)
    }
}
