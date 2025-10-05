/// Lifecycle event types for screens, components, and application states.
public enum LifecycleEventType: String, EventTypeProtocol, Sendable {
    /// Screen-level lifecycle events (view controllers, screens)
    case screen = "screen_lifecycle"

    /// Application-level lifecycle events (app state changes)
    case app = "app_lifecycle"

    /// Component-level lifecycle events (custom components, views)
    case component = "component_lifecycle"

    /// Session-level lifecycle events (user sessions)
    case session = "session_lifecycle"
}

/// Lifecycle action types representing different stages of an object's lifetime.
public enum LifecycleAction: String, EventActionProtocol, Sendable {
    /// Object is about to appear/start
    case willAppear = "will_appear"

    /// Object has appeared/started
    case didAppear = "did_appear"

    /// Object is about to disappear/stop
    case willDisappear = "will_disappear"

    /// Object has disappeared/stopped
    case didDisappear = "did_disappear"

    /// Object is about to load/initialize
    case willLoad = "will_load"

    /// Object has loaded/initialized
    case didLoad = "did_load"

    /// Object is about to be destroyed/deallocated
    case willDestroy = "will_destroy"

    /// Object has been destroyed/deallocated
    case didDestroy = "did_destroy"
}
