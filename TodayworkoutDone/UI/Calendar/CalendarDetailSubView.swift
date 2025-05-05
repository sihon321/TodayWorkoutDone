//
//  CalendarDetailSubView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/10/04.
//

import SwiftUI
import ComposableArchitecture
import SwiftData

@Reducer
struct CalendarDetailSubViewReducer {
    @ObservableState
    struct State: Equatable, Identifiable {
        @Presents var destination: Destination.State?
        
        let id = UUID()
        var workoutRoutine: WorkoutRoutineState
        var step = StepFeature.State()
        var exerciseTime = ExerciseTimeFeature.State()
        var energyBurn = EnergyBurnFeature.State()
    }
    
    enum Action {
        case edit
        case delete
        case destination(PresentationAction<Destination.Action>)
        case step(StepFeature.Action)
        case exerciseTime(ExerciseTimeFeature.Action)
        case energyBurn(EnergyBurnFeature.Action)
    }
    
    @Reducer(state: .equatable)
    enum Destination {
        case editWorkoutRoutine(EditWorkoutRoutineReducer)
    }
    
    @Dependency(\.workoutRoutineData) var workoutRoutineContext
    
    var body: some Reducer<State, Action> {
        Scope(state: \.step, action: \.step) {
            StepFeature()
        }
        Scope(state: \.exerciseTime, action: \.exerciseTime) {
            ExerciseTimeFeature()
        }
        Scope(state: \.energyBurn, action: \.energyBurn) {
            EnergyBurnFeature()
        }
        Reduce { state, action in
            switch action {
            case .edit:
                state.destination = .editWorkoutRoutine(
                    EditWorkoutRoutineReducer.State(
                        workoutRoutine: state.workoutRoutine
                    )
                )
                return .none
            case .delete:
                if let id = state.workoutRoutine.persistentModelID {
                    let descriptor = FetchDescriptor<WorkoutRoutine>(
                        predicate: #Predicate {
                            $0.persistentModelID == id
                        }
                    )
                    do {
                        if let deleteToWorkoutRoutine = try workoutRoutineContext.fetch(descriptor).first {
                            try workoutRoutineContext.delete(deleteToWorkoutRoutine)
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }

                return .none
            case .step:
                return .none
            case .exerciseTime:
                return .none
            case .energyBurn:
                return .none
            case .destination(.presented(.editWorkoutRoutine(.save))):
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) {
            Destination.body
        }
    }
}


struct CalendarDetailSubView: View {
    @Bindable var store: StoreOf<CalendarDetailSubViewReducer>
    @ObservedObject var viewStore: ViewStoreOf<CalendarDetailSubViewReducer>
    
    init(store: StoreOf<CalendarDetailSubViewReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("\(viewStore.workoutRoutine.name)")
                    .font(.title)
                Spacer()
                Button(action: {}) {
                    Menu {
                        Button(action: {
                            viewStore.send(.edit)
                        }) {
                            Label("편집", systemImage: "pencil")
                        }
                        Button(action: {
                            viewStore.send(.delete)
                        }) {
                            Label("삭제", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .contentShape(Rectangle())
                            .frame(minHeight: 20)
                            .padding(.trailing, 15)
                            .tint(Color(0x939393))
                    }
                }
            }
            Text("\(viewStore.workoutRoutine.startDate.formatToKoreanStyle())")
            
            HStack {
                Image(systemName: "timer")
                Text(viewStore.workoutRoutine.routineTime.convertSecondsToHMS())
                    .padding(.trailing, 10)
                Image(systemName: "flame")
                Text("\(Int(viewStore.workoutRoutine.calories)) kcal")
            }
            .padding(.bottom, 5)
            HStack {
                Image(systemName: "heart.fill")
                    .resizable()
                    .frame(width: 20, height: 18)
                    .foregroundStyle(.red)
                Text("Apple Health")
            }
            HStack {
                HStack {
                    Image(systemName: "shoeprints.fill")
                        .resizable()
                        .frame(width: 15, height: 18)
                    Text("\(viewStore.step.stepCount) 걸음")
                }
                .onAppear {
                    store.send(.step(.fetchStep(
                        from: viewStore.workoutRoutine.startDate,
                        to: viewStore.workoutRoutine.endDate))
                    )
                }
                HStack {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .resizable()
                        .frame(width: 15, height: 18)
                    Text("\(viewStore.exerciseTime.exerciseTime / 60) 시간 \(viewStore.exerciseTime.exerciseTime % 60) 분")
                        .foregroundStyle(.black)
                }
                .onAppear {
                    store.send(.exerciseTime(.fetchExerciseTime(
                        from: viewStore.workoutRoutine.startDate,
                        to: viewStore.workoutRoutine.endDate))
                    )
                }
                HStack {
                    Image(systemName: "flame.fill")
                        .resizable()
                        .frame(width: 15, height: 18)
                    Text("\(viewStore.energyBurn.energyBurned) kcal")
                        .foregroundStyle(.black)
                }
                .onAppear {
                    store.send(.energyBurn(.fetchEnergyBurned(
                        from: viewStore.workoutRoutine.startDate,
                        to: viewStore.workoutRoutine.endDate))
                    )
                }
            }
            
            ForEach(viewStore.workoutRoutine.routines, id: \.id) { routine in
                HStack {
                    if let image = UIImage(named: routine.workout.name) ?? UIImage(named: "default") {
                        Image(uiImage: image)
                            .resizable()
                            .frame(maxWidth: 45, maxHeight: 45)
                            .cornerRadius(10)
                    }
                    VStack(alignment: .leading) {
                        Text(routine.workout.name)
                        HStack {
                            Image(systemName: "dumbbell")
                            Text("\(String(format: "%.2f", routine.sets.reduce(0) { $0 + $1.weight })) kg")
                                .padding(.trailing, 10)
                            Image(systemName: "flame")
                            Text("\(Int(routine.calories)) kcal")
                        }
                    }
                }
                .padding(.leading, 5)
                .padding([.top, .bottom], 10)
                VStack {
                    HStack {
                        Text("세트")
                        Spacer()
                        Text("무게")
                        Spacer()
                        Text("횟수")
                        Spacer()
                    }
                    ForEach(routine.sets.indices, id: \.self) { index in
                        HStack {
                            Text("\(index + 1)")
                                .frame(width: 20, height: 20)
                            Spacer()
                            Text("\(String(format: "%.2f", routine.sets[index].weight)) kg")
                            Spacer()
                            Text("\(routine.sets[index].reps) reps")
                            Spacer()
                        }
                    }
                }
                .padding(.leading, 20)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding([.leading, .trailing], 10)
        .padding([.top, .bottom], 5)
        .fullScreenCover(
            item: $store.scope(state: \.destination?.editWorkoutRoutine,
                               action: \.destination.editWorkoutRoutine)
        ) { store in
            EditWorkoutRoutineView(store: store)
        }
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

#Preview {
    CalendarDetailSubView(
        store: Store(
            initialState: CalendarDetailSubViewReducer.State(
                workoutRoutine: WorkoutRoutineState(model: WorkoutRoutine.mockedData))
        ) {
            CalendarDetailSubViewReducer()
        }
    )
}
