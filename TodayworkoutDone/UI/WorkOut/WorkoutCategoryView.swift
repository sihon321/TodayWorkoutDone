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
    @Binding var workoutsList: Loadable<LazyList<Workouts>>
    @Binding var text: String
    @Binding var myRoutine: MyRoutine
    private var isMyWorkoutView: Bool = false
    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.workoutCategoryView)
    }
    
    init(categories: Loadable<LazyList<Category>> = .notRequested,
         workoutsList: Loadable<LazyList<Workouts>>,
         selectWorkouts: [Workouts] = [],
         search text: Binding<String> = .init(projectedValue: .constant("")),
         isMyWorkoutView: Bool = false,
         myRoutine: Binding<MyRoutine> = .init(projectedValue: .constant(MyRoutine(name: "", routines: [])))) {
        self._categories = .init(initialValue: categories)
        self._workoutsList = .init(projectedValue: .constant(workoutsList))
        self._selectWorkouts = .init(initialValue: selectWorkouts)
        self._text = .init(projectedValue: text)
        self.isMyWorkoutView = isMyWorkoutView
        self._myRoutine = myRoutine
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
        Text("")
            .onAppear(perform: reloadCategory)
    }
    
    func loadingView(_ previouslyLoaded: LazyList<Category>?) -> some View {
        if let categories = previouslyLoaded {
            return AnyView(loadedView(categories))
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
                                    category: category,
                                    isMyWorkoutView: isMyWorkoutView,
                                    myRoutine: $myRoutine)
                    .inject(injected)
                } label: {
                    WorkoutCategorySubview(category: category.kor)
                }
            }
        }
        .padding([.leading, .trailing], 15)
        .toolbar {
            if !selectWorkouts.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        if !isMyWorkoutView {
                            injected.appState[\.routing.workoutCategoryView.makeWorkoutView] = true
                        } else {
                            myRoutine.routines += selectWorkouts.compactMap({ Routine(workouts: $0) })
                            injected.appState[\.userData.selectionWorkouts].removeAll()
                            injected.appState[\.routing.makeWorkoutView.workoutCategoryView] = false
                        }
                    }) {
                        Text("Done(\(selectWorkouts.count))")
                    }
                    .fullScreenCover(isPresented: routingBinding.makeWorkoutView,
                                     content: {
                        if !isMyWorkoutView {
                            MakeWorkoutView(
                                myRoutine: .constant(MyRoutine(name: "",
                                                               routines: selectWorkouts.compactMap({ Routine(workouts: $0) })))
                            )
                        }
                    })
                }
            }
            if isMyWorkoutView {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        injected.appState[\.routing.makeWorkoutView.workoutCategoryView] = false
                    }, label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    })
                }
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
                            workoutsList: .loaded(Workouts.mockedData.lazyList),
                            selectWorkouts: [],
                            search: .constant(""))
            .inject(.preview)
    }
}
