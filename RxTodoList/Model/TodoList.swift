import CoreData
import RxSwift
import Foundation

class TodoList {
    
    private let observer: BehaviorSubject<[Todo]>
    
    
    init(_ observer: BehaviorSubject<[Todo]>) {
        self.observer = observer
    }
    
    
    
}
