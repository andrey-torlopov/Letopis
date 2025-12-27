/// Lifecycle domains for screens, components, and application states.
public enum LifecycleDomain: String, DomainProtocol, Sendable {
    /// Screen-level lifecycle events
    case screen = "screen"

    /// Application-level lifecycle events
    case app = "app"

    /// Component-level lifecycle events
    case component = "component"

    /// Session-level lifecycle events
    case session = "session"
}

/// Lifecycle action types representing different stages of an object's lifetime.
public enum LifecycleAction: String, ActionProtocol, Sendable {
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
