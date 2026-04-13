import Foundation

public struct ChatMessage: ChatMessageable {
    public enum Role: String {
        case user
        case assistant
        case system
    }

    public let role: Role
    public let content: String

    public init(role: Role, content: String) {
        self.role = role
        self.content = content
    }
}
