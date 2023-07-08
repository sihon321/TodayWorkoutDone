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
    @EnvironmentObject var dataController: DataController

    @State private var routingState: Routing = .init()
    @State private var currentTab = "play.fill"
    @State private var hideBar = false
    
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
                            WorkingOutView()
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
    @StateObject static var dataController = DataController()
    
    static var previews: some View {
        HomeView(bottomEdge: 0)
            .environment(\.managedObjectContext, dataController.container.viewContext)
    }
}
