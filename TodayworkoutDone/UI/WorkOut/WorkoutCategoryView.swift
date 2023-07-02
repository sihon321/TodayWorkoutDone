//
//  WorkoutCategoryView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/25.
//

import SwiftUI
import Combine

struct WorkoutCategoryView: View {
    @FetchRequest(sortDescriptors: []) var categories: FetchedResults<Category>
    @Environment(\.injected) private var injected: DIContainer
    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.workoutCategoryView)
    }
    @State private var routingState: Routing = .init()
    @State private var selectionList: [Int] = []
    @State private var selectionWorkouts: [Excercise] = []
    
    var body: some View {
        VStack(alignment: .leading)  {
            Text("category")
            ForEach(categories, id: \.self) { category in
                NavigationLink {
                    WorkoutListView(category: category.kor ?? "",
                                    selectionList: $selectionList,
                                    selectionWorkouts: $selectionWorkouts)
                    .inject(injected)
                } label: {
                    WorkoutCategorySubview(category: category.kor ?? "")
                }
            }
        }
        .padding([.leading, .trailing], 15)
        .toolbar {
            if !selectionList.isEmpty {
                Button(action: {
                    injected.appState[\.routing.workoutCategoryView.makeWorkoutView] = true
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
