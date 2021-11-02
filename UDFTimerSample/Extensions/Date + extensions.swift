import Foundation

extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}

extension TimeInterval {
    func toString() -> String {
        let h = Int(self) / 60
        let m = Int(self) % 60
        return "\(h.padZero()):\(m.padZero())"
    }
}

extension Int {
    func padZero() -> String {
        return String(format: "%02d", self)
    }
}
