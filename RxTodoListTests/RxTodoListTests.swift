import XCTest
import RxBlocking

@testable
import RxTodoList

class RxTodoListTests: XCTestCase {
    
    let user = User()

    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        
    }

    func test_User_updateTodos_append() throws {
        user.configure()
        user.setEdited(Todo("Test todo"))
        user.updateTodos()
        XCTAssertEqual(user.getTodos()
                        .map { $0.name },
                       ["Clean the apt",
                        "Learn to code",
                        "Call mom",
                        "Do the workout",
                        "Call customers",
                        "Test todo"])
        
        user.configure()
        user.setEdited(Todo(""))
        user.updateTodos()
        XCTAssertEqual(user.getTodos()
                        .map { $0.name },
                       ["Clean the apt",
                        "Learn to code",
                        "Call mom",
                        "Do the workout",
                        "Call customers"])
    }
    
    func test_User_updateTodos_edit() throws {
        user.configure()
        let todoToEdit = user.getTodos()[0]
        user.setEdited(todoToEdit)
        user.updateEdited("Test todo")
        user.updateTodos()
        XCTAssertEqual(user.getTodos()
                        .map { $0.name },
                       ["Test todo",
                        "Learn to code",
                        "Call mom",
                        "Do the workout",
                        "Call customers"])
        
        user.configure()
        let todoToDelete = user.getTodos()[0]
        user.setEdited(todoToDelete)
        user.updateEdited("")
        user.updateTodos()
        XCTAssertEqual(user.getTodos()
                        .map { $0.name },
                       ["Learn to code",
                        "Call mom",
                        "Do the workout",
                        "Call customers"])
    }
    
    func test_User_logout() {
        user.configure()
        let testLogout = try! user.logout()
            .toBlocking().first()!
        XCTAssertEqual(testLogout, nil)
    }
    
    func test_User_loginAs() {
        user.configure()
        let testLogin = try! user.loginAs("test_username", "test_password")
            .toBlocking().first()!
        XCTAssertEqual(testLogin,
                       LoginDetails(username: "test_username", password: "test_password"))
    }
    
    func test_User_signupAs() {
        user.configure()
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
