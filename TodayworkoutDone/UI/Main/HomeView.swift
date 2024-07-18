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
        var currentTab = Tab.workout
        var routineName = ""
        var workingOut = WorkingOutReducer.State()
        
        @Presents var alert: AlertState<Action.Alert>?
    }
    
    enum Action {
        case alert(PresentationAction<Alert>)
        case enterRoutineName(name: String)
        case workingOut(WorkingOutReducer.Action)
        
        @CasePathable
        enum Alert {
            case isSaved
            case isClosedWorking
        }
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .alert(.presented(.isSaved)), .alert(.presented(.isClosedWorking)):
                return .none
            case .alert:
                return .none
            case .enterRoutineName(let name):
                state.routineName = name
                return .none
            case .workingOut(.hideTabBar):
                state.workingOut.isHideTabBar = false
                return .none
            case .workingOut(.setTabBarOffset(let offset)):
                state.workingOut.tabBarOffset = offset
                return .none
            }
        }
    }
}

struct HomeView: View {
    @Environment(\.injected) private var injected: DIContainer
    @Bindable var store: StoreOf<HomeReducer>
    @ObservedObject var viewStore: ViewStoreOf<HomeReducer>

    @State private var routingState: Routing = .init()
    @State private var currentTab = "dumbbell.fill"
    @State private var currentIndex = 0
    @State private var isSavedAlert = false
    
    private var bottomEdge: CGFloat
    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.homeView)
    }
    
    init(bottomEdge: CGFloat, store: StoreOf<HomeReducer>) {
        UITabBar.appearance().isHidden = true
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
        self.bottomEdge = bottomEdge
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $currentIndex) {
                ZStack {
                    MainView(bottomEdge: bottomEdge)
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
                                    myRoutine: .constant(injected.appState[\.userData.myRoutine]),
                                    isSavedAlert: $isSavedAlert)
                            })
                    }
                }.tag(0)
                CalendarView()
                    .tag(1)
            }
            .overlay (
                VStack {
                    CustomTabBar(currentTab: $currentTab,
                                 currentIndex: $currentIndex,
                                 bottomEdge: bottomEdge)
                }.offset(y: store.state.workingOut.isHideTabBar ? 0.0 : store.state.workingOut.tabBarOffset),
                alignment: .bottom
            )
            Spacer()
        }
        .onReceive(routingUpdate) { self.routingState = $0 }
        .alert("루틴은 저장하겠습니까?", isPresented: $isSavedAlert) {
            TextField("루틴 이름을 정해주세요", text: viewStore.binding(
                get: \.routineName,
                send: HomeReducer.Action.enterRoutineName)
            )
            Button("Cancel") { }
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

private extension HomeView {
    
}

extension HomeView {
    struct Routing: Equatable {
        var workingOutView: Bool = false
    }
}

private extension HomeView {
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.homeView)
    }
}

//struct HomeView_Previews: PreviewProvider {
//    
//    static var previews: some View {
//        HomeView(bottomEdge: 0)
//            .inject(.preview)
//    }
//}
