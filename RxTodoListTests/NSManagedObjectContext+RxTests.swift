import XCTest
import CoreData
import RxSwift
import RxCocoa
import RxRelay
import RxBlocking

@testable
import RxTodoList

class NSManagedObjectContext_RxTests: XCTestCase {
    
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.context
    }()

    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        
    }
    
    func test_NSManagedObjectContext_fetch() throws {
        
        let testCDTodos: [CDTodo] = ["Clean the apt",
                                     "Learn to code",
                                     "Call mom",
                                     "Do the workout",
                                     "Call customers"]
            .map { name -> Todo in
                sleep(1)
                return Todo(name)
            }
            .map {
                let cdTodo = CDTodo(context: context)
                cdTodo.name = $0.name
                cdTodo.id = $0.id
                cdTodo.date = $0.date
                return cdTodo
            }

        context.performAndWait {
            do {
                try context.save()
            } catch {
                print(error)
            }
        }
        
        let request = CDTodo.fetchRequest() as NSFetchRequest<CDTodo>
        let sort = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sort]
        request.returnsObjectsAsFaults = false
        let fetchedCDTodos = try! context.rx
            .fetch(request)
            .toBlocking()
            .first()!
        
        XCTAssertEqual(fetchedCDTodos, testCDTodos)
        
        context.performAndWait {
            do {
                context.registeredObjects.forEach(context.delete)
                try context.save()
            } catch {
                print(error)
            }
        }
        
    }
    
    func test_NSManagedObjectContext_save() throws {
        
        let testCDTodos = ["Test todo",
                           "Another test todo"]
            .map { Todo($0) }
            .map { todo -> CDTodo in
                let cdTodo = CDTodo(context: context)
                cdTodo.name = todo.name
                cdTodo.date = todo.date
                cdTodo.id = todo.id
                return cdTodo
            }
        
        context.rx
            .save()
            .bind(onNext: { _ in
                
                self.context.performAndWait {
                    do {
                        let request = CDTodo.fetchRequest() as NSFetchRequest<CDTodo>
                        let sort = NSSortDescriptor(key: "date", ascending: true)
                        request.sortDescriptors = [sort]
                        request.returnsObjectsAsFaults = false
                        let fetchedCDTodos = try self.context.fetch(request)
                        
                        XCTAssertEqual(testCDTodos, fetchedCDTodos)
                        
                        self.context.registeredObjects.forEach(self.context.delete)
                        try self.context.save()
                    } catch {
                        print(error)
                    }
                }
                
            })
            .disposed(by: DisposeBag())
        
    }
    
    func test_NSManagedObjectContext_insert() throws {
        
        let bag = DisposeBag()
        
        let testCDTodo = ["Test todo"]
            .map { Todo($0) }
            .map { todo -> CDTodo in
                let cdTodo = CDTodo(context: context)
                cdTodo.name = todo.name
                cdTodo.date = todo.date
                cdTodo.id = todo.id
                return cdTodo
            }
            .first!
        
        context.performAndWait {
            do {
                try self.context.save()
            } catch {
                print(error)
            }
        }
        
        let insertedCDTodo = ["Inserted todo"]
            .map { Todo($0) }
            .map { todo -> CDTodo in
                let cdTodo = CDTodo(context: context)
                cdTodo.name = todo.name
                cdTodo.date = todo.date
                cdTodo.id = todo.id
                return cdTodo
            }
            .first!
        
        context.rx
            .insert(insertedCDTodo)
            .flatMap { _ -> Observable<Void> in
                return self.context.rx
                .save()
            }
            .bind(onNext: { _ in
                let request = CDTodo.fetchRequest() as NSFetchRequest<CDTodo>
                let sort = NSSortDescriptor(key: "date", ascending: true)
                request.sortDescriptors = [sort]
                request.returnsObjectsAsFaults = false
                self.context.performAndWait {
                    do {
                        let fetchedCDTodos = try self.context.fetch(request)
                        
                        XCTAssertEqual(fetchedCDTodos, [testCDTodo, insertedCDTodo])
                        
                        self.context.registeredObjects.forEach(self.context.delete)
                        try self.context.save()
                        
                    } catch {
                        print(error)
                    }
                }
            })
            .disposed(by: bag)
        
        
        
    }
    
    func test_NSManagedObjectContext_delete() throws {
        
        let testCDTodos = ["Test todo",
                           "Deleted todo"]
            .map { Todo($0) }
            .map { todo -> CDTodo in
                let cdTodo = CDTodo(context: context)
                cdTodo.name = todo.name
                cdTodo.date = todo.date
                cdTodo.id = todo.id
                return cdTodo
            }
        
        let bag = DisposeBag()
        
        context.rx
            .save()
            .bind(onNext: { _ in })
            .disposed(by: bag)
            
            context.rx
                .delete(testCDTodos[1])
                .flatMap { _ -> Observable<Void> in
                    return self.context.rx
                    .save()
                }
                .bind(onNext: { _ in
                    let request = CDTodo.fetchRequest() as NSFetchRequest<CDTodo>
                    let sort = NSSortDescriptor(key: "date", ascending: true)
                    request.sortDescriptors = [sort]
                    request.returnsObjectsAsFaults = false
                    self.context.performAndWait {
                        do {
                            let fetchedCDTodos = try self.context.fetch(request)
                            
                            XCTAssertEqual(fetchedCDTodos, [testCDTodos[0]])
                            
                            self.context.registeredObjects.forEach(self.context.delete)
                            try self.context.save()
                            
                        } catch {
                            print(error)
                        }
                    }
                    
                })
                .disposed(by: bag)
        
        
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
