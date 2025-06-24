//
//  EditWorkoutRoutineView.swift
//  TodayworkoutDone
//
//  Created by ocean on 4/22/25.
//

import SwiftUI
import ComposableArchitecture
import Foundation
import SwiftData

@Reducer
struct EditWorkoutRoutineReducer {
    @ObservableState
    struct State: Equatable {
        @Presents var addWorkoutCategory: AddWorkoutCategoryReducer.State?
        
        var workoutRoutine: WorkoutRoutineState
        var workingOutSection: IdentifiedArrayOf<WorkingOutSectionReducer.State>
        var isFocused: Bool = false
        
        init(workoutRoutine: WorkoutRoutineState) {
            self.workoutRoutine = workoutRoutine
            self.workingOutSection = IdentifiedArrayOf(
                uniqueElements: workoutRoutine.routines.map {
                    WorkingOutSectionReducer.State(
                        routine: $0,
                        editMode: .active
                    )
                }
            )
        }
    }
    
    enum Action {
        case tappedAdd
        case didUpdateText(String)
        case save(WorkoutRoutineState)
        case dismiss
        case editStartDate(Date)
        case editEndDate(Date)
        case setFocus(Bool)
        case dismissKeyboard
        
        case workingOutSection(IdentifiedActionOf<WorkingOutSectionReducer>)
        case addWorkoutCategory(PresentationAction<AddWorkoutCategoryReducer.Action>)
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .tappedAdd:
                state.addWorkoutCategory = AddWorkoutCategoryReducer.State(
                    routines: state.workoutRoutine.routines
                )
                return .none
            case .didUpdateText(let text):
                state.workoutRoutine.name = text
                return .none
            case .save(let workoutRoutine):
                @Dependency(\.workoutRoutineData.fetch) var fetch
                @Dependency(\.workoutRoutineData.save) var save
                
                if let id = workoutRoutine.persistentModelID {
                    let descriptor = FetchDescriptor<WorkoutRoutine>(
                        predicate: #Predicate { $0.persistentModelID == id }
                    )
                    do {
                        if let updateToWorkoutRoutine = try fetch(descriptor).first {
                            updateToWorkoutRoutine.update(from: workoutRoutine)
                            try save()
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                return .send(.dismiss)
            case .dismiss:
                return .run { _ in
                    await self.dismiss()
                }
            case .editStartDate(let date):
                state.workoutRoutine.startDate = date
                let endDate = state.workoutRoutine.endDate
                let difference = endDate.timeIntervalSince(date)
                state.workoutRoutine.routineTime = Int(difference)
                return .none
            case .editEndDate(let date):
                state.workoutRoutine.endDate = date
                let startDate = state.workoutRoutine.startDate
                let difference = date.timeIntervalSince(startDate)
                state.workoutRoutine.routineTime = Int(difference)
                return .none
                
            case let .setFocus(focus):
                state.isFocused = focus
                return .none
            case .dismissKeyboard:
                state.isFocused = false
                return .none
                
            case let .workingOutSection(action):
                switch action {
                case let .element(sectionId, action):
                    switch action {
                    case .tappedAddFooter:
                        if let sectionIndex = state.workingOutSection
                            .index(id: sectionId) {
                            let index = state.workingOutSection[sectionIndex]
                                .workingOutRow.count
                            let workoutSet = WorkoutSetState(order: index + 1)
                            let category = state.workingOutSection[sectionIndex].routine.workout.category
                            state.workingOutSection[sectionIndex]
                                .workingOutRow
                                .append(
                                    WorkingOutRowReducer.State(
                                        category: category,
                                        workoutSet: workoutSet,
                                        editMode: .active
                                    )
                                )
                            state.workoutRoutine
                                .routines[sectionIndex]
                                .sets
                                .append(workoutSet)
                        }
                        return .none
                    case let .workingOutRow(action):
                        switch action {
                        case let .element(rowId, action):
                            switch action {
                            case .toggleCheck:
                                return .none
                            case let .typeRep(rep):
                                if let sectionIndex = state.workingOutSection
                                    .index(id: sectionId),
                                   let rowIndex = state.workingOutSection[sectionIndex]
                                    .workingOutRow
                                    .index(id: rowId),
                                   let repValue = Int(rep) {
                                    state.workoutRoutine
                                        .routines[sectionIndex]
                                        .sets[rowIndex]
                                        .reps = repValue
                                }
                                return .none
                            case let .typeWeight(weight):
                                if let sectionIndex = state.workingOutSection
                                    .index(id: sectionId),
                                   let rowIndex = state.workingOutSection[sectionIndex]
                                    .workingOutRow
                                    .index(id: rowId),
                                   let weightValue = Double(weight) {
                                    state.workoutRoutine
                                        .routines[sectionIndex]
                                        .sets[rowIndex]
                                        .weight = weightValue
                                }
                                return .none
                            case .typeRestTime(let restTime):
                                if let sectionIndex = state.workingOutSection.index(id: sectionId),
                                   let rowIndex = state.workingOutSection[sectionIndex]
                                    .workingOutRow
                                    .index(id: rowId) {
                                    state.workoutRoutine
                                        .routines[sectionIndex]
                                        .sets[rowIndex]
                                        .restTime = restTime.timeStringToSeconds()
                                }
                                return .none
                            case .setFocus, .dismissKeyboard, .timerView, .presentStopWatch:
                                return .none
                            case .stopwatch:
                                return .none
                            }
                        }
                    case let .workingOutHeader(action):
                        switch action {
                        case .deleteWorkout:
                            if let sectionIndex = state.workingOutSection
                                .index(id: sectionId) {
                                state.workingOutSection.remove(at: sectionIndex)
                                state.workoutRoutine.routines.remove(at: sectionIndex)
                            }
                            return .none
                        case let .tappedWorkoutsType(type):
                            if let sectionIndex = state.workingOutSection
                                .index(id: sectionId) {
                                state.workoutRoutine
                                    .routines[sectionIndex].equipmentType = type
                            }
                            return .none
                        }
                    case .setEditMode:
                        return .none
                    case let .deleteWorkoutSet(indexSet):
                        if let sectionIndex = state.workingOutSection.index(id: sectionId) {
                            state.workoutRoutine.routines[sectionIndex]
                                .sets.remove(atOffsets: indexSet)
                        }
                        return .none
                    }
                }
            case let .addWorkoutCategory(.presented(.workoutList(.element(_, .dismiss(routines))))):
                state.workoutRoutine.routines = routines
                state.workingOutSection = IdentifiedArrayOf(
                    uniqueElements: routines.map {
                        WorkingOutSectionReducer.State(
                            routine: $0,
                            editMode: .active
                        )
                    }
                )
                return .none
            case let .addWorkoutCategory(.presented(.workoutList(.element(categoryId, action: .sortedWorkoutSection(.element(sectionId, action: .workoutListSubview(.element(rowId, action: .didTapped)))))))):

                if let categoryIndex = state.addWorkoutCategory?
                    .workoutList
                    .firstIndex(where: { $0.id == categoryId }) {
                    if let addWorkoutCategory = state.addWorkoutCategory,
                        let sectionIndex = addWorkoutCategory
                        .workoutList[categoryIndex]
                        .soretedWorkoutSection
                        .firstIndex(where: { $0.id == sectionId }) {
                        if let rowIndex = addWorkoutCategory
                            .workoutList[categoryIndex]
                            .soretedWorkoutSection[sectionIndex]
                            .workoutListSubview
                            .firstIndex(where: { $0.id == rowId }) {
                            let workout = addWorkoutCategory.workoutList[categoryIndex]
                                .soretedWorkoutSection[sectionIndex]
                                .workoutListSubview[rowIndex]
                                .workout
                            if workout.isSelected {
                                state.workoutRoutine.routines.append(RoutineState(workout: workout))
                                for index in 0..<addWorkoutCategory.workoutList.count {
                                    state.addWorkoutCategory?.workoutList[index].routines.append(RoutineState(workout: workout))
                                }
                            } else {
                                state.workoutRoutine.routines.removeAll { $0.workout.name == workout.name }
                                for index in 0..<addWorkoutCategory.workoutList.count {
                                    state.addWorkoutCategory?.workoutList[index].routines.removeAll { $0.workout.name == workout.name }
                                }
                            }
                        }
                    }
                }
                return .none
            case .addWorkoutCategory:
                return .none
            }
        }
        .forEach(\.workingOutSection, action: \.workingOutSection) {
            WorkingOutSectionReducer()
        }
        .ifLet(\.$addWorkoutCategory, action: \.addWorkoutCategory) {
            AddWorkoutCategoryReducer()
        }
    }
}

struct EditWorkoutRoutineView: View {
    @Bindable var store: StoreOf<EditWorkoutRoutineReducer>
    @ObservedObject var viewStore: ViewStoreOf<EditWorkoutRoutineReducer>
    @FocusState private var isTextFieldFocused: Bool
    
