import Foundation
import RxRelay
import RxSwift

class ListViewModel {
    
    let todos = BehaviorRelay<[String]>(value: ["Clean the apt", "Learn to code", "Call mom", "Do the workout", "Call customers"])
    
    func editTodo(text: String, at index: Int) {
        if !text.isEmpty {
            var todos = self.todos.value
            todos[index] = text
            self.todos.accept(todos)
        } else {
            var todos = self.todos.value
            todos.remove(at: index)
            self.todos.accept(todos)
        }
    }

    func appendTodo(text: String) {
        if !text.isEmpty {
            var todos = self.todos.value
            todos.append(text)
            self.todos.accept(todos)
        }
    }
    
    func instantiateEditItemViewModel(at index: Int) -> ItemViewModel {
        let todo = todos.value[index]
        return ItemViewModel(itemTitle: todo)
    }
    
}
