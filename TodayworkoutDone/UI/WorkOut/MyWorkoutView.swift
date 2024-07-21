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
    @Environment(\.injected) private var injected: DIContainer
    
    @State private var routingState: Routing = .init()
    @State private(set) var myRoutines: Loadable<LazyList<MyRoutine>>
    @State private var selectedRoutine: MyRoutine?
    @Binding var workoutsList: Loadable<LazyList<Workouts>>
    
    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.myWorkoutView)
    }
    
    init(myRoutines: Loadable<LazyList<MyRoutine>> = .notRequested,
         workoutsList: Binding<Loadable<LazyList<Workouts>>> = .constant(.notRequested)) {
        self._myRoutines = .init(initialValue: myRoutines)
        self._workoutsList = .init(projectedValue: workoutsList)
    }
    
    var body: some View {
        self.content
            .onReceive(routingUpdate) { self.routingState = $0 }
    }
    
    @ViewBuilder private var content: some View {
        switch myRoutines {
        case .notRequested:
            notRequestedView
        case .isLoading(let last, _):
            loadingView(last)
        case .loaded(let routines):
            if routines.count > 0 {
                loadedView(routines)
            } else {
                EmptyView()
            }
        case .failed(let error):
            failedView(error)
        }
    }
}

// MARK: - Side Effects

private extension MyWorkoutView {
    func reloadRoutines() {
        injected.interactors.routineInteractor
            .load(myRoutines: $myRoutines)
    }
}

// MARK: - Loading Content

private extension MyWorkoutView {
    var notRequestedView: some View {
        Text("").onAppear(perform: reloadRoutines)
    }
    
    func loadingView(_ previouslyLoaded: LazyList<MyRoutine>?) -> some View {
        if let routines = previouslyLoaded {
            return AnyView(loadedView(routines))
        } else {
            return AnyView(ActivityIndicatorView().padding())
        }
    }
    
    func failedView(_ error: Error) -> some View {
        ErrorView(error: error, retryAction: {
            self.reloadRoutines()
        })
    }
}

// MARK: - Displaying Conent

private extension MyWorkoutView {
    func loadedView(_ myRoutines: LazyList<MyRoutine>) -> some View {
        VStack(alignment: .leading) {
            Text("my workout")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(myRoutines.lazyList) { myRoutine in
                        Button(action: {
                            injected.appState[\.routing.myWorkoutView.alertMyWorkout] = true
                            selectedRoutine = MyRoutine(name: myRoutine.name,
                                                        routines:  myRoutine.routines)
                        }) {
                            MyWorkoutSubview(myRoutine: myRoutine)
                        }
                    }
                    .alert("루틴을 시작하겠습니까?", isPresented: routingBinding.alertMyWorkout) {
                        Button("Cancel") { 
                            injected.appState[\.routing.myWorkoutView.alertMyWorkout] = false
                        }
                        Button("OK") {
                            injected.appState[\.routing.myWorkoutView.alertMyWorkout] = false
                            injected.appState[\.routing.homeView.workingOutView] = true
                            if let selectedRoutine = selectedRoutine {
                                injected.appState[\.userData.myRoutine] = selectedRoutine
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
                    .fullScreenCover(isPresented: routingBinding.makeWorkoutView,
                                     content: {
                        MakeWorkoutView(myRoutine: .constant(injected.appState[\.userData.myRoutine]),
                                        myRoutines: $myRoutines,
                                        workoutsList: $workoutsList,
                                        isEdit: true)
                    })
                }
            }
        }
        .padding([.leading, .trailing], 15)
    }
}

extension MyWorkoutView {
    struct Routing: Equatable {
        var makeWorkoutView: Bool = false
        var alertMyWorkout: Bool = false
    }
}

private extension MyWorkoutView {
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.myWorkoutView)
    }
}

//struct MyWorkoutView_Previews: PreviewProvider {
//    static var previews: some View {
//        MyWorkoutView()
//            .background(Color.gray)
//    }
//}
