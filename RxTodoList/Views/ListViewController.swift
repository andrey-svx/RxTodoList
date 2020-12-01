import RxCocoa
import RxRelay
import RxSwift
import UIKit

final class ListViewController: UITableViewController {
    
    @IBOutlet weak var plusButton: UIBarButtonItem!
    
    private let viewModel = ListViewModel()
    private let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "RxTodoList"
        setupTableView()
        setupButton()
    }
    
    func setupTableView() {
        tableView.dataSource = nil
        tableView.delegate = nil
        
        viewModel.todos
            .bind(to: tableView.rx.items) { (tableView, row, element) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell")!
                cell.textLabel?.text = "\(row + 1). \(element)"
                return cell
            }
            .disposed(by: bag)
        
        tableView.rx
            .modelSelected(String.self)
            .subscribe(onNext: { [weak self] todo in
                guard let indexPath = self?.tableView.indexPathForSelectedRow else { return }
                self?.pushItemViewController(forItemAt: indexPath)
            })
            .disposed(by: bag)
    }
    
    func setupButton() {
        plusButton.rx
            .tap.bind { [weak self] _ in
                self?.pushItemViewControllerToAppend()
            }
            .disposed(by: bag)
    }
    
}

extension ListViewController {
    
    private func pushItemViewControllerToAppend() {
        guard let itemViewController = storyboard?.instantiateViewController(identifier: "ItemViewController") as? ItemViewController else { return }
        itemViewController.viewModel = ItemViewModel()
        guard let item = itemViewController.viewModel?.item else { assertionFailure("Item VM has not been set!"); return }
        item
            .subscribe(onNext: { [weak self] event in
                self?.viewModel.appendTodo(text: event)
            }, onError: { error in
                print(error)
            })
            .disposed(by: bag)
        
        navigationController?.pushViewController(itemViewController, animated: true)
    }

    private func pushItemViewController(forItemAt indexPath: IndexPath) {
        guard let itemViewController = storyboard?.instantiateViewController(identifier: "ItemViewController") as? ItemViewController else { return }
        let index = indexPath.row
        itemViewController.viewModel = self.viewModel.instantiateEditItemViewModel(at: index)
        guard let item = itemViewController.viewModel?.item else { assertionFailure("Item VM has not been set!"); return }
        
        item
            .subscribe(
                onNext: { [weak self] event in
                    self?.viewModel.editTodo(text: event, at: index)
                },
                onError: { error in
                    print(error)
                })
            .disposed(by: bag)
        
        navigationController?.pushViewController(itemViewController, animated: true)
    }

}
