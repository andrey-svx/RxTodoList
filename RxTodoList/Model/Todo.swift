import Foundation

struct Todo {
    
    private(set) var name: String
    let id = UUID()

    init(_ name: String) {
        self.name = name
    }
    
    mutating func update(_ name: String) {
        self.name = name
    }
    
}
