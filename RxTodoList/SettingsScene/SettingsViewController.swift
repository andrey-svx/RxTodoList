import RxCocoa
import RxSwift
import UIKit

final class SettingsViewController: UIViewController, Routable {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
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
        viewModel.destination
            .observeOn(MainScheduler.instance)
            .bind { [weak self] destination in self?.route(to: LogSignViewController.self) }
            .disposed(by: bag)
        viewModel.isBusy
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: bag)
        
    }
    
    @IBAction func upload(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let model = appDelegate.model
        let todo = LocalTodo("test-todo", id: UUID(), date: Date(), objectID: nil)
        model
            .upload([todo, todo, todo])
            .bind(onNext: { print("UPLOADED!") })
            .disposed(by: bag)
    }
    
    @IBAction func download(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let model = appDelegate.model
        model
            .download()
            .bind(onNext: {
                $0.forEach { print($0) }
            })
            .disposed(by: bag)
    }
    
}
