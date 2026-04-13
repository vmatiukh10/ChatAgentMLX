import MLXLLM
import MLXLMTokenizers
import MLXLMCommon
import Foundation

public final class AgentMLX {
    private let modelSource: ModelSource
    private var chatSession: ChatSession?

    private var _history: [ChatMessage] = []
    public var history: [ChatMessageable] { _history }

    init(modelSource: ModelSource) {
        self.modelSource = modelSource
    }

    private func downloadModel() async throws {
        let modelContainer = try await loadModelContainer(
            from: modelSource.filePath(),
            using: TokenizersLoader()
        )
        chatSession = ChatSession(modelContainer)
    }
}

extension AgentMLX: Agentable {
    public static func create(modelSource: ModelSource) async throws -> AgentMLX {
        let agent = AgentMLX(modelSource: modelSource)
        try await agent.downloadModel()
        return agent
    }

    public func generate(with promt: String) async throws -> String {
        guard let chatSession else {
            throw AgentError.noChatSession
        }
        _history.append(ChatMessage(role: .user, content: promt))
        let response = try await chatSession.respond(to: promt)
        _history.append(ChatMessage(role: .assistant, content: response))
        return response
    }
}
