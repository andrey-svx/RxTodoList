import Foundation
import RxSwift
import RxCocoa

final class ListViewModel {
    
    let todos: Driver<[LocalTodo]>
    
    let destination: Observable<Destination>
    
    init(
        addTap: Signal<()>,
        selectTap: Signal<LocalTodo>
    ) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let user = appDelegate.model
        
        self.todos = user.todos
            .asDriver(onErrorJustReturn: [])
        
        let addTapObservable = addTap.asObservable()
            .do(onNext: { [unowned user] _ in
                user.setForInserting()
            })
            .map { _ in Destination.route }
            .share()
        
        let selectTapObservable = selectTap.asObservable()
            .do(onNext: { [unowned user] todo in
                user.setForEdititng(todo)
            })
            .map { _ in Destination.route }
            .share()
        
        self.destination = Observable.of(addTapObservable, selectTapObservable)
            .merge()
    }
    
}
