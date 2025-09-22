import Foundation

/// Describes an entity that is able to handle log events produced by ``Letopis``.
public protocol LetopisInterceptor {
    /// Called when a log event is emitted by ``Letopis``.
    /// - Parameter logEvent: Event that should be handled.
    /// - Throws: An error if the interceptor fails to handle the event.
    func handle(_ logEvent: LogEvent) async throws

    /// Checks if the interceptor is healthy and able to handle log events.
    /// - Returns: `true` if the interceptor is operational, `false` if it's failed.
    func health() async -> Bool
}
