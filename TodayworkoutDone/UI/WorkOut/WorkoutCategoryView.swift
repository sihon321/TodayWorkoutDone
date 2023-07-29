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
    @State private var selectionWorkouts: LazyList<Workouts> = .empty
    @State private(set) var categories: Loadable<LazyList<Category>>
    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.workoutCategoryView)
    }
    
    init(categories: Loadable<LazyList<Category>> = .notRequested) {
        self._categories = .init(initialValue: categories)
    }
    
    var body: some View {
        self.content
            .onReceive(routingUpdate) { self.routingState = $0 }
    }
    
    @ViewBuilder private var content: some View {
        switch categories {
        case .notRequested:
            notRequestedView
        case let .isLoading(last, _):
            loadingView(last)
        case let .loaded(categories):
            loadedView(categories)
        case let .failed(error):
            failedView(error)
        }
    }
}

// MARK: - Side Effects

private extension WorkoutCategoryView {
    func reloadCategory() {
        injected.interactors.categoryInteractor
            .load(categories: $categories)
    }
}

// MARK: - Loading Content

private extension WorkoutCategoryView {
    var notRequestedView: some View {
        Text("").onAppear(perform: reloadCategory)
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
            ForEach(categories.array()) { category in
                NavigationLink {
                    WorkoutListView(selectWorkouts: injected.appState[\.userData.selectionWorkouts],
                                    category: category.kor ?? "")
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
        WorkoutCategoryView(categories: .loaded(Category.mockedData.lazyList))
            .inject(.preview)
    }
}
