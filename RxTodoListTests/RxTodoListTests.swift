import XCTest
import CoreData
import RxSwift
import RxCocoa
import RxRelay
import RxBlocking

@testable
import RxTodoList

class RxTodoListTests: XCTestCase {
    
    let user = User()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).context

    override func setUpWithError() throws {
        user.configure()
    }

    override func tearDownWithError() throws {

    }

    func test_User_appendTodo_testTodo() throws {
        user.setEdited(Todo("Test todo"))
        user.appendTodo()
        XCTAssertEqual(user.getTodos()
                        .map { $0.name },
                       ["Clean the apt",
                        "Learn to code",
                        "Call mom",
                        "Do the workout",
                        "Call customers",
                        "Test todo"])
    }
     
    func test_User_appendTodo_emptyTodo() throws {
        user.setEdited(Todo())
        user.appendTodo()
        XCTAssertEqual(user.getTodos()
                        .map { $0.name },
                       ["Clean the apt",
                        "Learn to code",
                        "Call mom",
                        "Do the workout",
                        "Call customers"])
    }
    
    func test_User_editTodo_testTodo() throws {
        let todoToEdit = user.getTodos()[0]
        user.setEdited(todoToEdit)
        user.updateEdited("Test todo")
        user.editTodo()
        XCTAssertEqual(user.getTodos()
                        .map { $0.name },
                       ["Test todo",
                        "Learn to code",
                        "Call mom",
                        "Do the workout",
                        "Call customers"])
    }
    
    func test_User_editTodo_emptyTodo() throws {
        
        let todoToDelete = user.getTodos()[0]
        user.setEdited(todoToDelete)
        user.updateEdited("")
        user.editTodo()
        XCTAssertEqual(user.getTodos()
                        .map { $0.name },
                       ["Learn to code",
                        "Call mom",
                        "Do the workout",
                        "Call customers"])
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
            guard context.hasChanges else { return }
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
                testCDTodos.forEach(context.delete)
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
                let request = CDTodo.fetchRequest() as NSFetchRequest<CDTodo>
                let sort = NSSortDescriptor(key: "date", ascending: true)
                request.sortDescriptors = [sort]
                request.returnsObjectsAsFaults = false
                let fetchedCDTodos = try! self.context.rx
                    .fetch(request)
                    .toBlocking()
                    .first()!
                
                XCTAssertEqual(testCDTodos, fetchedCDTodos)
                do {
                    testCDTodos.forEach(self.context.delete)
                    try self.context.save()
                } catch {
                    print(error)
                }
            })
            .disposed(by: DisposeBag())
        
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
        
        context.rx
            .save()
            .bind(onNext: { _ in })
            .disposed(by: DisposeBag())
            
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
                            
                            testCDTodos.forEach(self.context.delete)
                            try self.context.save()
                            
                        } catch {
                            print(error)
                        }
                    }
                    
                })
                .disposed(by: DisposeBag())
        
        
    }
    
    func test_User_logout() throws {
        let testLogout = try! user.logout()
            .toBlocking().first()!
        XCTAssertEqual(testLogout, nil)
    }
    
    func test_User_loginAs() throws {
        let testLogin = try! user.loginAs("test_username", "test_password")
            .toBlocking().first()!
        XCTAssertEqual(testLogin,
                       LoginDetails(username: "test_username", password: "test_password"))
    }
    
    func test_User_signupAs() throws {
        let testSignup = try! user.loginAs("test_username", "test_password")
            .toBlocking().first()!
        XCTAssertEqual(testSignup,
                       LoginDetails(username: "test_username", password: "test_password"))
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
