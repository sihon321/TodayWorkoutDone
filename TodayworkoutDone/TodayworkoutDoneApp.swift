//
//  TodayworkoutDoneApp.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/11/14.
//

import SwiftUI

@main
struct TodayworkoutDoneApp: App {
    @Environment(\.presentationMode) var presentationmode
    @StateObject private var dataController = DataController()
    @StateObject var myObject = MyObservableObject()
    
    var body: some Scene {
        WindowGroup {
            ContentView(isPresentWorkoutView: presentationmode)
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(myObject)
        }
    }
}
