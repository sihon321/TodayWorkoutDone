//
//  HomeView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/05/20.
//

import SwiftUI
import Combine

struct HomeView: View {
    @Environment(\.injected) private var injected: DIContainer

    @State private var routingState: Routing = .init()
    @State private var currentTab = "dumbbell.fill"
    @State private var currentIndex = 0
    @State private var hideTabValue: CGFloat = 0
    @State private var isCloseWorking: Bool = false
    @State private var isSavedAlert = false
    @State private var routineName = ""
    
    private var myRoutine: MyRoutine {
        injected.appState[\.userData.myRoutine]
    }
    
    private var bottomEdge: CGFloat
    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.homeView)
    }
    
    init(bottomEdge: CGFloat) {
        UITabBar.appearance().isHidden = true
        self.bottomEdge = bottomEdge
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $currentIndex) {
                ZStack {
                    MainView(bottomEdge: bottomEdge)
                    if !routingBinding.workingOutView.wrappedValue {
                        ExcerciseStartView()
                            .padding([.bottom], 40)
                    }
                    if routingBinding.workingOutView.wrappedValue {
                        SlideOverCardView(hideTabValue: $hideTabValue, content: {
                            WorkingOutView(isCloseWorking: $isCloseWorking,
                                           hideTabValue: $hideTabValue,
                                           isSavedAlert: $isSavedAlert)
                        })
                    } else {
                        
                    }
                }
                .tag(0)
                CalendarView()
                    .tag(1)
            }
            .overlay (
                VStack {
                    CustomTabBar(currentTab: $currentTab,
                                 currentIndex: $currentIndex,
                                 bottomEdge: bottomEdge)
                }
                    .offset(y: isCloseWorking ? 0.0 : hideTabValue)
                ,alignment: .bottom
            )
            Spacer()
        }
        .onReceive(routingUpdate) { self.routingState = $0 }
        .alert("루틴은 저장하겠습니까?", isPresented: $isSavedAlert) {
            TextField("루틴 이름을 정해주세요", text: $routineName)
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
            myRoutine: MyRoutine(id: myRoutine.id,
                                 name: routineName,
                                 routines: myRoutine.routines)
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

struct HomeView_Previews: PreviewProvider {
    
    static var previews: some View {
        HomeView(bottomEdge: 0)
            .inject(.preview)
    }
}
