import RxCocoa
import RxSwift
import UIKit

final class LogSignViewController: UIViewController, Routable {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var logsignButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewModel = LogSignViewModel(
            usernameInput: usernameField.rx
                .textInput
                .text
                .map { $0 ?? "" }
                .asDriver(onErrorJustReturn: ""),
            passwordInput: passwordField.rx
                .textInput
                .text
                .map { $0 ?? "" }
                .asDriver(onErrorJustReturn: ""),
            logsignTap: logsignButton.rx
                .tap
                .asSignal(),
            dismissTap: dismissButton.rx
                .tap
                .asSignal()
        )
        
//        viewModel.email
//            .drive(usernameField.rx.text)
//            .disposed(by: bag)
//        viewModel.password
//            .drive(passwordField.rx.text)
//            .disposed(by: bag)
        viewModel.warning
            .map { $0.isEmpty }
            .drive(warningLabel.rx.isHidden)
            .disposed(by: bag)
        viewModel.warning
            .drive(warningLabel.rx.text)
            .disposed(by: bag)
        viewModel.isBusy
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: bag)
        viewModel.destination
            .observeOn(MainScheduler.instance)
            .bind { [weak self] destination in self?.back() }
            .disposed(by: bag)
    }
    
}
