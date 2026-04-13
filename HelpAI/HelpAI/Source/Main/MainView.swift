//
//  MainView.swift
//  HelpAI
//
//  Created by Volodymyr Matiukh on 10.04.2026.
//

import SwiftUI
import Observation

struct MainView: View {
    
    // Injected observable view model (owned by parent)
    @Bindable var viewModel: MainViewModel
    
    var body: some View {
        VStack {
            Spacer()
            List(viewModel.history) { message in
                MessageView(message: message)
            }
            
            ChatStateView(state: viewModel.state)
            
            ChatInputView(viewModel: viewModel)
        }
        .padding()
    }
}

#Preview {
    // Simple preview with an injected model
    MainView(viewModel: MainViewModel())
}
