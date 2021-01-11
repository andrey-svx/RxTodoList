import Foundation
import RxSwift
import RxRelay
import RxCocoa

final class ListViewModel: ViewModel {
    
    let todos: Driver<[Todo]>
    
    let destination: Observable<Destination>
    
    init(
        addTap: Signal<()>,
        selectTap: Signal<Todo>
    ) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let user = appDelegate.user
        
        self.todos = user.todos
            .asDriver(onErrorJustReturn: [])
        
        let addTapObservable = addTap.asObservable()
            .do(onNext: { [unowned user] _ in
                user.appendEdit = user.appendTodo
                user.setEdited(user.newTodo())
            })
            .map { _ in Destination.route }
            .share()
        
        let selectTapObservable = selectTap.asObservable()
            .do(onNext: { [unowned user] todo in
                user.appendEdit = user.editTodo
                user.setEdited(todo)
            })
            .map { _ in Destination.route }
            .share()
        
        self.destination = Observable.of(addTapObservable, selectTapObservable)
            .merge()
    }
    
}
