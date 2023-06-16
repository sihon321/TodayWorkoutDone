//
//  ContentView.swift
//  TodayworkoutDone
//
//  Created by Sihoon Oh on 2022/11/14.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.presentationMode) var presentationmode
    @StateObject private var dataController = DataController()
    private let container: DIContainer 
    
    init(container: DIContainer) {
        self.container = container
    }
    
    var body: some View {
        GeometryReader { proxy in
            let bottomEdge = proxy.safeAreaInsets.bottom
            
            HomeView(bottomEdge: (bottomEdge == 0 ? 15 : bottomEdge))
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .inject(container)
                .ignoresSafeArea(.all, edges: .bottom)
        }
    }
}

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        ContentView(container: .preview)
    }
}
