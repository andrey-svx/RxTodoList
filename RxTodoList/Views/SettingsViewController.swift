import RxCocoa
import RxSwift
import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.rx
            .tap
            .subscribe { [weak self] _ in
                guard let logSignViewController = self?.storyboard?.instantiateViewController(withIdentifier: "LogSignViewController") as? LogSignViewController else { return }
                self?.present(logSignViewController, animated: true, completion: nil)
            }
            .disposed(by: bag)
        
        signupButton.rx
            .tap
            .subscribe { [weak self] _ in
                guard let logSignViewController = self?.storyboard?.instantiateViewController(withIdentifier: "LogSignViewController") as? LogSignViewController else { return }
                self?.present(logSignViewController, animated: true, completion: nil)
            }
            .disposed(by: bag)
    }

}
