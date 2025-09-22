import Foundation

public protocol EventTypeProtocol {
    var value: String { get }
}

extension EventTypeProtocol where Self: RawRepresentable, Self.RawValue == String {
    public var value: String {  rawValue }
}
