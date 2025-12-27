# Optional Helpers

Letopis provides optional helper utilities to simplify common logging patterns. These helpers are built on top of the core logging API and are entirely optional - you can use Letopis without them.

## Available Helpers

### 1. `@Logged` - Property Wrapper for State Logging

Automatically logs all read and write operations on properties.

**Example:**
```swift
class UserViewModel {
    let logger = Letopis.shared
    
    @Logged(wrappedValue: nil, "authToken", logger: logger)
    var authToken: String?
    
    // With custom domain and action
    @Logged(wrappedValue: nil, "userID", logger: logger, domain: "auth".asDomain, action: "state_change".asAction)
    var userID: String?
}

// Usage
viewModel.authToken = "abc123"  // Logs: Property updated: old_value=nil, new_value=abc123
let token = viewModel.authToken  // Logs: Property accessed: value=abc123
```

**When to use:**
- Track critical state changes
- Debug data issues
- Audit value modifications

---

### 2. `@LoggedSet` - Write-Only Property Wrapper

Logs only write operations. Better performance for frequently read properties.

**Example:**
```swift
class SettingsManager {
    let logger = Letopis.shared
    
    @LoggedSet(wrappedValue: "light", "theme", logger: logger)
    var currentTheme: String
}

// Usage
settings.currentTheme = "dark"  // Logged
let theme = settings.currentTheme  // NOT logged
```

**When to use:**
- Log only mutations
- High-frequency read properties (e.g., read 1000 times/sec but changed once/min)

---

### 3. `LogLifecycle` - SwiftUI View Lifecycle

Automatically logs SwiftUI view appearance and disappearance.

**Example:**
```swift
struct ProfileView: View {
    let logger = Letopis.shared
    
    var body: some View {
        Text("Profile")
            .logLifecycle("ProfileView", logger: logger)
    }
}

// With custom domain
struct DashboardView: View {
    var body: some View {
        Text("Dashboard")
            .logLifecycle("DashboardView", logger: .shared, domain: "analytics.screens".asDomain)
    }
}

// Using modifier directly for full control
struct SettingsView: View {
    var body: some View {
        Text("Settings")
            .modifier(
                LogLifecycle(
                    name: "SettingsView",
                    logger: .shared,
                    domain: "ui.navigation".asDomain,
                    onAppearAction: "screen_shown".asAction,
                    onDisappearAction: "screen_hidden".asAction
                )
            )
    }
}
```

**When to use:**
- Screen analytics
- User navigation tracking
- Lifecycle debugging

---

### 4. `logged()` - Scope-Based Operation Logging

Automatically logs start, completion, and errors for operations.

**Example:**
```swift
class DataService {
    let logger = Letopis.shared
    
    // Async throwing operation
    func fetchUserData() async throws -> String {
        return try await Letopis.logged(
            "fetchUserData",
            logger: logger,
            domain: "api".asDomain,
            startAction: "request_started".asAction,
            completeAction: "request_completed".asAction,
            errorAction: "request_failed".asAction
        ) {
            try await apiClient.fetch()
        }
    }
    
    // Using convenience global function
    func syncData() async throws {
        try await logged("syncData", logger: logger, domain: "sync".asDomain) {
            try await Task.sleep(nanoseconds: 500_000_000)
        }
    }
    
    // Non-throwing async operation
    func loadCache() async -> [String] {
        return await logged("loadCache", logger: logger, domain: "cache".asDomain) {
            await cache.load()
        }
    }
    
    // Synchronous throwing operation
    func parseJSON(_ data: String) throws -> [String: Any] {
        return try logged("parseJSON", logger: logger, domain: "parsing".asDomain) {
            try JSONSerialization.jsonObject(with: data)
        }
    }
}
```

**Logs generated:**
```
DEBUG [async] Operation started: operation=fetchUserData
DEBUG [async] Operation completed: operation=fetchUserData
// or
ERROR [async] Operation failed: operation=fetchUserData, error=Network timeout
```

**When to use:**
- Async operations
- API calls tracking
- Long-running operations
- Error-prone operations

---

### 5. Publisher Extensions - Combine Logging

Automatic logging for Combine publishers.

