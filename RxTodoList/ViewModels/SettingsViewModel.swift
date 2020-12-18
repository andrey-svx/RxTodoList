import Foundation
import RxSwift

class SettingsViewModel: ViewModel {
    
    private var user: User { (UIApplication.shared.delegate as! AppDelegate).user }
    private var userSubject = BehaviorSubject<User>(value: User())
    
    let username = BehaviorSubject<String>(value: "")
    let titleString = BehaviorSubject<String>(value: "Logged in as %username")
    
    private let bag = DisposeBag()
    
    init() {
        userSubject
            .subscribe { [weak self] (user: User) in
                guard let username = user.getDetails()?.username else { return }
                self?.username.onNext(username)
            }
            .disposed(by: bag)
    }
    
    func logout() {
        user.logout()
    }
    
}
