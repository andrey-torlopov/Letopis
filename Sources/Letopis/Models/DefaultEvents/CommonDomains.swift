import Foundation

/// Common domains covering most application logging needs.
/// Provides a comprehensive set of domains for typical iOS/macOS application scenarios.
public enum CommonDomain: String, DomainProtocol, Sendable {
    // MARK: - Special

    /// Empty/unspecified domain (fallback)
    case empty = "empty"

    // MARK: - Core Application

    /// Application lifecycle and state management
    case app = "app"

    /// UI layer and view hierarchy
    case ui = "ui"

    /// Navigation and routing
    case navigation = "navigation"

    // MARK: - Data & Network

    /// Network requests and connectivity
    case network = "network"

    /// API interactions
    case api = "api"

    /// Database operations
    case database = "database"

    /// Data parsing and serialization
    case parsing = "parsing"

    /// Caching mechanisms
    case cache = "cache"

    /// Persistent storage operations
    case storage = "storage"

    // MARK: - User & Auth

    /// Authentication and authorization
    case auth = "auth"

    /// User actions and interactions
    case user = "user"

    /// User session management
    case session = "session"

    // MARK: - Business Logic

    /// Business logic operations
    case business = "business"

    /// Data validation
    case validation = "validation"

    /// State management
    case state = "state"

    // MARK: - Technical

    /// Error handling and recovery
    case error = "error"

    /// Performance monitoring
    case performance = "performance"

    /// Debug and development
    case debug = "debug"

    /// Analytics and tracking
    case analytics = "analytics"

    // MARK: - Reactive & Async

    /// Combine publishers and streams
    case combine = "combine"

    /// Async/await operations
    case async = "async"

    // MARK: - System

    /// File system operations
    case fileSystem = "file_system"

    /// System-level operations
    case system = "system"

    /// Background tasks
    case background = "background"
}

/// Common actions covering typical application events and state changes.
public enum CommonAction: String, ActionProtocol, Sendable {
    // MARK: - Special

    /// Empty/unspecified action (fallback)
    case empty = ""

    // MARK: - Lifecycle

    /// Started or initiated
    case started = "started"

    /// Completed successfully
    case completed = "completed"

    /// Failed with error
    case failed = "failed"

    /// Cancelled by user or system
    case cancelled = "cancelled"

    /// Suspended or paused
    case suspended = "suspended"

    /// Resumed from suspension
    case resumed = "resumed"

    // MARK: - CRUD Operations

    /// Created new entity
    case created = "created"

    /// Read or fetched entity
    case read = "read"

    /// Updated existing entity
    case updated = "updated"

    /// Deleted entity
    case deleted = "deleted"

    // MARK: - Network & API

    /// Request sent
    case requestSent = "request_sent"

    /// Response received
    case responseReceived = "response_received"

    /// Connected to service
    case connected = "connected"

    /// Disconnected from service
    case disconnected = "disconnected"

    /// Retry attempted
    case retried = "retried"

    /// Timed out
    case timedOut = "timed_out"

    // MARK: - User Interaction

    /// User clicked/tapped
    case clicked = "clicked"

    /// User submitted form/data
    case submitted = "submitted"

    /// User navigated
    case navigated = "navigated"

    /// User searched
    case searched = "searched"

    /// User logged in
    case loggedIn = "logged_in"

    /// User logged out
    case loggedOut = "logged_out"

    // MARK: - UI State

    /// Appeared on screen
    case appeared = "appeared"

    /// Disappeared from screen
    case disappeared = "disappeared"

    /// Loaded content
    case loaded = "loaded"

    /// Refreshed content
    case refreshed = "refreshed"

    /// Rendered on screen
    case rendered = "rendered"

    // MARK: - Data State

    /// Data validated
    case validated = "validated"

    /// Data cached
    case cached = "cached"

    /// Data saved to storage
    case saved = "saved"

    /// Data synced
    case synced = "synced"

    /// Data transformed
    case transformed = "transformed"

    /// Storage cleared
    case cleared = "cleared"

    /// Storage migrated
    case migrated = "migrated"

    // MARK: - Error Handling

    /// Error occurred
    case errorOccurred = "error_occurred"

    /// Error recovered
    case errorRecovered = "error_recovered"

    /// Error logged
    case errorLogged = "error_logged"

    // MARK: - Performance

    /// Performance measured
    case measured = "measured"

    /// Benchmark started
    case benchmarkStarted = "benchmark_started"

    /// Benchmark ended
    case benchmarkEnded = "benchmark_ended"

    // MARK: - Debug

    /// Debug checkpoint hit
    case checkpoint = "checkpoint"

    /// State inspected
    case inspected = "inspected"

    /// Data dumped
    case dumped = "dumped"

    // MARK: - Reactive (Combine/Async)

    /// Publisher subscribed
    case subscribed = "subscribed"

    /// Value emitted/output
    case emitted = "emitted"

    /// Publisher output (alias for emitted, for Combine compatibility)
    case output = "output"

    /// Stream completed
    case streamCompleted = "stream_completed"
}
