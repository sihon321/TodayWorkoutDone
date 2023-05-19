//
//  ContentView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/11/14.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataController: DataController
    @State private var isPresented = false
    @State private var isPresentWorkingOutView = false
    @Binding var isPresentWorkoutView: PresentationMode
    @EnvironmentObject var myObject: MyObservableObject
    
    var body: some View {
        ZStack {
            TabView {
                ZStack {
                    MainView()
                    if myObject.isWorkingOutView {
                        SlideOverCardView(content: {
                            WorkingOutView(isPresentWorkingOutView: $isPresentWorkingOutView,
                                           isPresentWorkoutView: $isPresentWorkoutView)
                        })
                    } else {
                        ExcerciseStartView(isPresented: $isPresented)
                    }
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
