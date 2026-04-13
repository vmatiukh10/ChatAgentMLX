import SwiftUI

struct ChatInputView: View {
    @Bindable var viewModel: MainViewModel
    
    var body: some View {
        HStack {
            let isDisabled = viewModel.state.isProcessing
            TextField(Constants.Strings.typeHere, text: $viewModel.inputedValue)
                .textFieldStyle(.roundedBorder)
                .disabled(isDisabled)
                .onSubmit {
                    viewModel.generateAnswer()
                }
                
            Button {
                viewModel.generateAnswer()
            } label: {
                Image(systemName: "paperplane.fill")
            }
            .disabled(viewModel.inputedValue.isEmpty || isDisabled)
        }
    }
}
