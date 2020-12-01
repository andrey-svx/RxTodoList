import Foundation

struct Todo {
    
    let name: String
    let uuid = UUID()

    init(_ name: String) {
        self.name = name
    }
    
    static let empty = Todo("Empty")
    
}
