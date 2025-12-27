//
//  DevelopmentDomain.swift
//  Letopis
//
//  Created by Andrey Torlopov on 27.12.2025.
//


/// Development and debugging domains for developer tooling.
public enum DevelopmentDomain: String, DomainProtocol, Sendable {
    /// General debug information
    case debug = "debug"

    /// Performance measurement
    case performance = "performance"

    /// Code execution trace
    case trace = "trace"
}

/// Development action types for debugging and performance analysis.
public enum DevelopmentAction: String, ActionProtocol, Sendable {
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
