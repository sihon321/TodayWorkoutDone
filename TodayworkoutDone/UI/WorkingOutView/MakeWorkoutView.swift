//
//  MakeWorkoutView.swift
//  TodayworkoutDone
//
//  Created by ocean on 2023/05/17.
//

import SwiftUI
import ComposableArchitecture
import Dependencies
import SwiftData

@Reducer
struct MakeWorkoutReducer {
    @ObservableState
    struct State: Equatable {
        @Presents var addWorkoutCategory: AddWorkoutCategoryReducer.State?
        var myRoutine: MyRoutineState
        var isEdit: Bool = false
        var isFocused: Bool = false
        var workingOutSection: IdentifiedArrayOf<WorkingOutSectionReducer.State>
        
        init(myRoutine: MyRoutineState,
             isEdit: Bool) {
            self.myRoutine = myRoutine
            self.isEdit = isEdit
            workingOutSection = IdentifiedArrayOf(
                uniqueElements: myRoutine.routines.map {
                    WorkingOutSectionReducer.State(
                        routine: $0,
                        editMode: .active
                    )
                }
            )
        }
    }
    
    enum Action {
        case dismissMakeWorkout
        case tappedDone(MyRoutineState)
        case save(MyRoutineState)
        case didUpdateText(String)
        case setFocus(Bool)
        case dismissKeyboard
        case tappedAdd
        
        case workingOutSection(IdentifiedActionOf<WorkingOutSectionReducer>)
        case addWorkoutCategory(PresentationAction<AddWorkoutCategoryReducer.Action>)
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .dismissMakeWorkout:
                return .run { send in
                    await send(.dismissKeyboard)
                    await self.dismiss()
                }
            case .tappedDone(let myRoutine):
                state.myRoutine = myRoutine
                state.myRoutine.isRunning = true

                return .send(.dismissMakeWorkout)
            case .save(let myRoutine):
                @Dependency(\.myRoutineData.fetch) var fetch
                @Dependency(\.myRoutineData.save) var save
                
