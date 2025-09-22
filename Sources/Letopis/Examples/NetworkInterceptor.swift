import Foundation

/// Example interceptor that can fail (simulating network issues) to demonstrate health checking.
public final class NetworkInterceptorExample: LetopisInterceptor {
    private var isNetworkAvailable: Bool = true
    private var simulateFailure: Bool = false
    private let endpoint: String

    /// Creates a network interceptor.
    /// - Parameter endpoint: Network endpoint URL for sending logs.
    public init(endpoint: String) {
        self.endpoint = endpoint
    }

    /// Simulates network failure for testing purposes.
    /// - Parameter shouldFail: Whether the interceptor should simulate failure.
    public func simulateNetworkFailure(_ shouldFail: Bool) {
        simulateFailure = shouldFail
        isNetworkAvailable = !shouldFail
    }

    /// Handles a log event by sending it to a network endpoint.
    /// - Parameter logEvent: Event to handle.
    public func handle(_ logEvent: LogEvent) async throws {
        guard isNetworkAvailable else {
            throw NetworkError.connectionFailed
        }

        if simulateFailure {
            throw NetworkError.requestTimeout
        }

        // Simulate network call delay
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second

        // Simulate successful network call
        print("📡 NetworkInterceptor: Sent log to \(endpoint) - \(logEvent.message)")
    }

    /// Checks if the network interceptor is healthy by testing connectivity.
    /// - Returns: `true` if network is available, `false` otherwise.
    public func health() async -> Bool {
        // Simulate health check that might recover the connection
        if simulateFailure {
            // 30% chance of recovery on each health check
            let recoveryChance = Double.random(in: 0...1)
            if recoveryChance < 0.3 {
                simulateFailure = false
                isNetworkAvailable = true
                print("🔄 NetworkInterceptor: Connection recovered")
                return true
            }
            return false
        }

        return isNetworkAvailable
    }
}

/// Errors that can occur in the network interceptor.
public enum NetworkError: Error {
    case connectionFailed
    case requestTimeout
    case serverError

    var localizedDescription: String {
        switch self {
        case .connectionFailed:
            return "Network connection failed"
        case .requestTimeout:
            return "Request timed out"
        case .serverError:
            return "Server error"
        }
    }
}
