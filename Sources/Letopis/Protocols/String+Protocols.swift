import Foundation

///// Shared implementation of value property for String conforming to both DomainProtocol and ActionProtocol
//extension String {
//    public var value: String { self }
//}

/// A wrapper that allows using String as a DomainProtocol
public struct StringDomain: DomainProtocol {
    public let value: String

    public init(_ value: String) {
        self.value = value
    }
}

/// A wrapper that allows using String as an ActionProtocol
public struct StringAction: ActionProtocol {
    public let value: String

    public init(_ value: String) {
        self.value = value
    }
}

extension String {
    /// Converts String to DomainProtocol
    public var asDomain: StringDomain {
        StringDomain(self)
    }

    /// Converts String to ActionProtocol
    public var asAction: StringAction {
        StringAction(self)
    }
}
