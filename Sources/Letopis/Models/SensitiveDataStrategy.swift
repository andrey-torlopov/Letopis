//
//  SensitiveDataStrategy.swift
//  Letopis
//
//  Created by Andrey Torlopov on 02.10.2025.
//

/// Strategy for masking sensitive data in log payloads.
public enum SensitiveDataStrategy {
    /// Replaces entire value with "***"
    case full
    /// Keeps first and last character, masks the rest: "a***d"
    case partial
    /// Masks email username part: "a***@example.com"
    case email
    /// Shows only last 4 characters: "***1234"
    case last4

    /// Applies the masking strategy to a given string value.
    /// - Parameter value: The string value to mask.
    /// - Returns: The masked string according to the strategy.
    func mask(_ value: String) -> String {
        switch self {
        case .full:
            return "***"
        case .partial:
            guard value.count > 2 else { return "***" }
            let first = value.prefix(1)
            let last = value.suffix(1)
            return "\(first)***\(last)"
        case .email:
            guard let atIndex = value.firstIndex(of: "@"), value.count > 2 else { return "***" }
            let first = value.prefix(1)
            let domain = value[atIndex...]
            return "\(first)***\(domain)"
        case .last4:
            guard value.count >= 4 else { return "***" }
            let last4 = value.suffix(4)
            return "***\(last4)"
        }
    }
}
