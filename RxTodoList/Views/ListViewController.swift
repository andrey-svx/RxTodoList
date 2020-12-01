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
            .flatMap { [unowned self] todo -> Observable<(String, Int)> in
                let indexPath = self.tableView.indexPathForSelectedRow!
                let index = indexPath.row
                let viewModel = self.viewModel.instantiateItemViewModel(forItemAt: index)
                return self.pushItemViewController(with: viewModel)
                    .flatMap { BehaviorSubject<(String, Int)>(value: ($0, index)) }
            }
            .retry()
            .subscribe(onNext: { [unowned self] (value, index) in
                self.viewModel.updateTodo(text: value, at: index)
            })
            .disposed(by: bag)
    }
    
    private func setupPlusButton(_ viewModel: ListViewModel) {
        plusBarButtonItem.rx
            .tap
            .flatMap { [unowned self] _ -> Observable<String> in
                let viewModel = ItemViewModel()
                return self.pushItemViewController(with: viewModel)
            }
            .retry()
            .subscribe(onNext: { [unowned self] event in
                self.viewModel.appendTodo(text: event)
            })
            .disposed(by: bag)
    }
    
}

extension ListViewController {
    
    private func pushItemViewController(with viewModel: ItemViewModel) -> Observable<String> {
        guard let itemViewController = storyboard?.instantiateViewController(identifier: "ItemViewController") as? ItemViewController else {
            return BehaviorSubject<String>(value: ("Empty"))
        }
        itemViewController.viewModel = viewModel
        guard let item = itemViewController.viewModel?.item else {
            assertionFailure("Item VM has not been set!")
            return BehaviorSubject<String>(value: ("Empty"))
        }
        navigationController?.pushViewController(itemViewController, animated: true)
        
        return item
    }

}
