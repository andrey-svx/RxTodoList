import RxCocoa
import RxSwift
import UIKit

final class SettingsViewController: UIViewController, Routable {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    var state: State?
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
//                self?.route(to: LogSignViewController.self, with: State)
            }
            .disposed(by: bag)
    }
    
}
