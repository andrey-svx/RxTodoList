import RxSwift
import UIKit

final class ItemViewController: UIViewController, ViewModeled {

    @IBOutlet weak var textField: ItemTextField!
    @IBOutlet weak var saveButton: UIButton!
    private lazy var cancelButton: UIBarButtonItem = { [weak self] in
        self?.navigationItem.setHidesBackButton(true, animated: false)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
        self?.navigationItem.leftBarButtonItem = cancelButton
        return cancelButton
    }()
    
    var viewModel: ItemViewModel?

    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let viewModel = viewModel else {
            assertionFailure("Could not set Item VM!"); return
        }
        setupTextField(viewModel)
        setupButtons(viewModel)
    }
    
    private func setupTextField(_ viewModel: ItemViewModel) {
        textField.configure(with: viewModel)
        textField.rx.text
            .flatMap { BehaviorSubject<String>(value: $0 ?? "") }
            .bind(to: viewModel.itemInput)
            .disposed(by: bag)
        textField.becomeFirstResponder()
    }
    
    private func setupButtons(_ viewModel: ItemViewModel) {
        saveButton.rx
            .tap
            .bind(onNext: { [weak self] _ in
                guard let viewModel = self?.viewModel else { return }
                self?.saveTapped(viewModel)
            })
            .disposed(by: bag)
        
        cancelButton.rx
            .tap
            .bind(onNext: { [weak self] _ in
                guard let viewModel = self?.viewModel else { return }
                self?.cancelTapped(viewModel)
            })
            .disposed(by: bag)
    }
    
    private func saveTapped(_ viewModel: ItemViewModel) {
        viewModel.saveItem()
        back()
    }
    
    private func cancelTapped(_ viewModel: ItemViewModel) {
        viewModel.cancelItem()
        back()
    }
    
}

extension ItemViewController: Routable { }
