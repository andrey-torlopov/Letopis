import Foundation

public protocol ActionProtocol {
    var value: String { get }
}

extension ActionProtocol where Self: RawRepresentable, Self.RawValue == String {
    public var value: String { rawValue }
}
