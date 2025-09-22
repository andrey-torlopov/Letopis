import Foundation

/// Represents the health state of an interceptor.
public enum InterceptorHealthState {
    /// Interceptor is operational and handling events.
    case healthy
    /// Interceptor has failed and is not handling events.
    case failed
    /// Interceptor is being checked for recovery.
    case recovering
}

/// Tracks the health and recovery state of an interceptor.
class InterceptorHealthTracker: @unchecked Sendable {
    let interceptor: LetopisInterceptor
    private(set) var state: InterceptorHealthState = .healthy
    private(set) var lastFailureTime: Date?
    private(set) var consecutiveFailures: Int = 0
    private(set) var recoveryAttempts: Int = 0

    private let maxConsecutiveFailures: Int
    private let recoveryInterval: TimeInterval
    private let maxRecoveryAttempts: Int

    /// Creates a new health tracker for an interceptor.
    /// - Parameters:
    ///   - interceptor: The interceptor to track.
    ///   - maxConsecutiveFailures: Maximum consecutive failures before marking as failed.
    ///   - recoveryInterval: Time interval between recovery attempts in seconds.
    ///   - maxRecoveryAttempts: Maximum number of recovery attempts before giving up.
    init(
        interceptor: LetopisInterceptor,
        maxConsecutiveFailures: Int = 3,
        recoveryInterval: TimeInterval = 30.0,
        maxRecoveryAttempts: Int = 5
    ) {
        self.interceptor = interceptor
        self.maxConsecutiveFailures = maxConsecutiveFailures
        self.recoveryInterval = recoveryInterval
        self.maxRecoveryAttempts = maxRecoveryAttempts
    }

    /// Records a successful event handling.
    func recordSuccess() {
        consecutiveFailures = 0
        recoveryAttempts = 0
        state = .healthy
    }

    /// Records a failure in event handling.
    func recordFailure() {
        consecutiveFailures += 1
        lastFailureTime = Date()

        if consecutiveFailures >= maxConsecutiveFailures {
            state = .failed
        }
    }

    /// Checks if the interceptor should be attempted for recovery.
    func shouldAttemptRecovery() -> Bool {
        guard state == .failed else { return false }
        guard recoveryAttempts < maxRecoveryAttempts else { return false }
        guard let lastFailure = lastFailureTime else { return false }

        return Date().timeIntervalSince(lastFailure) >= recoveryInterval
    }

    /// Attempts to recover the interceptor by checking its health.
    func attemptRecovery() async -> Bool {
        guard shouldAttemptRecovery() else { return false }

        state = .recovering
        recoveryAttempts += 1

        let isHealthy = await interceptor.health()

        if isHealthy {
            recordSuccess()
            return true
        } else {
            state = .failed
            lastFailureTime = Date()
            return false
        }
    }

    /// Checks if the interceptor can handle events.
    var canHandleEvents: Bool {
        return state == .healthy
    }

    /// Checks if the interceptor has permanently failed.
    var isPermanentlyFailed: Bool {
        return state == .failed && recoveryAttempts >= maxRecoveryAttempts
    }
}
