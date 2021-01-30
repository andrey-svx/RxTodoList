import XCTest
import CoreData
import RxSwift
import RxRelay


@testable
import RxTodoList

class AccountTests: XCTestCase {
    
    var account: Account!
    
    override func setUpWithError() throws {
        account = Account()
    }

    override func tearDownWithError() throws {
        account = nil
    }
    
    func test_logout() throws {
//        let result = try! account
//            .logout()
//            .toBlocking()
//            .first()!
//        XCTAssertNil(result)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
