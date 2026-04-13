import Foundation

public enum Constants {
    public enum Strings {
        public static let loadingModel = LocalizedStringResource("loading_model")
        
        public static let assistantTyping = LocalizedStringResource("assistant_typing")
        
        public static let typeHere = LocalizedStringResource("type_here")
        
        public static func errorMessage(_ message: String) -> LocalizedStringResource {
            LocalizedStringResource("error_message \(message)")
        }
    }
}
