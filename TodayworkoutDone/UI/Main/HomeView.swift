//
//  HomeView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2023/05/20.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var dataController: DataController
    @State private var isPresented = false
    @Binding var isPresentWorkoutView: PresentationMode
    @State var currentTab = "play.fill"
    @Environment(\.injected) private var injected: DIContainer
    
    var bottomEdge: CGFloat
    @State var hideBar = false
    
    init(presentMode: Binding<PresentationMode>, bottomEdge: CGFloat) {
        UITabBar.appearance().isHidden = true
        self._isPresentWorkoutView = presentMode
        self.bottomEdge = bottomEdge
    }
    
    var body: some View {
        ZStack {
            TabView {
                ZStack {
                    MainView(bottomEdge: bottomEdge)
                    
                    if injected.appState[\.userData.isWorkingOutView] {
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
                        ExcerciseStartView(isPresented: $isPresented)
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

struct HomeView_Previews: PreviewProvider {
    @StateObject static var dataController = DataController()
    @Environment(\.presentationMode) static var presentationmode
    
    static var previews: some View {
        HomeView(presentMode: presentationmode,
                 bottomEdge: 0)
            .environment(\.managedObjectContext, dataController.container.viewContext)
    }
}
