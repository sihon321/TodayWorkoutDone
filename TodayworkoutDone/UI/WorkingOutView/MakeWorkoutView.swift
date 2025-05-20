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
        @Presents var destination: Destination.State?

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
        case destination(PresentationAction<Destination.Action>)
        case workingOutSection(IdentifiedActionOf<WorkingOutSectionReducer>)
    }
    
    @Reducer(state: .equatable)
    enum Destination {
        case addWorkoutCategory(AddWorkoutCategoryReducer)
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .dismissMakeWorkout:
                state.destination = .none
                return .run { _ in
                    await self.dismiss()
                }
            case .tappedDone(let myRoutine):
                state.myRoutine = myRoutine
                state.myRoutine.isRunning = true

                return .run { send in
                    await send(.dismissMakeWorkout)
                }
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
                state.destination = .addWorkoutCategory(
                    AddWorkoutCategoryReducer.State(
                        routines: state.myRoutine.routines
                    )
                )
                return .none
            case let .destination(.presented(.addWorkoutCategory(.workoutList(.element(_, .dismiss(routines)))))):
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
            case .destination:
                return .none

            case let .workingOutSection(action):
                switch action {
                case let .element(sectionId, action):
                    switch action {
                    case .tappedAddFooter:
                        if let sectionIndex = state.workingOutSection
                            .index(id: sectionId) {
                            let workoutSet = WorkoutSetState()
                            let index = state.workingOutSection[sectionIndex]
                                .workingOutRow.count
                            state.workingOutSection[sectionIndex]
                                .workingOutRow
                                .append(
                                    WorkingOutRowReducer.State(
                                        index: index + 1,
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
                            case .setFocus, .dismissKeyboard:
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
        .ifLet(\.$destination, action: \.destination) {
            Destination.body
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
                        item: $store.scope(state: \.destination?.addWorkoutCategory,
                                           action: \.destination.addWorkoutCategory)
                    ) { store in
                        AddWorkoutCategoryView(store: store)
                    }
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
                            .foregroundColor(.black)
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
        }
        .tint(.black)
        .onChange(of: isTextFieldFocused) { _, newValue in
            viewStore.send(.setFocus(newValue))
        }
        .onChange(of: viewStore.isFocused) { _, newValue in
            isTextFieldFocused = newValue
        }
    }
    
}
