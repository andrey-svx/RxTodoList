import Foundation
import RxRelay
import RxSwift

final class ListViewModel: ViewModel {
    
    private let todoList = TodoList()
    
    var todos: BehaviorRelay<[Todo]> { todoList.todos }
    
    func updateTodo(text: String, at index: Int) {
        if !text.isEmpty {
            todoList.editTodo(text: text, at: index)
        } else {
            todoList.deleteTodo(at: index)
        }
    }

    func appendTodo(text: String) {
        if !text.isEmpty {
            todoList.appendTodo(text: text)
        }
    }
    
    func instantiateItemViewModel(forItemAt index: Int) -> ItemViewModel {
        let todo = todos.value[index]
        return ItemViewModel(itemTitle: todo.name)
    }
    
}
