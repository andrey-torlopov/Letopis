#if canImport(SwiftUI)
import SwiftUI

/// A ViewModifier that automatically logs SwiftUI view lifecycle events.
///
/// Use this modifier to track when views appear and disappear:
///
/// ```swift
/// struct ProfileView: View {
///     var body: some View {
///         Text("Profile")
///             .modifier(LogLifecycle(name: "ProfileView", logger: .shared))
///     }
/// }
/// ```
///
/// Or use the convenient extension method:
///
/// ```swift
/// ProfileView()
///     .logLifecycle("ProfileView", logger: .shared)
/// ```
public struct LogLifecycle<D: DomainProtocol, A: ActionProtocol>: ViewModifier {
    let name: String
    let logger: Letopis
    let domain: D
    let onAppearAction: A
    let onDisappearAction: A

    /// Creates a lifecycle logging modifier with custom configuration.
    /// - Parameters:
    ///   - name: Display name of the view for logging.
    ///   - logger: Letopis instance to use for logging.
    ///   - domain: Business domain for lifecycle events.
    ///   - onAppearAction: Action name for appear events.
    ///   - onDisappearAction: Action name for disappear events.
    public init(
        name: String,
        logger: Letopis,
        domain: D,
        onAppearAction: A,
        onDisappearAction: A
    ) {
        self.name = name
        self.logger = logger
        self.domain = domain
        self.onAppearAction = onAppearAction
        self.onDisappearAction = onDisappearAction
    }

    public func body(content: Content) -> some View {
        content
            .onAppear {
                logger
                    .domain(domain)
                    .action(onAppearAction)
                    .payload(["view": name])
                    .info("View appeared")
            }
            .onDisappear {
                logger
                    .domain(domain)
                    .action(onDisappearAction)
                    .payload(["view": name])
                    .info("View disappeared")
            }
    }
}

extension View {
    /// Logs lifecycle events (onAppear/onDisappear) for this view with full control.
    /// - Parameters:
    ///   - name: Display name of the view for logging.
    ///   - logger: Letopis instance to use for logging.
    ///   - domain: Business domain for lifecycle events.
    ///   - onAppearAction: Action name for appear events.
    ///   - onDisappearAction: Action name for disappear events.
    /// - Returns: Modified view with lifecycle logging enabled.
    public func logLifecycle<D: DomainProtocol, A: ActionProtocol>(
        _ name: String,
        logger: Letopis,
        domain: D,
        onAppearAction: A,
        onDisappearAction: A
    ) -> some View {
        modifier(LogLifecycle(name: name, logger: logger, domain: domain, onAppearAction: onAppearAction, onDisappearAction: onDisappearAction))
    }

    /// Convenience overload with default domain and actions
    public func logLifecycle(
        _ name: String,
        logger: Letopis,
        domain: any DomainProtocol = DefaultDomain.ui
    ) -> ModifiedContent<Self, LogLifecycle<StringDomain, StringAction>> {
        modifier(LogLifecycle(
            name: name,
            logger: logger,
            domain: domain as? StringDomain ?? domain.value.asDomain,
            onAppearAction: DefaultAction.appeared.value.asAction,
            onDisappearAction: DefaultAction.disappeared.value.asAction
        ))
    }
}

#endif
