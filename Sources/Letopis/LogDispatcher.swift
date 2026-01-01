import Foundation

/// Singleton dispatcher that manages the global logging instance.
///
/// This class provides thread-safe access to the logging system and can be easily mocked for testing.
///
/// Example usage:
/// ```swift
/// // Configure at app startup
/// LogDispatcher.configure(with: Letopis(interceptors: [ConsoleInterceptor()]))
///
/// // Use LogMessage anywhere in the code
/// LogMessage(.debug, "User logged in", domain: CommonDomain.auth, action: CommonAction.loggedIn)
/// LogMessage(.error, "Payment failed", domain: CommonDomain.business, action: CommonAction.failed)
/// ```
public final class LogDispatcher: @unchecked Sendable {

    // MARK: - Singleton

    /// Shared instance of the log dispatcher.
    public static let shared = LogDispatcher()

    // MARK: - Private Properties

    private var logger: Letopis?
    private var hasShownWarning = false
    private let lock = NSLock()

    // MARK: - Initialization

    private init() {}

    // MARK: - Public Methods

    /// Configures the global logger instance.
    /// - Parameter logger: The Letopis instance to use for logging.
    /// - Note: This should be called once at application startup.
    public func configure(with logger: Letopis) {
        lock.lock()
        defer { lock.unlock() }
        self.logger = logger
        self.hasShownWarning = false
    }

    /// Returns the configured logger instance.
    /// - Returns: The Letopis instance, or nil if not configured.
    public func instance() -> Letopis? {
        lock.lock()
        defer { lock.unlock() }

        if logger == nil && !hasShownWarning {
            hasShownWarning = true
            #if DEBUG
            print("⚠️ [Letopis] LogDispatcher is not configured. Call LogDispatcher.configure(with:) at app startup.")
            print("   Example: LogDispatcher.configure(with: Letopis(interceptors: [ConsoleInterceptor()]))")
            #endif
        }

        return logger
    }

    /// Resets the logger instance (useful for testing).
    public func reset() {
        lock.lock()
        defer { lock.unlock() }
        logger = nil
        hasShownWarning = false
    }

    /// Checks if the logger is configured.
    /// - Returns: true if logger is configured, false otherwise.
    public func isConfigured() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return logger != nil
    }
}

// MARK: - Convenience Static Methods

extension LogDispatcher {
    /// Configures the global logger instance (static convenience method).
    /// - Parameter logger: The Letopis instance to use for logging.
    public static func configure(with logger: Letopis) {
        shared.configure(with: logger)
    }

    /// Returns the configured logger instance (static convenience method).
    /// - Returns: The Letopis instance, or nil if not configured.
    public static func instance() -> Letopis? {
        return shared.instance()
    }

    /// Resets the logger instance (static convenience method).
    public static func reset() {
        shared.reset()
    }

    /// Checks if the logger is configured (static convenience method).
    /// - Returns: true if logger is configured, false otherwise.
    public static func isConfigured() -> Bool {
        return shared.isConfigured()
    }
}
