import Foundation
import RxRelay
import RxSwift

final class ListViewModel: ViewModel {
    
    private var user: User { (UIApplication.shared.delegate as! AppDelegate).user }
    private var userSubject = BehaviorSubject<User>(value: User())
    
    let todos = BehaviorSubject<[Todo]>(value: [])
    private let bag = DisposeBag()
    
    init() {
        userSubject
            .subscribe { [weak self] (user: User) in
                self?.todos.onNext(user.getTodos())
            }
            .disposed(by: bag)
    }
    
    func updateTodo(text: String, at index: Int) {
        if !text.isEmpty {
            user.editTodo(at: index, with: text)
        } else {
            user.deleteTodo(at: index)
        }
        userSubject.onNext(user)
    }

    func appendTodo(text: String) {
        if !text.isEmpty {
            user.appendTodo(text: text)
        }
        userSubject.onNext(user)
    }
    
    func instantiateItemViewModel(forItemAt index: Int) -> ItemViewModel {
        let todo = user.getTodos()[index]
        return ItemViewModel(itemTitle: todo.name)
    }

}
