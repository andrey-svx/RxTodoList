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
        let viewModel = SettingsViewModel()
        viewModel.title
            .drive(titleLabel.rx.text)
            .disposed(by: bag)
        
    }
    
}
