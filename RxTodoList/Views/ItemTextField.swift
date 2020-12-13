import UIKit

final class ItemTextField: UITextField {
    
    func configure(with viewModel: ItemViewModel) {
        if viewModel.forEditing,
           let value = try? viewModel.itemInput.value() {
            text = value
        } else {
            placeholder = "Type todo item here"
        }
    }

}
