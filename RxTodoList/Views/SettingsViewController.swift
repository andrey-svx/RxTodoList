import RxCocoa
import RxSwift
import UIKit

final class SettingsViewController: UIViewController, ViewModeled {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    var viewModel: SettingsViewModel? = SettingsViewModel()
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let viewModel = viewModel else {
            assertionFailure("Could not set View Model")
            return
        }
        
        viewModel.titleString
            .bind(to: titleLabel.rx.text)
            .disposed(by: bag)
        
        logoutButton.rx
            .tap
            .subscribe { [weak self] _ in
                viewModel.logOut()
                let logSignViewModel = LogSignViewModel()
                self?.route(to: LogSignViewController.self, with: logSignViewModel)
            }
            .disposed(by: bag)
    }
    
}

extension SettingsViewController: Routable { }
