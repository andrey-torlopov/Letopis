import Foundation

/// Protocol for types that can be used as log event domains.
///
/// Domains represent business areas or subsystems in your application.
/// Examples: auth, payments, network, ui, analytics
public protocol DomainProtocol {
    /// String value of the domain
    var value: String { get }
}

extension DomainProtocol where Self: RawRepresentable, Self.RawValue == String {
    public var value: String { rawValue }
}
