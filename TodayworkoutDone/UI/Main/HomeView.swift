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
    @State private var currentTab = "play.fill"
    @State private var hideBar = false
    @State private var isSavedAlert = false
    
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
            TabView {
                ZStack {
                    MainView(bottomEdge: bottomEdge)
                    
                    if routingBinding.workingOutView.wrappedValue {
                        SlideOverCardView(hideTab: $hideBar, content: {
                            WorkingOutView(hideTab: $hideBar, isSavedAlert: $isSavedAlert)
                        })
                        .onAppear {
                            hideBar = true
                        }
                    } else {
                        
                    }
                }
                .tabItem({
                    Text("play.fill")
                })
            }
            .overlay (
                VStack {
                    if !routingBinding.workingOutView.wrappedValue {
                        ExcerciseStartView()
                    }
                    CustomTabBar(currentTab: $currentTab, bottomEdge: bottomEdge)
                }
                    .offset(y: hideBar ? (15 + 35 + bottomEdge) : 0)
                ,alignment: .bottom
            )
            Spacer()
        }
        .onReceive(routingUpdate) { self.routingState = $0 }
        .alert("저장하겠습니까?", isPresented: $isSavedAlert) {
            Button("Cancel") { }
            Button("OK") {
                
            }
        } message: {
            Text("새로운 루틴을 저장하시겟습니까")
        }
    }
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
