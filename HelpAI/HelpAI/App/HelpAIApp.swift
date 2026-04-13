//
//  HelpAIApp.swift
//  HelpAI
//
//  Created by Volodymyr Matiukh on 10.04.2026.
//

import SwiftUI
import Observation

@main
struct HelpAIApp: App {
    // App owns the model and injects it
    private let viewModel = MainViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainView(viewModel: viewModel)
        }
    }
}
