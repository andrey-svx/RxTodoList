import RxCocoa
import RxSwift
import UIKit

final class LogSignViewController: UIViewController, Routable {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var logsignButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewModel = LogSignViewModel(
            usernameInput: usernameField.rx
                .textInput
                .text
                .asDriver(),
            passwordInput: passwordField.rx
                .textInput
                .text
                .asDriver(),
            logsignTap: logsignButton.rx
                .tap
                .asSignal(),
            dismissTap: dismissButton.rx
                .tap
                .asSignal()
        )
        
        viewModel.warningIsHidden
            .drive(warningLabel.rx.isHidden)
            .disposed(by: bag)
        viewModel.warning
            .drive(warningLabel.rx.text)
            .disposed(by: bag)
    }
    
}
