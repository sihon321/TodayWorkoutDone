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
        var filteredReps: [Int] = []
        var filteredWeight: [Int] = []
        var filteredRestTimes: [Int] = []
        var filteredDurations: [Int] = []
        
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
                                let equipmentType = EquipmentType(rawValue: workout.equipment.first ?? "") ?? .none
                                state.myRoutine.routines.append(
                                    RoutineState(workout: workout,
                                                 equipmentType: equipmentType)
                                )
                                for index in 0..<addWorkoutCategory.workoutList.count {
                                    state.addWorkoutCategory?.workoutList[index].routines.append(
                                        RoutineState(workout: workout,
                                                     equipmentType: equipmentType)
                                    )
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
                            let categoryName = state.workingOutSection[sectionIndex].routine.workout.categoryName
                            let categoryType = WorkoutCategoryState.WorkoutCategoryType(rawValue: categoryName) ?? .strength
                            state.workingOutSection[sectionIndex]
                                .workingOutRow
                                .append(
                                    WorkingOutRowReducer.State(
                                        categoryType: categoryType,
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
                            case let .typeRep(rep):
                                if let sectionIndex = state.workingOutSection
                                    .index(id: sectionId),
                                   let rowIndex = state.workingOutSection[sectionIndex]
                                    .workingOutRow
                                    .index(id: rowId),
                                   let repValue = Int(rep) {
                                    state.myRoutine
                                        .routines[sectionIndex]
                                        .sets[rowIndex]
                                        .reps = repValue
                                    
                                    if rep.count == 1 {
                                        state.filteredReps = state.myRoutine
                                            .routines[sectionIndex]
                                            .sets
                                            .enumerated()
                                            .filter { $0.element.reps == 0 }
                                            .map { $0.offset }
                                    }
                                    let endIndex = state.workingOutSection[sectionIndex].workingOutRow.count
                                    for index in rowIndex..<endIndex {
                                        if state.filteredReps.contains(index) {
                                            state.myRoutine
                                                .routines[sectionIndex]
                                                .sets[index]
                                                .reps = repValue
                                            state.workingOutSection[sectionIndex]
                                                .workingOutRow[index]
                                                .repText = String(repValue)
                                        }
                                    }
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
                                    
                                    if weight.count == 1 {
                                        state.filteredWeight = state.myRoutine
                                            .routines[sectionIndex]
                                            .sets
                                            .enumerated()
                                            .filter { $0.element.weight == 0.0 }
                                            .map { $0.offset }
                                    }
                                    let endIndex = state.workingOutSection[sectionIndex].workingOutRow.count
                                    for index in rowIndex..<endIndex {
                                        if state.filteredWeight.contains(index) {
                                            state.myRoutine
                                                .routines[sectionIndex]
                                                .sets[index]
                                                .weight = weightValue
                                            state.workingOutSection[sectionIndex]
                                                .workingOutRow[index]
                                                .weightText = String(weightValue)
                                        }
                                    }
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
                                    
                                    if restTime.count == 1 {
                                        state.filteredRestTimes = state.myRoutine
                                            .routines[sectionIndex]
                                            .sets
                                            .enumerated()
                                            .filter { $0.element.restTime == 0 }
                                            .map { $0.offset }
                                    }
                                    let endIndex = state.workingOutSection[sectionIndex].workingOutRow.count
                                    for index in rowIndex..<endIndex {
                                        if state.filteredRestTimes.contains(index) {
                                            state.myRoutine
                                                .routines[sectionIndex]
                                                .sets[index]
                                                .restTime = restTime.timeStringToSeconds()
                                            state.workingOutSection[sectionIndex]
                                                .workingOutRow[index]
                                                .restTimeText = restTime.formattedTime()
                                        }
                                    }
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
                                    
                                    if duration.count == 1 {
                                        state.filteredDurations = state.myRoutine
                                            .routines[sectionIndex]
                                            .sets
                                            .enumerated()
                                            .filter { $0.element.duration == 0 }
                                            .map { $0.offset }
                                    }
                                    let endIndex = state.workingOutSection[sectionIndex].workingOutRow.count
                                    for index in rowIndex..<endIndex {
                                        if state.filteredDurations.contains(index) {
                                            state.myRoutine
                                                .routines[sectionIndex]
                                                .sets[index]
                                                .duration = duration.timeStringToSeconds()
                                            state.workingOutSection[sectionIndex]
                                                .workingOutRow[index]
                                                .durationText = duration.formattedTime()
                                        }
                                    }
                                }
                                return .none
                            case .setFocus:
                                state.filteredReps.removeAll()
                                state.filteredWeight.removeAll()
                                state.filteredRestTimes.removeAll()
                                state.filteredDurations.removeAll()
                                return .none
                            case .dismissKeyboard, .timerView, .presentStopWatch:
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
