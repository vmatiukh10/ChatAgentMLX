import SwiftUI

struct MessageView: View {
    let message: ChatMessageModel
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
                Text(message.content)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            } else {
                Text(message.content)
                    .padding()
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(12)
                Spacer()
            }
        }
    }
}
