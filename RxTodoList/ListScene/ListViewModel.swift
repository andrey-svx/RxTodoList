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
            .do(onNext: { [weak user] _ in user?.setEdited(Todo()) })
            .map { _ in Destination.route }
        
        let selectTapObservable = selectTap.asObservable()
            .do(onNext: { [weak user] todo in user?.setEdited(todo) })
            .map { _ in Destination.route }
        
        self.destination = Observable.of(addTapObservable, selectTapObservable)
            .merge()
    }
    
}
