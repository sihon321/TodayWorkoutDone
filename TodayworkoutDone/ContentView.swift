//
//  ContentView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/11/14.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var modelData: DataController
    @State var isBarPresented: Bool = true
    @State var isPresented = false
    
    var body: some View {
        ZStack {
            TabView {
                ZStack {
                    MainView()
                    ExcerciseStartView(isBarPresented: $isBarPresented,
                                       isPresented: $isPresented)
                }
                .tabItem({
                    Image(systemName: "play.fill")
                    Text("Main")
                })
            }

//            SlideOverCardView(content: {
//                WorkingOutView()
//                    .environmentObject(modelData)
//            })
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    @StateObject static var dataController = DataController()
    
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, dataController.container.viewContext)
    }
}
