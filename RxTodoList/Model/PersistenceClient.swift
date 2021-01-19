import Foundation
import RxSwift
import CoreData

struct PersistenceClient {
    
    typealias PCFetchResult = Result<[LocalTodo], Self.Error>
    typealias PCRemoveResult = Result<Void, Self.Error>
    typealias PCInsertOneResult = Result<NSManagedObjectID, Self.Error>
    typealias PCInsertManyResult = Result<[(UUID, NSManagedObjectID)], Self.Error>
    
    private lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.context
    }()
    
    mutating func fetchAllTodos() -> Observable<PCFetchResult> {
        let request = StoredTodo.fetchRequest() as NSFetchRequest<StoredTodo>
        let sorter = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sorter]
        request.returnsObjectsAsFaults = false
        return context.rx
            .fetch(request)
            .map { storedTodos -> [LocalTodo] in
                storedTodos
                    .map { LocalTodo($0.name, id: $0.id, date: $0.date, objectID: $0.objectID) }
            }
            .map { .success($0) }
            .catchErrorJustReturn(.failure(.unknown))
    }
    
    mutating func remove(todo: LocalTodo) -> Observable<PCRemoveResult> {
        guard let objectID = todo.objectID else { return Observable.just(.failure(.unknown)) }
        let cdTodo = context.object(with: objectID)
        return context.rx
            .delete(cdTodo)
            .flatMap(context.rx.save)
            .map { .success(()) }
            .catchErrorJustReturn(.failure(.unknown))
    }
    
    mutating func removeAllTodos() -> Observable<PCRemoveResult> {
        return context.rx
            .deleteAll(StoredTodo.self)
            .map { .success(()) }
            .catchErrorJustReturn(.failure(.unknown))
    }
    
    mutating func insert(todo: LocalTodo) -> Observable<PCInsertOneResult> {
        let storedTodo = StoredTodo(context: context)
        storedTodo.name = todo.name
        storedTodo.id = todo.id
        storedTodo.date = todo.date
    
        return context.rx
            .insert(storedTodo)
            .flatMap(context.rx.save)
            .map { .success(storedTodo.objectID) }
            .catchErrorJustReturn(.failure(.unknown))
    }
    
    mutating func insert(todos: [LocalTodo]) -> Observable<PCInsertManyResult> {
        let storedTodos = todos
            .map { todo -> StoredTodo in
                let storedTodo = StoredTodo(context: context)
                storedTodo.name = todo.name
                storedTodo.id = todo.id
                storedTodo.date = todo.date
                return storedTodo
            }
        
        return context.rx
            .insert(storedTodos)
            .map { 
                let ids = todos.map { $0.id }
                let objectIDs = storedTodos.map { $0.objectID }
                let idsTuple = zip(ids, objectIDs)
                    .compactMap { $0 }
                return .success(idsTuple)
            }
            .catchErrorJustReturn(.failure(.unknown))
    }
    
    enum Error: Swift.Error {
        
        case unknown
    
    }
    
}
