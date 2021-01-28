import Foundation
import CoreData
import RxSwift

extension Reactive where Base: NSManagedObjectContext {
    
    /**
    Reactive wrapper for CoreData NSAsynchronousFetchRequest
    
    - parameter request: Standard NSFetchRequest used in CoreData
    - parameter queue: Serial DispatchQueue to protect data from corruption by several read/write operations
    - returns: Observable array of fetch result
     */
    
    func fetch<T>(
        _ request: NSFetchRequest<T>,
        on queue: DispatchQueue = DispatchQueue(label: "LocalSerialQueue")
    ) -> Observable<[T]> {
        Observable.create { observer -> Disposable in
            let asyncRequest = NSAsynchronousFetchRequest(fetchRequest: request) { result in
                queue.sync {
                    observer.onNext(result.finalResult ?? [])
                    observer.onCompleted()
                }
            }
            
            do {
                try self.base.execute(asyncRequest)
            } catch {
                observer.onError(NSManagedObjectContext.ReactiveError.fetch)
            }
            
            return Disposables.create()
        }
    }
    
    /**
    Reactive wrapper for CoreData save() operation
    
    - parameter queue: Serial DispatchQueue to protect data from corruption by several read/write operations
    - returns: Observable array of save result. Type Void used for bind(onNext:) compatibility
     */
    
    func save(
        on queue: DispatchQueue = DispatchQueue(label: "LocalSerialQueue")
    ) -> Observable<Void> {
        guard base.hasChanges else { return Observable.just(()) }
        return Observable.create { observer -> Disposable in
                self.base.perform {
                    queue.sync {
                        do {
                            try self.base.save()
                            observer.onNext(())
                            observer.onCompleted()
                        } catch {
                            observer.onError(NSManagedObjectContext.ReactiveError.save)
                        }
                    }
                }
            return Disposables.create()
        }
    }
    
    /**
    Reactive wrapper for CoreData delete(_ object: NSManagedObject) and save() operations performed serially
    
    - parameter object: Object inheriting from NSManagedObject
    - parameter queue: Serial DispatchQueue to protect data from corruption by several read/write operations
    - returns: Observable of delete and save result. Type Void used for bind(onNext:) compatibility
     */
    
    func deleteAndSave<T: NSManagedObject>(
        _ object: T,
        on queue: DispatchQueue = DispatchQueue(label: "LocalSerialQueue")
    ) -> Observable<Void> {
        Observable.create { observer -> Disposable in
                self.base.perform {
                    queue.sync {
                        do {
                            self.base.delete(object)
                            try self.base.save()
                            observer.onNext(())
                            observer.onCompleted()
                        } catch {
                            observer.onError(NSManagedObjectContext.ReactiveError.save)
                        }
                    }
            }
            return Disposables.create()
        }
    }
    
    /**
    Reactive wrapper for CoreData NSBatchDeleteRequest operation
    
    - parameter className: Class of all entities to be deleted within current NSManagedObjectContext
    - parameter queue: Serial DispatchQueue to protect data from corruption by several read/write operations
    - returns: Observable array of executed delete and merge request result. Type Void used for bind(onNext:) compatibility
     */
    
    func deleteAll<T: NSManagedObject>(
        _ className: T.Type,
        on queue: DispatchQueue = DispatchQueue(label: "LocalSerialQueue")
    ) -> Observable<Void> {
        let entityName = String(describing: className)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        return Observable.create { observer -> Disposable in
            self.base.perform {
                queue.sync {
                    do {
                        try self.base.execute(batchDeleteRequest)
                        observer.onNext(())
                        observer.onCompleted()
                    } catch {
                        
                        observer.onError(NSManagedObjectContext.ReactiveError.batchDelete)
                    }
                }
            }
            return Disposables.create()
        }
    }
    
}

extension NSManagedObjectContext {
    
    enum ReactiveError: Swift.Error {
        
        case fetch
        case save
        case batchDelete
        case unknown
    
    }
    
}
