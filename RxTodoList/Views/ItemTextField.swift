//
//  ItemTextField.swift
//  RxTodoList
//
//  Created by Андрей Исаев on 09.12.2020.
//

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
