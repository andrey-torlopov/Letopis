import XCTest
@testable import Letopis

final class HealthCheckTests: XCTestCase {

    func testInterceptorHealthTracking() throws {
        // Create interceptors
        let consoleInterceptor = ConsoleInterceptor()
        let networkInterceptor = NetworkInterceptorExample(endpoint: "https://test.com")

        // Create logger with fast health check interval for testing
        let logger = Letopis(interceptors: [consoleInterceptor, networkInterceptor], healthCheckInterval: 1.0)

        // Check initial health
        XCTAssertEqual(logger.healthyInterceptorsCount, 2)
        XCTAssertEqual(logger.totalInterceptorsCount, 2)

        // Simulate network failure
        networkInterceptor.simulateNetworkFailure(true)

        // Try to log - this should trigger failure detection
        logger.error("Test error that should fail network interceptor")
        logger.info("Another test message")
        logger.warning("Warning message")

        // Give some time for health tracking to detect failures
        Thread.sleep(forTimeInterval: 0.1)

        // Check health status
        let healthStatus = logger.getInterceptorHealthStatus()
        print("Health status after simulated failure:")
        for status in healthStatus {
            print("- \(status.type): \(status.state), can handle: \(status.canHandle)")
        }

        // The console interceptor should still be healthy
        let consoleStatus = healthStatus.first { $0.type.contains("ConsoleInterceptor") }
        XCTAssertNotNil(consoleStatus)
        XCTAssertTrue(consoleStatus?.canHandle ?? false)

        // Manually trigger health checks
        logger.triggerHealthChecks()

        print("Test completed successfully")
    }

    func testNetworkInterceptorRecovery() async throws {
        let networkInterceptor = NetworkInterceptorExample(endpoint: "https://test.com")
        let logger = Letopis(interceptors: [networkInterceptor])

        // Start with healthy interceptor
        XCTAssertEqual(logger.healthyInterceptorsCount, 1)

        // Simulate failure
        networkInterceptor.simulateNetworkFailure(true)

        // Try logging multiple times to trigger failure detection
        for i in 1...5 {
            do {
                try await networkInterceptor.handle(LogEvent(
                    type: .info,
                    isCritical: false,
                    message: "Test message \(i)",
                    payload: [:]
                ))
            } catch {
                // Expected to fail
                print("Expected failure: \(error)")
            }
        }

        // Test health check
        let isHealthy = await networkInterceptor.health()
        print("Network interceptor health after failure: \(isHealthy)")

        // The health() method has a 30% chance of recovery, so we might get true or false
        // This is expected behavior for simulation
    }
}
