//
//  HomeView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/05/20.
//

import SwiftUI
import ComposableArchitecture
import Combine

@Reducer
struct HomeReducer {
    enum Tab { case workout }
    
    @ObservableState
    struct State: Equatable {
        var bottomEdge: CGFloat
        var routineName = ""
        var workingOut = WorkingOutReducer.State()
        var tabBar: CustomTabBarReducer.State
        
        init(bottomEdge: CGFloat) {
            self.bottomEdge = bottomEdge
            tabBar = CustomTabBarReducer.State(
                bottomEdge: bottomEdge,
                tabButton: TabButtonReducer.State(
                    info: TabButtonReducer.TabInfo(imageName: "dumbbell.fill",
                                                   index: 0)
                )
            )
        }
    }
    
    enum Action {
        case enterRoutineName(name: String)
        case workingOut(WorkingOutReducer.Action)
        case tabBar(CustomTabBarReducer.Action)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .enterRoutineName(let name):
                state.routineName = name
                return .none
            case .workingOut(.hideTabBar):
                state.workingOut.isHideTabBar = true
                return .none
            case .workingOut(.setTabBarOffset(let offset)):
                state.workingOut.tabBarOffset = offset
                return .none
            case .workingOut(.saveRoutine(let isSavedRoutine)):
                state.workingOut.isSavedRoutine = isSavedRoutine
                return .none
            case .workingOut(.saveWorkout(let isSavedWorkout)):
                state.workingOut.isSavedWorkout = isSavedWorkout
                return .none
            case .tabBar(.tabButton(.setTab(let info))):
                state.tabBar.tabButton.info = info
                return .none
            }
        }
    }
}

struct HomeView: View {
    @Bindable var store: StoreOf<HomeReducer>
    @ObservedObject var viewStore: ViewStoreOf<HomeReducer>
    
    init(store: StoreOf<HomeReducer>) {
        UITabBar.appearance().isHidden = true
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
    }
    
    var body: some View {
        ZStack {
            TabView(
                selection: viewStore.binding(
                    get: { $0.tabBar.tabButton.info },
                    send: { HomeReducer.Action.tabBar(.tabButton(.setTab(info: $0))) }
                ).index
            ) {
                ZStack {
                    MainView(bottomEdge: store.state.bottomEdge)
                    if !routingBinding.workingOutView.wrappedValue {
                        ExcerciseStartView(
                            store: Store(initialState: ExcerciseStarter.State()) {
                                ExcerciseStarter()
                            }
                        )
                        .padding([.bottom], 40)
                    } else {
                        SlideOverCardView(
                            hideTabValue: viewStore.binding(
                                get: { $0.workingOut.tabBarOffset },
                                send: { HomeReducer.Action.workingOut(.setTabBarOffset(offset: $0)) }
                            ),
                            content: {
                                WorkingOutView(
                                    store: store.scope(state: \.workingOut, action: \.workingOut),
                                    myRoutine: .constant(injected.appState[\.userData.myRoutine]))
                            })
                    }
                }
                .tag(0)
                
                CalendarView()
                    .tag(1)
            }
            .overlay (
                VStack {
                    CustomTabBar(store: store.scope(state: \.tabBar,
                                                    action: \.tabBar))
                }.offset(y: store.state.workingOut.isHideTabBar ? 0.0 : store.state.workingOut.tabBarOffset),
                alignment: .bottom
            )
            Spacer()
        }
        .alert("루틴은 저장하겠습니까?",
               isPresented: viewStore.binding(
                get: { $0.workingOut.isSavedRoutine },
                send: { HomeReducer.Action.workingOut(.saveRoutine(isSavedRoutine: $0)) }
               )
        ) {
            TextField("루틴 이름을 정해주세요", text: viewStore.binding(
                get: \.routineName,
                send: HomeReducer.Action.enterRoutineName)
            )
            Button("Cancel") { 
                viewStore.send(.workingOut(.saveRoutine(isSavedRoutine: false)))
            }
            Button("OK") {
                saveMyRoutine()
            }
        } message: {
            Text("새로운 루틴을 저장하시겟습니까")
        }
    }
}

private extension HomeView {
    func saveMyRoutine() {
        injected.interactors.routineInteractor.store(
            myRoutine: MyRoutine(id: injected.appState[\.userData.myRoutine].id,
                                 name: store.state.routineName,
                                 routines: injected.appState[\.userData.myRoutine].routines)
        )
    }
}

//struct HomeView_Previews: PreviewProvider {
//    
//    static var previews: some View {
//        HomeView(bottomEdge: 0)
//            .inject(.preview)
//    }
//}
