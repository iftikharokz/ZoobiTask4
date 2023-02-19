//
//  ZoobiTask4App.swift
//  ZoobiTask4
//
//  Created by Theappmedia on 2/17/23.
//

import SwiftUI

@main
struct ZoobiTask4App: App {
    @StateObject var dataController = DataController()
    var body: some Scene {
        WindowGroup {
            NavigationView{
                ContentView()
            }
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .navigationViewStyle(.stack)
            
        }
    }
}
