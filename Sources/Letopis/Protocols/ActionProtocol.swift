import Foundation

public protocol ActionProtocol {
    var value: String { get }
}

extension ActionProtocol where Self: RawRepresentable, Self.RawValue == String {
    public var value: String { rawValue }
}

///// Allows String literals to be used as actions for convenience
//extension String: ActionProtocol {
//    // No need to implement value here - will be provided by shared extension
//}
