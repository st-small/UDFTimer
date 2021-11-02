import XCTest
@testable import UDFTimerSample

class MockedProps<Props> {
    var props: Props!
    
    var command: CommandWith<Props> { CommandWith { self.props = $0 }}
}

class TestTimeline: Timeline {
    func schedule(on queue: DispatchQueue, work: @escaping () -> ()) {
        work()
    }
}

class UDFTimerSampleTests: XCTestCase {
    
    var timerViewController: MockedProps<TimerViewController.Props>!

    override func setUpWithError() throws {
        currentTimeline = TestTimeline()
        let store = Store()
        
        timerViewController = MockedProps<TimerViewController.Props>()
        
        let viewControllerOperator = TimerViewControllerOperator(render: timerViewController.command, store: store)
        
        store.observe(with: Observer(handle: viewControllerOperator.process(state:)))
    }

    func testInitialState() {
        XCTAssertNotNil(timerViewController.props.initial)
    }
    
    func testLoadingState() {
        timerViewController.props.initial?.start()
        XCTAssertNotNil(timerViewController.props.startTimer)
    }
    
    func testResetState() {
        timerViewController.props.initial?.start()
        timerViewController.props.startTimer?.reset()
        XCTAssertNotNil(timerViewController.props.initial)
    }
}
