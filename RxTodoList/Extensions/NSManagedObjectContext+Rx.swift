import Foundation
import CoreData
import RxSwift

extension Reactive where Base: NSManagedObjectContext {
    
    func fetch<T>(_ request: NSFetchRequest<T>) -> Observable<[T]> {
        Observable.create { observer -> Disposable in
            self.base.performAndWait {
                do {
                    let nsObjects = try self.base.fetch(request) 
                    observer.onNext(nsObjects)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    func save() -> Observable<Void> {
        guard base.hasChanges else { return Observable.just(()) }
        return Observable.create { observer -> Disposable in
            self.base.performAndWait {
                do {
                    try self.base.save()
                    observer.onNext(())
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    func delete<T: NSManagedObject>(_ object: T) -> Observable<Void> {
        Observable.create { observer -> Disposable in
            self.base.performAndWait {
                self.base.delete(object)
                observer.onNext(())
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
}
