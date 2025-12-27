/// User interaction domains for UI elements and gestures.
public enum UserDomain: String, DomainProtocol, Sendable {
    /// User interface interactions
    case ui = "ui"

    /// User input and forms
    case input = "user_input"

    /// User navigation
    case navigation = "user_navigation"

    /// User gestures
    case gesture = "user_gesture"
}

/// User action types representing different user interactions.
public enum UserAction: String, ActionProtocol, Sendable {
    /// Single click/tap
    case click = "click"

    /// Long press gesture
    case longPress = "long_press"

    /// Double click/tap
    case doubleClick = "double_click"

    /// Scroll action
    case scroll = "scroll"

    /// Text typing
    case typeText = "type_text"

    /// Form submission
    case submit = "submit"

    /// Swipe left
    case swipeLeft = "swipe_left"

    /// Swipe right
    case swipeRight = "swipe_right"

    /// Swipe up
    case swipeUp = "swipe_up"

    /// Swipe down
    case swipeDown = "swipe_down"

    /// Pull to refresh
    case pullToRefresh = "pull_to_refresh"

    /// Pinch gesture
    case pinch = "pinch"

    /// Rotate gesture
    case rotate = "rotate"
}
