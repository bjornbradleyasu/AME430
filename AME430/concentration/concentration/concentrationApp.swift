//
//  concentrationApp.swift
//  concentration
//
//  Created by Bjorn Bradley on 9/11/24.
//

import SwiftUI

@main
struct concentrationApp: App {
    @StateObject private var gameViewModel = PairsGameViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameViewModel)
        }
    }
}
