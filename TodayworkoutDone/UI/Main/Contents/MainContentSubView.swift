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
    struct State: Equatable {
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
    }
    
    enum Action {

    }
    
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {

            }
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
                    .foregroundStyle(.black)
                Text(viewStore.headerTitle)
                    .font(.system(size: 15,
                                  weight: .semibold,
                                  design: .default))
                    .foregroundStyle(.black)
                    .padding(.leading, -5)
            }
            .padding([.leading], 15)
            
            HStack(alignment: .firstTextBaseline) {
                switch viewStore.type {
                case .stepCount:
                    MainContentStepView(
                        store: Store(initialState: StepFeature.State()) {
                            StepFeature()
                        }
                    )
                case .workoutTime:
                    MainContentWorkoutView(
                        store: Store(initialState: ExerciseTimeFeature.State()) {
                            ExerciseTimeFeature()
                        }
                    )
                case .energyBurn:
                    MainContentEnergyBurn(
                        store: Store(initialState: EnergyBurnFeature.State()) {
                            EnergyBurnFeature()
                        }
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
        .background(Color.white)
        .cornerRadius(15)
    }
}
