import Foundation
import RxSwift
import CoreData

class PersistenceClient {
    
    private lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.context
    }()
    
    func fetchTodos() -> Observable<[Todo]> {
        let request = CDTodo.fetchRequest() as NSFetchRequest<CDTodo>
        let sorter = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sorter]
        request.returnsObjectsAsFaults = false
        return context.rx
            .fetch(request)
            .map { $0.map { Todo($0.name, id: $0.id, date: $0.date, objectID: $0.objectID) } }
    }
    
    func fetchTodo(_ todo: Todo) -> Observable<Todo?> {
        let request = CDTodo.fetchRequest() as NSFetchRequest<CDTodo>
        let predicate = NSPredicate(format: "id CONTAINS %@", "\(todo.id)")
        request.predicate = predicate
        return context.rx
            .fetch(request)
            .map { cdTodos -> Todo? in
                if let cdTodo = cdTodos.first {
                    return Todo(cdTodo.name, id: cdTodo.id, date: cdTodo.date, objectID: cdTodo.objectID)
                } else {
                    return nil
                }
            }
    }
    
    func removeTodo(_ todo: Todo) -> Observable<Void> {
        guard let objectID = todo.objectID else { return Observable<Void>.error(Error.some) }
        let cdTodo = context.object(with: objectID)
        return context.rx
            .delete(cdTodo)
            .flatMap(context.rx.save)
    }
    
    func appendTodo(_ todo: Todo) -> Observable<Void> {
        let cdTodo = CDTodo(context: context)
        cdTodo.name = todo.name
        cdTodo.id = todo.id
        cdTodo.date = todo.date
    
        return context.rx
            .insert(cdTodo)
            .flatMap(context.rx.save)
    }
    
    func editTodo(_ todo: Todo, with editedTodo: Todo) -> Observable<Void> {
        Observable.just(())
    }
    
    enum Error: Swift.Error {
        case some
    }
    
}
