import UIKit

public final class TimerViewController: UIViewController {
    
    // MARK: - UI elements
    @IBOutlet private var timer: UILabel!
    @IBOutlet private var actionButton: UIButton!
    @IBOutlet private var resetButton: UIButton!
    
    private var accumulator: Double = 0
    private var timestamp: Double = 0
    private var timerScheduler: Timer?
    
    public enum Props {
        case initial(Initial)
        case startTimer(StartTimer)
        case pausedTimer(PausedTimer)
        
        public struct Initial {
            let start: Command
            let reset: Command
        }

        public struct StartTimer {
            let accumulator: Double
            let timestamp: Double?
            let pause: Command
            let reset: Command
        }
        
        public struct PausedTimer {
            let resume: Command
            let reset: Command
        }
        
        public var initial: Initial? {
            guard case .initial(let value) = self else { return nil }
            return value
        }
        
        var startTimer: StartTimer? {
            guard case .startTimer(let value) = self else { return nil }
            return value
        }
        
        var pausedTimer: PausedTimer? {
            guard case .pausedTimer(let value) = self else { return nil }
            return value
        }
    }
    
    public var props: Props = .initial(.init(start: .notImplemented, reset: .notImplemented)) {
        didSet {
            render(props: props)
        }
    }
    
    private func render(props: Props) {
        guard isViewLoaded else { return }
        
        switch props {
        case .initial:
            stopTimer()
        case .startTimer(let timer):
            accumulator = timer.accumulator
            timestamp = timer.timestamp ?? 0
            runTimer()
        case .pausedTimer:
            stopTimer()
        }
        
        configureTimerLabel(props)
        configureActionButton(props)
        configureResetButton(props)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        render(props: props)
    }
    
    private func configureTimerLabel(_ props: Props) {
        timer.text = {
            switch props {
            case .initial:
                return "00:00"
            case .startTimer:
                return renderCurrentTimerValue()
            case .pausedTimer:
                return renderCurrentTimerValue()
            }
        }()
    }
    
    private func configureActionButton(_ props:Props) {
        let actionTitle: String = {
            switch props {
            case .initial:
                return "Start"
            case .startTimer:
                return "Pause"
            case .pausedTimer:
                return "Resume"
            }
        }()
        actionButton.setTitle(actionTitle, for: .normal)
    }
    
    private func configureResetButton(_ props: Props) {
        let resetButtonHidden: Bool = {
            switch props {
            case .initial:
                return true
            case .startTimer, .pausedTimer:
                return false
            }
        }()
        resetButton.isHidden = resetButtonHidden
        resetButton.setTitle("Reset", for: .normal)
        
        UIView.animate(withDuration: 0.3) {
            self.view.setNeedsDisplay()
        }
    }
    
    private func runTimer() {
        timerScheduler = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateTimerLabel), userInfo: nil, repeats: true)
    }
    
    @objc
    private func updateTimerLabel() {
        timer.text = renderCurrentTimerValue()
    }
    
    private func stopTimer() {
        timerScheduler?.invalidate()
    }
    
    private func renderCurrentTimerValue() -> String {
        let diff = Date() - Date(timeIntervalSince1970: timestamp) + accumulator
        return diff.toString()
    }
    
    // MARK: - Actions
    @IBAction private func actionTimerTapped() {
        switch props {
        case .initial:
            props.initial?.start()
        case .startTimer:
            props.startTimer?.pause()
        case .pausedTimer:
            props.pausedTimer?.resume()
        }
    }
    
    @IBAction private func resetTimer() {
        switch props {
        case .initial:
            break
        case .startTimer:
            props.startTimer?.reset()
        case .pausedTimer:
            props.pausedTimer?.reset()
        }
    }
}
                                        
