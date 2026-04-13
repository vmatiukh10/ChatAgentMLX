import Testing
@testable import AgentMLX

// MARK: - ChatMessage.Role

@Suite("ChatMessage.Role")
struct ChatMessageRoleTests {

    @Test("Raw values match expected strings")
    func rawValues() {
        #expect(ChatMessage.Role.user.rawValue == "user")
        #expect(ChatMessage.Role.assistant.rawValue == "assistant")
        #expect(ChatMessage.Role.system.rawValue == "system")
    }

    @Test("All roles are distinct")
    func distinctRoles() {
        let roles: [ChatMessage.Role] = [.user, .assistant, .system]
        let rawValues = roles.map(\.rawValue)
        #expect(Set(rawValues).count == roles.count)
    }
}

// MARK: - ChatMessage

@Suite("ChatMessage")
struct ChatMessageTests {

    @Test("Init stores role and content")
    func initStoresValues() {
        let msg = ChatMessage(role: .user, content: "Hello!")
        #expect(msg.role == .user)
        #expect(msg.content == "Hello!")
    }

    @Test("Empty content is preserved")
    func emptyContent() {
        let msg = ChatMessage(role: .system, content: "")
        #expect(msg.content == "")
    }

    @Test("Multiline content is preserved")
    func multilineContent() {
        let text = "Line one\nLine two\nLine three"
        let msg = ChatMessage(role: .assistant, content: text)
        #expect(msg.content == text)
    }

    @Test("Unicode content is preserved")
    func unicodeContent() {
        let text = "こんにちは 🌸"
        let msg = ChatMessage(role: .user, content: text)
        #expect(msg.content == text)
    }

    @Test("Conforms to ChatMessageable protocol")
    func conformsToProtocol() {
        let msg: ChatMessageable = ChatMessage(role: .assistant, content: "Hi")
        #expect(msg.role == .assistant)
        #expect(msg.content == "Hi")
    }

    @Test("All roles can be assigned")
    func allRoles() {
        for role in [ChatMessage.Role.user, .assistant, .system] {
            let msg = ChatMessage(role: role, content: "test")
            #expect(msg.role == role)
        }
    }
}
