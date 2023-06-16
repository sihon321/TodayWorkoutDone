//
//  HomeView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/05/20.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.injected) private var injected: DIContainer
    @EnvironmentObject var dataController: DataController

    @State private var isPresented = false
    @State private var isWorkingOut = false
    @State var currentTab = "play.fill"
    @State private var routingState: Routing = .init()
    @State var hideBar = false
    var bottomEdge: CGFloat
//    private var routingBinding: Binding<Routing> {
//        $routingState.dispatched(to: injected.appState, \.routing.homeView)
//    }

    init(bottomEdge: CGFloat) {
        UITabBar.appearance().isHidden = true
        self.bottomEdge = bottomEdge
    }
    
    var body: some View {
        ZStack {
            TabView {
                ZStack {
                    MainView(bottomEdge: bottomEdge)
                    
                    if isWorkingOut {
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
                    if !injected.appState[\.userData.isWorkingOutView] {
                        ExcerciseStartView(isPresented: $isPresented,
                                           isWorkingOut: $isWorkingOut)
                    }
                    CustomTabBar(currentTab: $currentTab, bottomEdge: bottomEdge)
                }
                    .offset(y: hideBar ? (15 + 35 + bottomEdge) : 0)
                ,alignment: .bottom
            )
            Spacer()
        }
    }
}

extension HomeView {
    struct Routing: Equatable {
        var workoutView: Bool = false
    }
}

struct HomeView_Previews: PreviewProvider {
    @StateObject static var dataController = DataController()
    
    static var previews: some View {
        HomeView(bottomEdge: 0)
            .environment(\.managedObjectContext, dataController.container.viewContext)
    }
}
