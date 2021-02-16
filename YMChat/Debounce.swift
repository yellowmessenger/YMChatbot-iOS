import Foundation

class Debouncer {
    typealias Handler = () -> Void

    private let timeInterval: TimeInterval
    var handler: Handler?

    init(timeInterval: TimeInterval, handler: Handler? = nil) {
        self.timeInterval = timeInterval
        self.handler = handler
    }

    private var timer: Timer?

    func renewInterval() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
            self?.handler?()
        }
    }

    func stop() {
        timer?.invalidate()
    }
}
