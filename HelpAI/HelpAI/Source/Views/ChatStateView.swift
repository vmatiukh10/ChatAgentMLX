import SwiftUI

struct ChatStateView: View {
    let state: MainViewModel.State
    
    var body: some View {
        HStack {
            if state == .loadingModel || state == .generating {
                ProgressView().scaleEffect(0.4).padding(.trailing, 4)
                Text(state == .loadingModel ? Constants.Strings.loadingModel : Constants.Strings.assistantTyping)
                    .foregroundColor(.gray)
                    .italic()
            } else if let error = state.errorMessage {
                Text(Constants.Strings.errorMessage(error))
                    .foregroundColor(.red)
                    .font(.caption)
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

