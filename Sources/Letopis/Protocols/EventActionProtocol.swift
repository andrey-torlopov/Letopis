import Foundation

public protocol EventActionProtocol {
    var value: String { get }
}

extension EventActionProtocol where Self: RawRepresentable, Self.RawValue == String {
    public var value: String { rawValue }
}