    init(store: StoreOf<EditWorkoutRoutineReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    TextField("타이틀을 입력하세요",
                              text: viewStore.binding(
                                get: \.workoutRoutine.name,
                                send: EditWorkoutRoutineReducer.Action.didUpdateText
                              ))
                    .multilineTextAlignment(.leading)
                    .font(.title)
                    .accessibilityAddTraits(.isHeader)
                    .padding(.horizontal, 15)
                    
                    Spacer()
                    DatePicker("시작시간",
                               selection: viewStore.binding(get: \.workoutRoutine.startDate,
                                                            send: EditWorkoutRoutineReducer.Action.editStartDate),
                               displayedComponents: [.date, .hourAndMinute])
                    .padding(.horizontal, 15)
                    DatePicker("종료시간",
                               selection: viewStore.binding(get: \.workoutRoutine.endDate,
                                                            send: EditWorkoutRoutineReducer.Action.editEndDate),
                               displayedComponents: [.date, .hourAndMinute])
                    .padding(.horizontal, 15)
                    Spacer()
                    
                    ForEach(store.scope(state: \.workingOutSection,
                                        action: \.workingOutSection)) { rowStore in
                        WorkingOutSection(store: rowStore)
                    }
                    .padding([.bottom], 30)
                    
                    Button("워크아웃 추가") {
                        viewStore.send(.tappedAdd)
                    }
                    .buttonStyle(AddWorkoutButtonStyle())
                    Spacer().frame(height: 100)
                }
                .onTapGesture {
                    viewStore.send(.dismissKeyboard)
                    viewStore.workingOutSection.elements.forEach { section in
                        section.workingOutRow.elements.forEach { row in
                            viewStore.send(
                                .workingOutSection(
                                    .element(id: section.id,
                                             action: .workingOutRow(
                                                .element(id: row.id,
                                                         action: .dismissKeyboard))
                                            )
                                )
                            )
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        viewStore.send(.dismiss)
                    }, label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    })
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewStore.send(.save(viewStore.workoutRoutine))
                    }
                }
            }
            .fullScreenCover(
                item:  $store.scope(state: \.addWorkoutCategory,
                                    action: \.addWorkoutCategory)
            ) { store in
                AddWorkoutCategoryView(store: store)
            }
            .tint(.black)
        }
    }
    
}
