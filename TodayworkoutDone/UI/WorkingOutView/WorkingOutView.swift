//
//  WorkingOutView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/12/28.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct WorkingOutReducer {
    @ObservableState
    struct State: Equatable {
        var myRoutine: MyRoutine
        var workingOutSection: IdentifiedArrayOf<WorkingOutSectionReducer.State>
        
        var secondsElapsed = 0
        var isTimerActive = false
        
        static func == (lhs: WorkingOutReducer.State, rhs: WorkingOutReducer.State) -> Bool {
            return lhs.myRoutine.id == rhs.myRoutine.id
        }
    }
    
    enum Action {
        case tappedToolbarCloseButton(secondsElapsed: Int)
        case tappedEdit
        
        case cancelTimer
        case resetTimer
        case timerTicked
        case toggleTimer
        
        indirect case workingOutSection(IdentifiedActionOf<WorkingOutSectionReducer>)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            default:
                return .none
            }
        }
    }
}

struct WorkingOutView: View {
    @Bindable var store: StoreOf<WorkingOutReducer>
    @ObservedObject var viewStore: ViewStoreOf<WorkingOutReducer>
    
    private let gridLayout: [GridItem] = [GridItem(.flexible())]
    
    init(store: StoreOf<WorkingOutReducer>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(store.scope(state: \.workingOutSection, action: \.workingOutSection)) { rowStore in
                    WorkingOutSection(store: rowStore)
                }
                Spacer().frame(height: 100)
            }
            .onAppear {
                store.send(.toggleTimer)
            }
            .onDisappear {
                store.send(.cancelTimer)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        store.send(.tappedToolbarCloseButton(secondsElapsed: store.state.secondsElapsed))
                        store.send(.toggleTimer)
                    }
                }
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(store.state.secondsElapsed.secondToHMS)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        store.send(.tappedEdit)
                    }
                }
            }
            .navigationTitle(store.myRoutine.name)
            .listStyle(.grouped)
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }
}
