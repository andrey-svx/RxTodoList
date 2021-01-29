import Foundation

struct LoginDetails {
    
    let email: String
    let password: String
    
}

extension LoginDetails: Equatable {
    
    static func == (lhs: LoginDetails, rhs: LoginDetails) -> Bool {
            lhs.email == rhs.email
        }

}
