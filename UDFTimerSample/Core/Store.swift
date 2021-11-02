import Foundation

public protocol Timeline {
    func schedule(on queue: DispatchQueue, work: @escaping () -> ())
}

public final class RealTimeline: Timeline {
    public func schedule(on queue: DispatchQueue, work: @escaping () -> ()) {
        queue.async {
            work()
        }
    }
}

var currentTimeline: Timeline = RealTimeline()

public final class Store {
    
    public var state = State()
    
    private var observers = [] as [Observer]
    private let queue = DispatchQueue(label: "store")
    
    func dispatch(action: Action) {
        print("[store] Dispatching: ", action)
        currentTimeline.schedule(on: queue) { [self] in
            state.reduce(action)
            for observer in observers {
                observer.handle(state)
            }
        }
    }
    
    public func observe(with observer: Observer) {
        currentTimeline.schedule(on: queue) { [self] in
            observers.append(observer)
            observer.handle(state)
        }
    }
}

public final class Observer {
    
    public let handle: (State) -> ()
    
    public init(handle: @escaping (State) -> ()) {
        self.handle = handle
    }
}

extension Store {
    func bind(_ action: Action) -> Command {
        Command { [self] in
            dispatch(action: action)
        }
    }
    
    func bind<T>(_ actionCreator: @escaping (T) -> Action) -> CommandWith<T> {
        CommandWith { [self] value in
            dispatch(action: actionCreator(value))
        }
    }
}
