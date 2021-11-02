import Foundation

public final class Command {
    public init(action: @escaping () -> ()) {
        self.action = action
    }
    
    private let action: () -> ()
    
    public func callAsFunction() {
        action()
    }
}

public final class CommandWith<T> {
    public init(action: @escaping (T) -> ()) {
        self.action = action
    }
    
    private let action: (T) -> ()
    
    public func callAsFunction(with value: T) {
        action(value)
    }
}

extension CommandWith {
    func dispatched(on queue: DispatchQueue) -> CommandWith {
        CommandWith { value in
            queue.async {
                self.action(value)
            }
        }
    }
}


extension Command {
    static var notImplemented: Command {
        Command {
            preconditionFailure("Not implemented")
        }
    }
}
