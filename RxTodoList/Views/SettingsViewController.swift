import RxCocoa
import RxSwift
import UIKit

final class SettingsViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoutButton.rx
            .tap
            .subscribe { [weak self] _ in
                self?.presentLoginSugnupViewController(LoginViewModel())
            }
            .disposed(by: bag)
    }
    
    func presentLoginSugnupViewController(_ viewModel: LogSignViewModel) {
        guard let logSignViewController = storyboard?.instantiateViewController(withIdentifier: "LogSignViewController") as? LogSignViewController else { return }
        logSignViewController.viewModel = viewModel
        logSignViewController.completion = tabBarController?.prepareForRestart
        present(logSignViewController, animated: true, completion: nil)
    }

}
