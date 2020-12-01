import RxCocoa
import RxRelay
import RxSwift
import UIKit

final class ListViewController: UITableViewController {
    
    @IBOutlet weak var plusBarButtonItem: UIBarButtonItem!
    
    private let viewModel = ListViewModel()
    private let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "RxTodoList"
        setupTableView(viewModel)
        setupPlusButton(viewModel)
    }
    
    private func setupTableView(_ viewModel: ListViewModel) {
        tableView.dataSource = nil
        tableView.delegate = nil
        
        viewModel.todos
            .bind(to: tableView.rx.items) { (tableView, row, element) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell")!
                cell.textLabel?.text = "\(row + 1). \(element.name)"
                return cell
            }
            .disposed(by: bag)
        
        tableView.rx
            .modelSelected(Todo.self)
            .subscribe(onNext: { [weak self] todo in
                guard let indexPath = self?.tableView.indexPathForSelectedRow else { return }
                self?.pushItemViewController(forItemAt: indexPath)
            })
            .disposed(by: bag)
    }
    
    private func setupPlusButton(_ viewModel: ListViewModel) {
        plusBarButtonItem.rx
            .tap
            .flatMap { [unowned self] _ -> Observable<String> in
                self.pushItemViewControllerToAppend()
            }
            .retry()
            .subscribe(
                onNext: { [unowned self] event in
                    self.viewModel.appendTodo(text: event)
                },
                onError: { error in
                    print(error)
                }
            )
            .disposed(by: bag)
    }
    
}

extension ListViewController {
    
    private func pushItemViewControllerToAppend() -> Observable<String> {
        guard let itemViewController = storyboard?.instantiateViewController(identifier: "ItemViewController") as? ItemViewController else {
            return BehaviorSubject<String>(value: "Empty")
        }
        itemViewController.viewModel = ItemViewModel()
        guard let item = itemViewController.viewModel?.item else {
            assertionFailure("Item VM has not been set!")
            return BehaviorSubject<String>(value: "Empty")
        }
        navigationController?.pushViewController(itemViewController, animated: true)
        return item
    }

    private func pushItemViewController(forItemAt indexPath: IndexPath) {
        guard let itemViewController = storyboard?.instantiateViewController(identifier: "ItemViewController") as? ItemViewController else { return }
        let index = indexPath.row
        itemViewController.viewModel = self.viewModel.instantiateItemViewModel(forItemAt: index)
        guard let item = itemViewController.viewModel?.item else { assertionFailure("Item VM has not been set!"); return }
        
        item
            .subscribe(
                onNext: { [weak self] event in
                    self?.viewModel.updateTodo(text: event, at: index)
                }
            )
            .disposed(by: bag)
        
        navigationController?.pushViewController(itemViewController, animated: true)
    }

}
