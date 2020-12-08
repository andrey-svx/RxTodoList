import RxSwift
import UIKit

final class ItemViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    private lazy var cancelButton: UIBarButtonItem = { [weak self] in
        self?.navigationItem.setHidesBackButton(true, animated: false)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
        self?.navigationItem.leftBarButtonItem = cancelButton
        return cancelButton
    }()
    
    var viewModel: ItemViewModel?
    
    lazy var item: BehaviorSubject<String> = { [weak self] in
        guard let item = self?.viewModel?.item else {
            assertionFailure("Item VM has not been set!")
            return BehaviorSubject<String>(value: "")
        }
        return item
    }()
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let viewModel = viewModel else {
            assertionFailure("Item VM has not been set!")
            return
        }
        setupTextField(viewModel)
        setupButtons(viewModel)
    }
    
    private func setupTextField(_ viewModel: ItemViewModel) {
        if viewModel.forEditing,
           let value = try? viewModel.item.value() {
            textField.text = value
        } else {
            textField.placeholder = "Type todo item here"
        }
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
    
    func saveTapped(_ viewModel: ItemViewModel) {
        let item = viewModel.item
        item.onNext(textField.text ?? "")
        navigationController?.popViewController(animated: true)
    }
    
    func cancelTapped(_ viewModel: ItemViewModel) {
        let item = viewModel.item
        item.onError(TextInputError.cancelled)
        navigationController?.popViewController(animated: true)
    }
    
}

enum TextInputError: Error {
    
    case cancelled

}
