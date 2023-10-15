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
    @State private var workoutsList:  Loadable<LazyList<Workouts>> = .notRequested
    @Binding var text: String
    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.workoutCategoryView)
    }
    
    init(categories: Loadable<LazyList<Category>> = .notRequested,
         selectWorkouts: [Workouts],
         search text: Binding<String>) {
        self._categories = .init(initialValue: categories)
        self._selectWorkouts = .init(initialValue: selectWorkouts)
        self._text = .init(projectedValue: text)
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
    
    func reloadWorkouts() {
        injected.interactors.workoutInteractor
            .load(workouts: $workoutsList)
    }
}

// MARK: - Loading Content

private extension WorkoutCategoryView {
    var notRequestedView: some View {
        Text("")
            .onAppear(perform: reloadCategory)
            .onAppear(perform: reloadWorkouts)
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
            self.reloadWorkouts()
        })
    }
}

// MARK: - Displaying Conent

private extension WorkoutCategoryView {
    func loadedView(_ categories: LazyList<Category>) -> some View {
        VStack(alignment: .leading)  {
            Text("category")
            let filteredCategory = workoutsList.value?.array()
                .filter({ $0.name.hasPrefix(text) })
                .compactMap({ $0.category })
                .uniqued() ?? []
            let categories = categories.array().filter {
                if filteredCategory.isEmpty {
                    return true
                } else if filteredCategory.contains($0.kor) || filteredCategory.contains($0.en) {
                    return true
                } else {
                    return false
                }
            }
            ForEach(categories) { category in
                NavigationLink {
                    WorkoutListView(workoutsList: workoutsList,
                                    selectWorkouts: selectWorkouts,
                                    category: category)
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
                        myRoutine: .constant(MyRoutine(name: "", routines: selectWorkouts.compactMap({ Routine(workouts: $0) })))
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
                            selectWorkouts: [],
                            search: .constant(""))
            .inject(.preview)
    }
}
