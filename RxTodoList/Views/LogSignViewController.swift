import RxCocoa
import RxSwift
import UIKit

final class LogSignViewController: UIViewController, ViewModeled {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var viewModel: LogSignViewModel?
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let viewModel = viewModel else {
            assertionFailure("Could not set View Model")
            return
        }
        
        viewModel.warningString
            .bind(to: warningLabel.rx.text)
            .disposed(by: bag)
        
        viewModel.warningString
            .flatMap { BehaviorSubject<Bool>(value: $0.isEmpty) }
            .bind(to: warningLabel.rx.isHidden)
            .disposed(by: bag)
        
        loginButton.rx
            .tap
            .subscribe { [weak self] _ in
                self?.loginTapped()
            }
            .disposed(by: bag)
        
        signupButton.rx
            .tap
            .subscribe { [weak self] _ in
                self?.signupTapped()
            }
            .disposed(by: bag)
        
        cancelButton.rx
            .tap
            .subscribe { [weak self] _ in
                self?.cancelTapped()
            }
            .disposed(by: bag)
    }
    
    func loginTapped() {
        backLoggedSigned()
    }
    
    func signupTapped() {
        backLoggedSigned()
    }
    
    func cancelTapped() {
        back()
    }

}

extension LogSignViewController: BackwardRoutable {
    
    func back() {
        dismiss(animated: true)
    }
    
    func backLoggedSigned() {
        defer { back() }
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
              let rootViewController = sceneDelegate.window?.rootViewController as? UITabBarController else {
            assertionFailure("Could not set Root View Controller")
            return
        }
        rootViewController.prepareForRestart()
    }

}
