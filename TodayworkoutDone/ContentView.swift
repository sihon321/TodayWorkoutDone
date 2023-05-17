//
//  ContentView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/11/14.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataController: DataController
    @State var isBarPresented: Bool = true
    @State var isPresented = false
    @State private var isPresentWorkingOutView = false
    @State private var selectionWorkouts: [Excercise] = []
    @Binding var isPresentWorkoutView: PresentationMode
    
    var body: some View {
        ZStack {
            TabView {
                ZStack {
                    MainView()
                    ExcerciseStartView(isBarPresented: $isBarPresented,
                                       isPresented: $isPresented)
//                    SlideOverCardView(content: {
//                        WorkingOutView(makeWorkingOutView: false,
//                                       isPresentWorkingOutView: $isPresentWorkingOutView,
//                                       isPresentWorkoutView: $isPresentWorkoutView,
//                                       selectionWorkouts: $selectionWorkouts)
//                    })
                }
                .tabItem({
                    Image(systemName: "play.fill")
                    Text("Main")
                })
            }
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    @StateObject static var dataController = DataController()
    @Environment(\.presentationMode) static var presentationmode
    
    static var previews: some View {
        ContentView(isPresentWorkoutView: presentationmode)
            .environment(\.managedObjectContext, dataController.container.viewContext)
    }
}
