import Foundation

public final class TimerViewControllerOperator {
    
    public typealias Props = TimerViewController.Props
    
    private let render: CommandWith<Props>
    private let store: Store
    
    public init(render: CommandWith<Props>, store: Store) {
        self.render = render
        self.store = store
    }
    
    public func process(state: State) {
        render(with: map(state: state))
    }
    
    func map(state: State) -> Props {
        switch state.timerStatus {
        case .initial:
            return .initial(
                .init(
                    start: store.bind(TimerStatusRunning()),
                    reset: store.bind(TimerStatusReset())))
        case .running:
            return .startTimer(
                .init(
                    accumulator: state.timerState.accumulator,
                    timestamp: state.timerState.lastStartDate,
                    pause: store.bind(TimerStatusPaused()),
                    reset: store.bind(TimerStatusReset())))
        case .paused:
            return .pausedTimer(
                .init(
                    resume: store.bind(TimerStatusRunning()),
                    reset: store.bind(TimerStatusReset()))
            )
        }
    }
}
