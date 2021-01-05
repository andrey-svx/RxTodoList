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
        setupTextFields(viewModel)
        setupWarningLabel(viewModel)
        setupButtons()
    }
    
    private func setupTextFields(_ viewModel: LogSignViewModel) {
        usernameField.rx
            .text
            .flatMap { BehaviorSubject<String>(value: $0 == nil ? "" : $0!) }
            .bind(to: viewModel.usernameInput)
            .disposed(by: bag)
        
        passwordField.rx
            .text
            .flatMap { BehaviorSubject<String>(value: $0 != nil ? $0! : "") }
            .bind(to: viewModel.passwordInput)
            .disposed(by: bag)
    }
    
    private func setupWarningLabel(_ viewModel: LogSignViewModel) {
        viewModel.warningString
            .bind(to: warningLabel.rx.text)
            .disposed(by: bag)
        
        viewModel.warningString
            .flatMap { BehaviorSubject<Bool>(value: $0.isEmpty) }
            .bind(to: warningLabel.rx.isHidden)
            .disposed(by: bag)
    }
    
    private func setupButtons() {
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
    
}

extension LogSignViewController {
    
    private func loginTapped() {
        back()
    }
    
    private func signupTapped() {
        back()
    }
    
    private func cancelTapped() {
        back()
    }

}

extension LogSignViewController: Routable { }
