import Foundation

public protocol ChatMessageable {
    var role: ChatMessage.Role { get }
    var content: String { get }
}
