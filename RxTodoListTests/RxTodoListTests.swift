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
    
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.context
        return context
    }()

    override func setUpWithError() throws {
        user.configure()
    }

    override func tearDownWithError() throws {

    }

    func test_User_appendTodo_testTodo() throws {
        user.setEdited(LocalTodo("Test todo"))
        user.appendTodo()
        
        XCTAssertEqual(
            user.getTodos().map { $0.name },
            ["Clean the apt",
             "Learn to code",
             "Call mom",
             "Do the workout",
             "Call customers",
             "Test todo"]
        )
    }
     
    func test_User_appendTodo_emptyTodo() throws {
        user.setEdited(LocalTodo())
        user.appendTodo()
        
        XCTAssertEqual(
            user.getTodos().map { $0.name },
            ["Clean the apt",
             "Learn to code",
             "Call mom",
             "Do the workout",
             "Call customers"]
        )
    }
    
    func test_User_editTodo_testTodo() throws {
        let todoToEdit = user.getTodos()[0]
        user.setEdited(todoToEdit)
        user.updateEdited("Test todo")
        user.editTodo()
        
        XCTAssertEqual(
            user.getTodos().map { $0.name },
            ["Test todo",
             "Learn to code",
             "Call mom",
             "Do the workout",
             "Call customers"]
        )
    }
    
    func test_User_editTodo_emptyTodo() throws {
        let todoToDelete = user.getTodos()[0]
        user.setEdited(todoToDelete)
        user.updateEdited("")
        user.editTodo()
        
        XCTAssertEqual(
            user.getTodos().map { $0.name },
            ["Learn to code",
             "Call mom",
             "Do the workout",
             "Call customers"]
        )
    }
    
    
    func test_User_logout() throws {
        let testLogout = try! user.logout()
            .toBlocking()
            .first()!
        
        XCTAssertEqual(testLogout, nil)
    }
    
    func test_User_loginAs() throws {
        let testLogin = try! user.loginAs("test_username", "test_password")
            .toBlocking()
            .first()!
        XCTAssertEqual(testLogin,
                       LoginDetails(username: "test_username", password: "test_password"))
    }
    
    func test_User_signupAs() throws {
        let testSignup = try! user.signupAs("test_username", "test_password")
            .toBlocking()
            .first()!
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
