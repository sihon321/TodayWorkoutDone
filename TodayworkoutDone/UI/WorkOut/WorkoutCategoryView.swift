//
//  WorkoutCategoryView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/25.
//

import SwiftUI
import Combine

struct WorkoutCategoryView: View {
    @Environment(\.injected) private var injected: DIContainer

    @State private var routingState: Routing = .init()
    @State private var selectionWorkouts: [Workouts] = []
    @State private var categories: Loadable<LazyList<Category>>
    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.workoutCategoryView)
    }
    
    var body: some View {
        self.content
            .onReceive(routingUpdate) { self.routingState = $0 }
    }
    
    @ViewBuilder private var content: some View {
        switch categories {
        case .notRequested:
            notRequestedView
        case .isLoading(let last, let cancelBag):
            loadingView(last)
        case .loaded(let t):
            <#code#>
        case .failed(let error):
            <#code#>
        }
    }
}

// MARK: - Side Effects

private extension WorkoutCategoryView {
    func reloadCategory() {
        injected.interactors.categoryInteractor
            .load(countries: $categories)
    }
}

// MARK: - Loading Content

private extension WorkoutCategoryView {
    var notRequestedView: some View {
        Text("")
    }
    
    func loadingView(_ previouslyLoaded: LazyList<Category>?) -> some View {
        if let countries = previouslyLoaded {
            return AnyView(loadedView(countries))
        } else {
            return AnyView(ActivityIndicatorView().padding())
        }
    }
    
    func failedView(_ error: Error) -> some View {
        ErrorView(error: error, retryAction: {
            self.reloadCategory()
        })
    }
}

// MARK: - Displaying Conent

private extension WorkoutCategoryView {
    func loadedView(_ categories: LazyList<Category>) -> some View {
        VStack(alignment: .leading)  {
            Text("category")
            List(categories) { category in
                NavigationLink {
                    WorkoutListView(category: category.kor ?? "",
                                    selectionWorkouts: $selectionWorkouts)
                    .inject(injected)
                } label: {
                    WorkoutCategorySubview(category: category.kor ?? "")
                }
            }
        }
        .padding([.leading, .trailing], 15)
        .toolbar {
            if !selectionWorkouts.isEmpty {
                Button(action: {
                    injected.appState[\.routing.workoutCategoryView.makeWorkoutView] = true
                }) {
                    Text("Done(\(selectionWorkouts.count))")
                }
                .fullScreenCover(isPresented: routingBinding.makeWorkoutView,
                                 content: {
                    MakeWorkoutView(selectionWorkouts: $selectionWorkouts)
                })
            }
        }
    }
}

extension WorkoutCategoryView {
    struct Routing: Equatable {
        var makeWorkoutView: Bool = false
        var workoutListView: Bool = false
    }
}

private extension WorkoutCategoryView {
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.workoutCategoryView)
    }
}

struct WorkoutCategoryView_Previews: PreviewProvider {
    @Environment(\.presentationMode) static var presentationmode
    static var previews: some View {
        WorkoutCategoryView()
    }
}
