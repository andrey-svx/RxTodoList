import RxCocoa
import RxRelay
import RxSwift
import UIKit

final class ListViewController: UITableViewController {

    @IBOutlet weak var plusBarButtonItem: UIBarButtonItem!
    
    private var viewModel = ListViewModel()
    private let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "RxTodoList"
        setupTableView(viewModel)
        setupPlusButton(viewModel)
    }
    
    private func setupTableView(_ viewModel: ListViewModel) {
        setupCellForRowAt(viewModel)
        setupDidSelectRowAt(viewModel)
    }
    
    private func setupCellForRowAt(_ viewModel: ListViewModel) {
        tableView.dataSource = nil
        viewModel.todos
            .bind(to: tableView.rx.items) { (tableView, row, element) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell")!
                cell.textLabel?.text = "\(row + 1). \(element.name)"
                return cell
            }
            .disposed(by: bag)
    }
    
    private func setupDidSelectRowAt(_ viewModel: ListViewModel) {
        tableView.delegate = nil
        tableView.rx
            .modelSelected(Todo.self)
            .flatMap { [unowned self] todo -> Observable<(String, Int)> in
                let indexPath = self.tableView.indexPathForSelectedRow!
                let index = indexPath.row
                let viewModel = self.viewModel.instantiateItemViewModel(forItemAt: index)
                return self.instantiateItemViewController(viewModel) { [unowned self] itemViewController in
                    navigationController?.pushViewController(itemViewController, animated: true)
                }
                .item
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
            .flatMap { [unowned self] hello -> Observable<String> in
                print(hello)
                let viewModel = ItemViewModel()
                return self.instantiateItemViewController(viewModel) { [unowned self] itemViewController in
                    navigationController?.pushViewController(itemViewController, animated: true)
                }
                .item
            }
            .retry()
            .subscribe(onNext: { [unowned self] event in
                self.viewModel.appendTodo(text: event)
            })
            .disposed(by: bag)
    }
    
}

extension ListViewController {
    
    private func instantiateItemViewController(_ viewModel: ItemViewModel, completion: @escaping (UIViewController) -> Void) -> ItemViewController {
        guard let itemViewController = storyboard?.instantiateViewController(identifier: "ItemViewController") as? ItemViewController else {
            return ItemViewController()
        }
        itemViewController.viewModel = viewModel
        completion(itemViewController)
        return itemViewController
    }

}