**Example:**
```swift
import Combine

class NetworkManager {
    let logger = Letopis.shared
    private var cancellables = Set<AnyCancellable>()
    
    // Full logging (subscription, output, completion, cancel)
    func fetchData() {
        dataPublisher
            .logged("fetchData", logger: logger, domain: "network".asDomain)
            .sink { completion in
                // handle completion
            } receiveValue: { value in
                // handle value
            }
            .store(in: &cancellables)
    }
    
    // Log only errors
    func fetchWithErrorLogging() {
        dataPublisher
            .logErrors("fetchData", logger: logger)
            .sink { completion in
                // handle completion
            } receiveValue: { value in
                // handle value
            }
            .store(in: &cancellables)
    }
    
    // Log only lifecycle (without values)
    func streamWithLifecycle() {
        dataStream
            .logLifecycle("dataStream", logger: logger)
            .sink { value in
                // handle value
            }
            .store(in: &cancellables)
    }
    
    // Custom actions for different events
    func customPublisherLogging() {
        dataPublisher
            .logged(
                "customPublisher",
                logger: logger,
                domain: "custom".asDomain,
                subscribeAction: "observer_attached".asAction,
                outputAction: "data_received".asAction,
                completionAction: "stream_ended".asAction,
                logOutput: true
            )
            .sink { _ in }
            .store(in: &cancellables)
    }
}
```

**When to use:**
- Debug Combine chains
- Track reactive data flows
- Audit publisher events

---

## Integration with Letopis

All helpers use the unified Letopis API and support:

- ✅ Custom domain and action
- ✅ Payload with metadata
- ✅ Sensitive data masking
- ✅ Correlation ID for related events
- ✅ All severity types (debug, info, warning, error, fault)

## Best Practices

### 1. Create a shared logger instance

```swift
extension Letopis {
    static let shared = Letopis(
        interceptors: [ConsoleInterceptor()],
        sensitiveKeys: ["password", "token", "apiKey"]
    )
}
```

### 2. Use meaningful names

```swift
@Logged(wrappedValue: nil, "userAuthToken", logger: .shared)  // ✅ Good
@Logged(wrappedValue: nil, "x", logger: .shared)              // ❌ Bad
```

### 3. Choose the right domain

```swift
.logged("fetchUser", logger: .shared, domain: "api".asDomain)      // ✅ API calls
.logged("parseData", logger: .shared, domain: "parsing".asDomain)  // ✅ Data processing
.logged("saveCache", logger: .shared, domain: "cache".asDomain)    // ✅ Cache operations
```

### 4. Use @LoggedSet for frequent operations

```swift
// If property is read 1000 times/sec but changed once/min
@LoggedSet(wrappedValue: 0, "frameCount", logger: .shared)  // ✅ Log only changes
```

### 5. Don't over-log

```swift
// ❌ Bad: Logging every array access
@Logged(wrappedValue: [], "items", logger: .shared)
var items: [String]

// Every iteration logs:
for item in viewModel.items { ... }  // Logged 100 times!

// ✅ Better: Use @LoggedSet or log manually when needed
@LoggedSet(wrappedValue: [], "items", logger: .shared)
var items: [String]
```

## Performance Tips

- **`@LoggedSet` is faster than `@Logged`** for frequently read properties
- **`.logLifecycle()` doesn't log each output** in Combine publishers
- **All logging happens asynchronously** via `Task.detached` - no blocking
- **Use `.logErrors()` instead of `.logged()`** in Combine when you only care about failures

## Complete Examples

For complete, runnable examples of all helpers, see:
- [`Sources/Letopis/Examples/HelpersExample.swift`](../../Sources/Letopis/Examples/HelpersExample.swift)

## Implementation Details

All helpers are located in:
- [`Sources/Letopis/Helpers/Logged.swift`](../../Sources/Letopis/Helpers/Logged.swift) - Property wrappers
- [`Sources/Letopis/Helpers/LogLifecycle.swift`](../../Sources/Letopis/Helpers/LogLifecycle.swift) - SwiftUI lifecycle
- [`Sources/Letopis/Helpers/LoggedOperation.swift`](../../Sources/Letopis/Helpers/LoggedOperation.swift) - Operation logging
- [`Sources/Letopis/Helpers/Publisher+Logging.swift`](../../Sources/Letopis/Helpers/Publisher+Logging.swift) - Combine extensions
