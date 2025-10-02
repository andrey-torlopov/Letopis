# Installation

Letopis can be installed via Swift Package Manager.

## Swift Package Manager

### Via Xcode

Add Letopis to your Xcode project:

1. In Xcode, open your project and navigate to **File → Add Package Dependencies...**
2. Enter the repository URL:
   ```
   https://github.com/yourusername/Letopis.git
   ```
3. Select the version rule (recommended: "Up to Next Major Version")
4. Click **Add Package**

### Via Package.swift

Add to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/Letopis.git", from: "1.0.0")
]
```

Then add it to your target:

```swift
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["Letopis"]
    )
]
```

## System Requirements

- Swift 6.2 or higher
- Supported platforms: iOS, macOS, Linux

---

[Back to main README](../../README.md) | [Quick Start](quick-start.md)
