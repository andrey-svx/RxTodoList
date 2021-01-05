import Foundation
import RxSwift

class User {
    
    let loginDetails = PublishSubject<LoginDetails?>()
    let todos = PublishSubject<[Todo]>()
    
    private var _loginDetails: LoginDetails? {
        didSet { loginDetails.onNext(oldValue) }
    }
    
    private var _todos: [Todo] {
        didSet { todos.onNext(oldValue) }
    }
    
    init() {
        self._loginDetails = nil
        self._todos = []
    }
    
    #if DEBUG
    deinit {
        print("model deinited!")
    }
    #endif
    
}