                if let id = myRoutine.persistentModelID {
                    let descriptor = FetchDescriptor<MyRoutine>(
                        predicate: #Predicate { $0.persistentModelID == id }
                    )
                    do {
                        if let updateToMyRoutine = try fetch(descriptor).first {
                            updateToMyRoutine.update(from: myRoutine)
                            try save()
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                } else {
                    @Dependency(\.myRoutineData) var myRoutineContext
                    do {
                        try myRoutineContext.add(myRoutine.toModel())
                        try myRoutineContext.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                
                return .send(.dismissMakeWorkout)
                
            case .didUpdateText(let text):
                state.myRoutine.name = text
                return .none
            case let .setFocus(focus):
                state.isFocused = focus
                return .none

            case .dismissKeyboard:
                state.isFocused = false
                return .none
            case .tappedAdd:
                state.addWorkoutCategory = AddWorkoutCategoryReducer.State(
                    routines: state.myRoutine.routines
                )
                return .none
            case let .addWorkoutCategory(.presented(.workoutList(.element(_, .dismiss(routines))))):
                state.myRoutine.routines = routines
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
                                state.myRoutine.routines.append(RoutineState(workout: workout))
                                for index in 0..<addWorkoutCategory.workoutList.count {
                                    state.addWorkoutCategory?.workoutList[index].routines.append(RoutineState(workout: workout))
                                }
                            } else {
                                state.myRoutine.routines.removeAll { $0.workout.name == workout.name }
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

            case let .workingOutSection(action):
                switch action {
                case let .element(sectionId, action):
                    switch action {
                    case .tappedAddFooter:
                        @Dependency(\.routineData.fetch) var fetch

                        if let sectionIndex = state.workingOutSection
                            .index(id: sectionId) {
                            let index = state.workingOutSection[sectionIndex]
                                .workingOutRow.count
                            let name = state.myRoutine.routines[sectionIndex].workout.name
                            var descriptor = FetchDescriptor<Routine>(
                                predicate: #Predicate {
                                    $0.workout.name == name
                                },
                                sortBy: [SortDescriptor(\.endDate, order: .reverse)]
                            )
                            descriptor.fetchLimit = 1
                            var workoutSet = WorkoutSetState(order: index + 1)
                            do {
                                if let prevRoutine = try fetch(descriptor).first,
                                   let prevWeight = prevRoutine.sets.first(where: { $0.order == index + 1 })?.weight,
                                   let prevReps = prevRoutine.sets.first(where: { $0.order == index + 1 })?.reps,
                                   let prevDuration = prevRoutine.sets.first(where: { $0.order == index + 1 })?.duration {
                                    workoutSet.prevWeight = prevWeight
                                    workoutSet.prevReps = prevReps
                                    workoutSet.duration = prevDuration
                                }
                            } catch {
                                print(error.localizedDescription)
                            }
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
                            state.myRoutine
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
                            case let .typeRep(lab):
                            if let sectionIndex = state.workingOutSection
                                    .index(id: sectionId),
                                   let rowIndex = state.workingOutSection[sectionIndex]
                                    .workingOutRow
                                    .index(id: rowId),
                                   let labValue = Int(lab) {
                                    state.myRoutine
                                        .routines[sectionIndex]
                                        .sets[rowIndex]
                                        .reps = labValue
                                }
                                return .none
                            case let .typeWeight(weight):
                                if let sectionIndex = state.workingOutSection
                                    .index(id: sectionId),
                                   let rowIndex = state.workingOutSection[sectionIndex]
                                    .workingOutRow
                                    .index(id: rowId),
                                   let weightValue = Double(weight) {
                                    state.myRoutine
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
                                    state.myRoutine
                                        .routines[sectionIndex]
                                        .sets[rowIndex]
                                        .restTime = restTime.timeStringToSeconds()
                                }
                                return .none
                            case .typeDuration(let duration):
                                if let sectionIndex = state.workingOutSection.index(id: sectionId),
                                   let rowIndex = state.workingOutSection[sectionIndex]
                                    .workingOutRow
                                    .index(id: rowId) {
                                    state.myRoutine
                                        .routines[sectionIndex]
                                        .sets[rowIndex]
                                        .duration = duration.timeStringToSeconds()
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
                                state.myRoutine.routines.remove(at: sectionIndex)
                            }
                            return .none
                        case let .tappedWorkoutsType(type):
                            if let sectionIndex = state.workingOutSection
                                .index(id: sectionId) {
                                state.myRoutine
                                    .routines[sectionIndex].equipmentType = type
                            }
                            return .none
                        }
                    case .setEditMode:
                        return .none
                    case let .deleteWorkoutSet(indexSet):
                        if let sectionIndex = state.workingOutSection.index(id: sectionId) {
                            state.myRoutine.routines[sectionIndex]
                                .sets.remove(atOffsets: indexSet)
                        }
                        return .none
                    }
                }
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

struct MakeWorkoutView: View {
    @Bindable var store: StoreOf<MakeWorkoutReducer>
    @ObservedObject var viewStore: ViewStoreOf<MakeWorkoutReducer>
    @FocusState private var isTextFieldFocused: Bool

    init(store: StoreOf<MakeWorkoutReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    TextField("타이틀을 입력하세요",
                              text: viewStore.binding(
                                get: \.myRoutine.name,
                                send: MakeWorkoutReducer.Action.didUpdateText
                              ))
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 25, weight: .bold))
                    .accessibilityAddTraits(.isHeader)
                    .padding([.leading], 15)
                    .focused($isTextFieldFocused)
                    
                    ForEach(
                        store.scope(state: \.workingOutSection,
                                    action: \.workingOutSection)
                    ) { rowStore in
                        WorkingOutSection(store: rowStore)
                    }
                    .padding(.bottom, 30)
                    
                    Button("워크아웃 추가") {
                        viewStore.send(.tappedAdd)
                    }
                    .buttonStyle(AddWorkoutButtonStyle())
                    .fullScreenCover(
                        item: $store.scope(state: \.addWorkoutCategory, action: \.addWorkoutCategory)
                    ) { store in
                        AddWorkoutCategoryView(store: store)
                    }
                    Spacer().frame(height: 100)
                }
                .background(Color.background)
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
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
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
                        viewStore.send(.dismissMakeWorkout)
                    }) {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if store.isEdit {
                        Button("Save") {
                            viewStore.send(.save(viewStore.myRoutine))
                        }
                    } else {
                        Button("Done") {
                            viewStore.send(.tappedDone(viewStore.myRoutine))
                        }
                    }
                }
            }
            .background(Color.background)
        }
        .onChange(of: isTextFieldFocused) { _, newValue in
            viewStore.send(.setFocus(newValue))
        }
        .onChange(of: viewStore.isFocused) { _, newValue in
            isTextFieldFocused = newValue
        }
    }
    
}
