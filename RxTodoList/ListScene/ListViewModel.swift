import Foundation
import RxSwift
import RxRelay
import RxCocoa

final class ListViewModel: ViewModel {
    
    enum Destination {
        case dummy
    }
    
    let todos: Driver<[Todo]>
    let destination: Observable<Destination>
    
    init(
        addTaps: Signal<Todo?>,
        selectTaps: Signal<Todo?>
    ) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let user = appDelegate.user
        
        self.todos = user.todos
            .asDriver(onErrorJustReturn: [])
        
        self.destination = Observable.of(addTaps, selectTaps)
            .merge()
            .do(onNext: { [weak user] item in user?.setEdited(item ?? Todo()) })
            .map {  _ -> Destination in Destination.dummy }
    }
    
}
