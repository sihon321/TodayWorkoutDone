//
//  MainContentSubView.swift
//  TodayWorkoutDone (iOS)
//
//  Created by ocean on 2022/08/07.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct MainSubContentFeature {
    @ObservableState
    struct State: Equatable, Identifiable {
        let id: UUID = UUID()
        var type: MainContentFeature.MainContentType
        var iconName: String {
            switch type {
            case .stepCount: return "figure.walk"
            case .workoutTime: return "figure.strengthtraining.traditional"
            case .energyBurn: return "flame.fill"
            }
        }
        
        var headerTitle: String {
            switch type {
            case .stepCount: return "걸음"
            case .workoutTime: return "운동시간"
            case .energyBurn: return "활동"
            }
        }
        var step = StepFeature.State()
        var workout = ExerciseTimeFeature.State()
        var energy = EnergyBurnFeature.State()
    }
    
    enum Action {
        case step(StepFeature.Action)
        case workout(ExerciseTimeFeature.Action)
        case energy(EnergyBurnFeature.Action)
    }
    
    
    var body: some Reducer<State, Action> {
        Scope(state: \.step, action: \.step) {
            StepFeature()
        }
        Scope(state: \.workout, action: \.workout) {
            ExerciseTimeFeature()
        }
        Scope(state: \.energy, action: \.energy) {
            EnergyBurnFeature()
        }
        
        Reduce { state, action in
            return .none
        }
    }
}

struct MainContentSubView: View {
    @Bindable var store: StoreOf<MainSubContentFeature>
    @ObservedObject var viewStore: ViewStoreOf<MainSubContentFeature>
    
    init(store: StoreOf<MainSubContentFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .firstTextBaseline) {
                Image(systemName: viewStore.iconName)
                    .foregroundStyle(Color.todBlack)
                Text(viewStore.headerTitle)
                    .font(.system(size: 15,
                                  weight: .semibold,
                                  design: .default))
                    .foregroundStyle(Color.todBlack)
                    .padding(.leading, -5)
            }
            .padding([.leading], 15)
            
            HStack(alignment: .firstTextBaseline) {
                switch viewStore.type {
                case .stepCount:
                    MainContentStepView(
                        store: store.scope(state: \.step, action: \.step)
                    )
                case .workoutTime:
                    MainContentWorkoutView(
                        store: store.scope(state: \.workout, action: \.workout)
                    )
                case .energyBurn:
                    MainContentEnergyBurn(
                        store: store.scope(state: \.energy, action: \.energy)
                    )
                }
            }
            .padding(.leading, 15)
            .padding([.top, .bottom], 5)
        }
        .frame(minWidth: 0,
               maxWidth: .infinity,
               minHeight: 80,
               alignment: .leading)
        .background(Color.contentBackground)
        .cornerRadius(15)
    }
}
