//
//  MainViewModel.swift
//  HelpAI
//
//  Created by Volodymyr Matiukh on 10.04.2026.
//

import Foundation
import AgentMLX
internal import Combine

struct ChatMessageModel: Identifiable, Hashable {
    enum Role: Equatable, Hashable {
        case user
        case assistant
        case system
        
        init(from agentRole: ChatMessage.Role) {
            switch agentRole {
            case .user: self = .user
            case .assistant: self = .assistant
            case .system: self = .system
            }
        }
    }
    
    let id = UUID()
    let role: Role
    let content: String
    
    init(role: Role, content: String) {
        self.role = role
        self.content = content
    }
    
    init(from message: any ChatMessageable) {
        self.role = Role(from: message.role)
        self.content = message.content
    }
}

@Observable
class MainViewModel {
    
    enum State: Equatable {
        case idle
        case loadingModel
        case ready
        case generating
        case error(String)
        
        var isProcessing: Bool {
            self == .loadingModel || self == .generating
        }
        
        var errorMessage: String? {
            if case .error(let message) = self {
                return message
            }
            return nil
        }
    }
    
    @MainActor
    var agent: Agentable?
    
    var history: [ChatMessageModel] = []
    
    var inputedValue: String = ""
    
    var state: State = .loadingModel
    
    init() {
        Task {
            do {
                guard let modelSource = ModelSource.default else {
                    self.state = .error("No models found")
                    return
                }
                self.agent = try await AgentMLX.create(modelSource: modelSource)
                await MainActor.run {
                    self.state = .ready
                }
            } catch {
                await MainActor.run {
                    self.state = .error(error.localizedDescription)
                }
            }
        }
    }
    
    func generateAnswer() {
        guard !state.isProcessing, let agent else {
            return
        }
        
        let prompt = inputedValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty else { return }
        
        inputedValue = ""
        
        // Add the user message immediately so it shows up in the UI
        history.append(ChatMessageModel(role: .user, content: prompt))
        
        state = .generating
        
        Task {
            do {
                _ = try await agent.generate(with: prompt)
                
                // Sync the full history from the agent
                let updatedHistory = agent.history.map { ChatMessageModel(from: $0) }
                
                // Update history on main thread
                await MainActor.run {
                    self.history = updatedHistory
                    self.state = .ready
                }
            } catch {
                await MainActor.run {
                    self.state = .error(error.localizedDescription)
                }
            }
        }
    }
}
