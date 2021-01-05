import Foundation
import RxSwift
import RxRelay
import RxCocoa

final class ListViewModel: ViewModel {
    
    let todos: Driver<[Todo]>
    
    init(
        addTaps: Signal<()>,
        selectTaps: Signal<Todo>
    ) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let user = appDelegate.user
        user.prepare()
        
        self.todos = user.todos
            .asDriver(onErrorJustReturn: [])
        
    }
    
    #if DEBUG
    deinit {
        print("List view model deinited!")
    }
    #endif

}
