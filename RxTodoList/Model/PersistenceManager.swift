import Foundation
import RxSwift
import CoreData

struct PersistenceManager {
    
    typealias PMFetchResult = Result<[LocalTodo], Error>
    typealias PMRemoveResult = Result<Void, Error>
    typealias PMInsertOneResult = Result<NSManagedObjectID, Error>
    typealias PMInsertManyResult = Result<[(UUID, NSManagedObjectID)], Error>
    
    let context: NSManagedObjectContext
    
    let queue = DispatchQueue(label: "LocalSerialQueue")
    
    init(_ context: NSManagedObjectContext) {
        
        self.context = context
    
    }
    
    mutating func fetchAllTodos() -> Observable<PMFetchResult> {
        let request = StoredTodo.fetchRequest() as NSFetchRequest<StoredTodo>
        let sorter = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sorter]
        request.returnsObjectsAsFaults = false
        return context.rx
            .fetch(request, on: queue)
            .map { storedTodos -> [LocalTodo] in
                storedTodos
                    .map { LocalTodo($0.name, id: $0.id, date: $0.date, objectID: $0.objectID) }
            }
            .map { .success($0) }
            .catchErrorJustReturn(.failure(.unknown))
    }
    
    mutating func remove(todo: LocalTodo) -> Observable<PMRemoveResult> {
        guard let objectID = todo.objectID else { return Observable.just(.failure(.unknown)) }
        let cdTodo = context.object(with: objectID)
        return context.rx
            .deleteAndSave(cdTodo, on: queue)
            .map { .success(()) }
            .catchErrorJustReturn(.failure(.unknown))
    }
    
    mutating func removeAllTodos() -> Observable<PMRemoveResult> {
        return context.rx
            .deleteAll(StoredTodo.self)
            .map { .success(()) }
            .catchErrorJustReturn(.failure(.unknown))
    }
    
    mutating func insert(todo: LocalTodo) -> Observable<PMInsertOneResult> {
        let storedTodo = StoredTodo(context: context)
        storedTodo.name = todo.name
        storedTodo.id = todo.id
        storedTodo.date = todo.date
        
        return context.rx
            .save(on: queue)
            .map { _ in .success(storedTodo.objectID) }
            .catchErrorJustReturn(.failure(.unknown))
    }
    
    mutating func insert(todos: [LocalTodo]) -> Observable<PMInsertManyResult> {
        let storedTodos = todos
            .map { todo -> StoredTodo in
                let storedTodo = StoredTodo(context: context)
                storedTodo.name = todo.name
                storedTodo.id = todo.id
                storedTodo.date = todo.date
                return storedTodo
            }
        
        return context.rx
            .save(on: queue)
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
