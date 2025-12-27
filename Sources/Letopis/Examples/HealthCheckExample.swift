import Foundation

/// Example demonstrating the health check system in action.
public class HealthCheckExample {

    /// Runs a demonstration of the health check system.
    public static func runExample() {
        print("🚀 Starting Health Check Example")

        // Create interceptors
        let consoleInterceptor = ConsoleInterceptor(
            severities: [.debug, .info, .notice, .warning, .error, .fault],
            printer: { print($0) }
        )
        let networkInterceptor = NetworkInterceptorExample(endpoint: "https://api.example.com/logs")

        // Create logger with interceptors
        let logger = Letopis(interceptors: [consoleInterceptor, networkInterceptor])

        // Log some initial events
        print("\n📝 Logging initial events...")
        logger.log().domain("app").action("started").info("Application started")
        logger.log().domain("system").action("memory_warning").warning("Memory usage high")

        // Check initial health status
        print("\n🏥 Initial health status:")
        printHealthStatus(logger)

        // Simulate network failure
        print("\n💥 Simulating network failure...")
        networkInterceptor.simulateNetworkFailure(true)

        // Try logging with failed network
        logger.log().domain("app").action("error").critical().error("Critical error occurred")
        logger.log().domain("user").action("completed").info("User action completed")

        // Check health status after failure
        print("\n🏥 Health status after network failure:")
        printHealthStatus(logger)

        // Wait and trigger health checks
        print("\n🔄 Triggering health checks...")
        logger.triggerHealthChecks()

        // Keep trying to log events (some may fail, some may succeed after recovery)
        for i in 1...5 {
            logger.log().domain("test").action("message").info("Test message \(i)")

            // Trigger health checks periodically
            if i % 2 == 0 {
                logger.triggerHealthChecks()
                printHealthStatus(logger)
            }

            // Small delay to simulate real-world scenario
            Thread.sleep(forTimeInterval: 1)
        }

        print("\n✅ Health Check Example completed")
    }

    private static func printHealthStatus(_ logger: Letopis) {
        let status = logger.getInterceptorHealthStatus()
        print("📊 Interceptor Status:")
        for interceptor in status {
            let statusIcon = interceptor.canHandle ? "✅" : "❌"
            print("  \(statusIcon) \(interceptor.type): \(interceptor.state) (can handle: \(interceptor.canHandle))")
        }
        print("  📈 Healthy: \(logger.healthyInterceptorsCount)/\(logger.totalInterceptorsCount)")
    }
}
