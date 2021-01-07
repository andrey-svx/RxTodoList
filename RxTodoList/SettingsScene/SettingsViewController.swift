import RxCocoa
import RxSwift
import UIKit

final class SettingsViewController: UIViewController, Routable {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewModel = SettingsViewModel(
            logoutTap: logoutButton.rx
                .tap
                .asSignal(),
            loginTap: loginButton.rx
                .tap
                .asSignal(),
            signupTap: signupButton.rx
                .tap
                .asSignal()
        )
        
        viewModel.title
            .drive(titleLabel.rx.text)
            .disposed(by: bag)
        
        viewModel.logoutIsEnabled
            .drive(logoutButton.rx.isEnabled)
            .disposed(by: bag)
        
        viewModel.loginIsEnabled
            .drive(loginButton.rx.isEnabled)
            .disposed(by: bag)
        
        viewModel.signupIsEnabled
            .drive(signupButton.rx.isEnabled)
            .disposed(by: bag)
        
    }
    
}
