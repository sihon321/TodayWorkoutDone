//
//  MyWorkoutView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/25.
//

import SwiftUI
import Combine

struct MyWorkoutView: View {
    @Environment(\.injected) private var injected: DIContainer
    
    @State private var routingState: Routing = .init()
    @State private(set) var myRoutines: Loadable<LazyList<MyRoutine>>
    @State private var selectedRoutine: MyRoutine?
    @Binding var text: String
    
    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.myWorkoutView)
    }
    
    init(myRoutines: Loadable<LazyList<MyRoutine>> = .notRequested,
         search text: Binding<String>) {
        self._myRoutines = .init(initialValue: myRoutines)
        self._text = .init(projectedValue: text)
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
                    ForEach(myRoutines.array()) { myRoutine in
                        Button(action: {
                            injected.appState[\.routing.myWorkoutView.makeWorkoutView] = true
                            selectedRoutine = myRoutine
                        }) {
                            MyWorkoutSubview(myRoutine: myRoutine)
                        }
                    }
                    .fullScreenCover(isPresented: routingBinding.makeWorkoutView,
                                     content: {
                        if let selectedRoutine = selectedRoutine {
                            MakeWorkoutView(myRoutine: .constant(selectedRoutine))
                        }
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
    }
}

private extension MyWorkoutView {
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.myWorkoutView)
    }
}

struct MyWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        MyWorkoutView(search: .constant(""))
            .background(Color.gray)
    }
}
