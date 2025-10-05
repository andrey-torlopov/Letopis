import Foundation

// MARK: - Demo Event Types

/// Screen actions for UI events
public enum ScreenAction: String, EventActionProtocol, Sendable {
    case open
    case close
    case error
}

/// Application event types
public enum AppEventType: String, EventTypeProtocol, Sendable {
    case uiAction = "ui_action"
    case businessLogic = "business_logic"
    case networkEvent = "network_event"
}

// MARK: - Network Simulation

/// Simulates network conditions for demonstration purposes
class NetworkMonitor {

    /// Possible network status states
    enum NetworkStatus {
        case online     // Full connectivity - all logs sent immediately
        case offline    // No connectivity - all logs cached
        case poor       // Limited connectivity - only critical logs sent
    }

    /// Returns a random network status to simulate varying conditions
    func getStatus() -> NetworkStatus {
        switch Int.random(in: 0...2) {
        case 0: return .online
        case 1: return .offline
        default: return .poor
    }
    }
}

/// Log model sent over network
struct NetworkLogModel {
    let id: UUID
    let timestamp: Date
    let text: String
    let isCritical: Bool
    let eventType: String
    let action: String
}

// MARK: - Network Interceptor

/// Thread-safe network interceptor using Swift Actor
/// Demonstrates proper handling of network conditions and caching
actor LogNetworkInterceptor: LetopisInterceptor {
    let name: String = "LogNetworkInterceptor"

    typealias NetworkProcessor = @Sendable (NetworkLogModel) -> Bool

    private var monitor: NetworkMonitor
    private let networkProcessor: NetworkProcessor
    private var cache: [NetworkLogModel] = []
    private var isNetworkAvailable: Bool = true

    init(
        monitor: NetworkMonitor,
        networkProcessor: @escaping NetworkProcessor
    ) {
        self.networkProcessor = networkProcessor
        self.monitor = monitor
    }

    /// Entry point for the protocol - delegates to async handler
    nonisolated func handle(_ logEvent: LogEvent) throws {
        Task {
            await handleAsync(logEvent)
        }
    }

    /// Main log handling logic with network-aware behavior
    private func handleAsync(_ logEvent: LogEvent) async {
        guard health() else { return }

        let status = monitor.getStatus()
        let model = NetworkLogModel(
            id: UUID(),
            timestamp: logEvent.timestamp,
            text: logEvent.message,
            isCritical: logEvent.isCritical,
            eventType: "network_log",
            action: "process"
        )

        switch status {
        case .online:
            // Process all cached logs plus current one
            await processOnlineState(newModel: model)

        case .offline:
            // Cache everything for later processing
            cache.append(model)
            print("📱 [OFFLINE] Cached log: \(model.text)")

        case .poor:
            // Only send critical logs immediately, cache others
            await processPoorConnectivityState(model: model)
        }
    }

    /// Handles online state - processes cache and new logs
    private func processOnlineState(newModel: NetworkLogModel) async {
        var models: [NetworkLogModel] = []
        models.append(contentsOf: cache)
        models.append(newModel)

        var failedModels: [NetworkLogModel] = []

        print("🌐 [ONLINE] Processing \(models.count) log(s)")

        for model in models {
            let result = networkProcessor(model)
            if result == false {
                failedModels.append(model)
                self.isNetworkAvailable = false
            }
        }

        cache = failedModels

        if cache.isEmpty {
            print("✅ [ONLINE] All logs sent successfully")
        } else {
            print("⚠️ [ONLINE] \(cache.count) log(s) failed, moved to cache")
        }
    }

    /// Handles poor connectivity - selective sending based on criticality
    private func processPoorConnectivityState(model: NetworkLogModel) async {
        if !model.isCritical {
            cache.append(model)
            print("📶 [POOR] Non-critical log cached: \(model.text)")
        } else {
            print("📶 [POOR] Attempting to send critical log: \(model.text)")
            let result = networkProcessor(model)
            if result == false {
                cache.append(model)
                self.isNetworkAvailable = false
                print("❌ [POOR] Critical log failed, cached for retry")
            } else {
                print("✅ [POOR] Critical log sent successfully")
            }
        }
    }

    /// Health check for the interceptor
    nonisolated func health() -> Bool {
        true
    }
}

// MARK: - Demo Scenarios

/// Demonstrates different network scenarios
struct NetworkScenarioDemo {

    /// Simulates a server that randomly succeeds or fails
    static func createNetworkProcessor() -> @Sendable (NetworkLogModel) -> Bool {
        return { @Sendable model in
            print("🔄 Attempting to send: \(model.text) [Critical: \(model.isCritical)]")

            // Simulate network delay
            Thread.sleep(forTimeInterval: 0.1)

            // 30% chance of failure to simulate real-world conditions
            let success = Double.random(in: 0...1) > 0.3

            if success {
                print("✅ Successfully sent to server: \(model.text)")
            } else {
                print("❌ Failed to send to server: \(model.text)")
            }

            return success
        }
    }

    /// Creates mixed critical/non-critical logs for testing
    static func generateTestLogs(logger: Letopis) {
        print("\n🚀 Starting network interceptor demonstration...")
        print("📋 Generating logs with different criticality levels to test network handling\n")

        // Generate a mix of critical and normal logs
        for i in 1...15 {
            let isCritical: Bool = (i % 4 == 0)
            let eventType: AppEventType = (i % 3 == 0) ? .networkEvent : .uiAction
            let action: ScreenAction = (i % 5 == 0) ? .error : .open

            var log = logger
                .event(eventType)
                .action(action)

            if isCritical {
                log = log.critical()
            }

            log.info("Demo log message #\(i)")
        }
    }
}

// MARK: - Main Demo

// 👇 UNCOMMENT THIS TO RUN EXAMPLE
// @main
struct LetopisDemo {
    static func main() {
        print("🎯 Letopis Network Interceptor Demo")
        print("=====================================")
        print("This demo shows how the network interceptor handles different connectivity states:")
        print("• 🌐 ONLINE: All logs sent immediately")
        print("• 📱 OFFLINE: All logs cached for later")
        print("• 📶 POOR: Only critical logs sent, others cached")
        print("")

        // Create logger with console output
        let logger = Letopis(interceptors: [ConsoleInterceptor()])

        // Add network interceptor with simulated server
        logger.addInterceptor(LogNetworkInterceptor(
            monitor: NetworkMonitor(),
            networkProcessor: NetworkScenarioDemo.createNetworkProcessor()
        ))

        // Generate test scenarios
        NetworkScenarioDemo.generateTestLogs(logger: logger)

        print("\n⏳ Processing logs (network simulation in progress)...")
        print("Watch for different network states and caching behavior!\n")

        // Allow time for async processing and network simulation
        Thread.sleep(forTimeInterval: 8.0)

        print("\n🏁 Demo completed!")
        print("💡 Key observations:")
        print("   • Logs are processed differently based on network state")
        print("   • Failed logs are cached and retried when network improves")
        print("   • Critical logs get priority even in poor connectivity")
        print("   • The actor ensures thread-safe cache operations")
    }
}
