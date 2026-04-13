import Foundation

enum AgentError: Error, Equatable {
    case noChatSession
    case noModelAvailable
}
