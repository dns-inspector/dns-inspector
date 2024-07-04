import Foundation

/// Describes a timer for measuring the duration of an operation
internal class Timer {
    private var startTime: DispatchTime

    private init(startTime: DispatchTime) {
        self.startTime = startTime
    }

    /// Create and start a new timer
    internal static func start() -> Timer {
        return Timer(startTime: DispatchTime.now())
    }

    /// Stop the timer and return the number of nanoseconds since the timer started
    internal func stop() -> UInt64 {
        let endTime = DispatchTime.now()
        return endTime.uptimeNanoseconds - self.startTime.uptimeNanoseconds
    }
}
