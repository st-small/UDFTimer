import Foundation

public protocol Action {}

extension Action {
    func on<T: Action>(_ type: T.Type, code: (T) -> Void) {
        guard let action = self as? T else { return }
        code(action)
    }
    
    func on<T: Action>(_ type: T.Type, code: () -> Void) {
        guard self is T else { return }
        code()
    }
}

public struct State {
    public var timerStatus: TimerStatus = .initial
    public var timerState: TimerState = .init()
    
    public mutating func reduce(_ action: Action) {
        timerStatus.reduce(action)
        timerState.reduce(action)
    }
}

public struct TimerState {
    
    public var accumulator: Double = 0
    public var lastStartDate: Double = 0
    
    mutating func reduce(_ action: Action) {
        
        action.on(TimerStatusRunning.self) {
            lastStartDate = Date().timeIntervalSince1970
        }
        
        action.on(TimerStatusResume.self) {
            lastStartDate = Date().timeIntervalSince1970
        }
        
        action.on(TimerStatusPaused.self) { action in
            accumulator += Date() - Date(timeIntervalSince1970: lastStartDate)
        }
        
        action.on(TimerStatusReset.self) {
            accumulator = 0
            lastStartDate = 0
        }
    }
}

public enum TimerStatus {
    case initial
    case running
    case paused
    
    public mutating func reduce(_ action: Action) {
        action.on(TimerStatusRunning.self) {
            self = .running
        }
        
        action.on(TimerStatusPaused.self) {
            self = .paused
        }
        
        action.on(TimerStatusResume.self) {
            self = .running
        }
        
        action.on(TimerStatusReset.self) {
            self = .initial
        }
    }
}

struct TimerStatusRunning: Action { }
struct TimerStatusPaused: Action { }
struct TimerStatusResume: Action { }
struct TimerStatusReset: Action { }
