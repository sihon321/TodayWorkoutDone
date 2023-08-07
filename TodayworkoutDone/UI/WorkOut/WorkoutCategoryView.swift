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
    @State private var selectWorkouts: [Workouts]
    @State private(set) var categories: Loadable<LazyList<Category>>
    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.workoutCategoryView)
    }
    
    init(categories: Loadable<LazyList<Category>> = .notRequested,
         selectWorkouts: [Workouts]) {
        self._categories = .init(initialValue: categories)
        self._selectWorkouts = .init(initialValue: selectWorkouts)
    }
    
    var body: some View {
        self.content
            .onReceive(routingUpdate) { self.routingState = $0 }
            .onReceive(workoutsUpdate) { self.selectWorkouts = $0 }
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
                    WorkoutListView(selectWorkouts: selectWorkouts,
                                    category: category.kor)
                        .inject(injected)
                } label: {
                    WorkoutCategorySubview(category: category.kor)
                }
            }
        }
        .padding([.leading, .trailing], 15)
        .toolbar {
            if !selectWorkouts.isEmpty {
                Button(action: {
                    injected.appState[\.routing.workoutCategoryView.makeWorkoutView] = true
                }) {
                    Text("Done(\(selectWorkouts.count))")
                }
                .fullScreenCover(isPresented: routingBinding.makeWorkoutView,
                                 content: {
                    MakeWorkoutView(
                        routines: .constant(selectWorkouts.compactMap({ Routine(workouts: $0) }))
                    )
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
    
    var workoutsUpdate: AnyPublisher<[Workouts], Never> {
        injected.appState.updates(for: \.userData.selectionWorkouts)
    }
}

struct WorkoutCategoryView_Previews: PreviewProvider {
    @Environment(\.presentationMode) static var presentationmode
    static var previews: some View {
        WorkoutCategoryView(categories: .loaded(Category.mockedData.lazyList),
                            selectWorkouts: [])
            .inject(.preview)
    }
}
