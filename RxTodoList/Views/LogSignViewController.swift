import RxCocoa
import RxSwift
import UIKit

class LogSignViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var viewModel: LogSignViewModel?
    
    private let bag = DisposeBag()
    
    var onDismiss: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = viewModel?.titleString
        loginButton.setTitle(viewModel?.logsignButtonString, for: .normal)
        warningLabel.text = viewModel?.warningString
        
        loginButton.rx
            .tap
            .subscribe { [weak self] _ in
                self?.logsignTapped()
            }
            .disposed(by: bag)
        
        cancelButton.rx
            .tap
            .subscribe { [weak self] _ in
                self?.cancelTapped()
            }
            .disposed(by: bag)
    }
    
    func logsignTapped() {
        dismiss(animated: true, completion: onDismiss)
    }
    
    func cancelTapped() {
        dismiss(animated: true)
    }

}
