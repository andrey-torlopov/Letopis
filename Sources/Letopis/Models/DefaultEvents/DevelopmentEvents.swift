/// Development and debugging event types for developer tooling.
public enum DevelopmentEventType: String, EventTypeProtocol, Sendable {
    /// General debug information
    case debug = "debug"

    /// Performance measurement events
    case performance = "performance"

    /// Code execution trace events
    case trace = "trace"

    /// State inspection events
    case inspection = "inspection"
}

/// Development action types for debugging and performance analysis.
public enum DevelopmentAction: String, EventActionProtocol, Sendable {
    /// Mark a checkpoint in code execution
    case checkpoint = "checkpoint"

    /// Measure performance metrics
    case measure = "measure"

    /// Log breakpoint hit
    case breakpoint = "breakpoint"

    /// Inspect current state
    case inspect = "inspect"

    /// Dump data or state
    case dump = "dump"

    /// Start timing
    case startTiming = "start_timing"

    /// End timing
    case endTiming = "end_timing"
}
