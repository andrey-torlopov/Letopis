# Integration Examples

## Integration in a Package

When creating a package with Letopis as a dependency, define domain-specific event types:

```swift
import Letopis
import Foundation

public enum ScreenAction: String, ActionProtocol, Sendable {
    case open
    case close
}

public enum AppEventType: String, EventTypeProtocol, Sendable {
    case uiAction = "ui_action"
    case businessLogic = "business_logic"
}

@main
struct LetopisDemo {
    static func main() {
        let logger = Letopis(interceptors: [ConsoleInterceptor()])
        
        logger
            .event(AppEventType.uiAction)
            .action(ScreenAction.open)
            .payload(["screen_name": "MainViewController", "user_id": "12345"])
            .source()
            .info("User opened main screen")
        
        logger
            .event(AppEventType.businessLogic)
            .payload(["operation": "data_sync", "records_count": "150"])
            .source()
            .info("Processing user data")
        
        Thread.sleep(forTimeInterval: 2.0)
    }
}
```

## Integration with Analytics Services

```swift
import Letopis

final class MixpanelInterceptor: LetopisInterceptor {
    private let mixpanel: MixpanelInstance
    
    init(mixpanel: MixpanelInstance) {
        self.mixpanel = mixpanel
    }
    
    func handle(_ logEvent: LogEvent) {
        guard logEvent.type == .analytics else { return }
        
        mixpanel.track(
            event: logEvent.message,
            properties: logEvent.payload
        )
    }
}

// Setup
let logger = Letopis(interceptors: [
    ConsoleInterceptor(),
    MixpanelInterceptor(mixpanel: Mixpanel.mainInstance())
])
```

## Integration with Crash Reporting

```swift
import Letopis
import FirebaseCrashlytics

final class CrashlyticsInterceptor: LetopisInterceptor {
    func handle(_ logEvent: LogEvent) {
        // Log all errors to Crashlytics
        if logEvent.type == .error {
            Crashlytics.crashlytics().log(logEvent.message)
            
            // Record custom keys
            for (key, value) in logEvent.payload {
                Crashlytics.crashlytics().setCustomValue(value, forKey: key)
            }
        }
    }
}

// Setup
let logger = Letopis(interceptors: [
    ConsoleInterceptor(),
    CrashlyticsInterceptor()
])
```

## Integration with Core Data

```swift
import Letopis
import CoreData

final class CoreDataInterceptor: LetopisInterceptor {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func handle(_ logEvent: LogEvent) {
        context.perform {
            let entity = LogEntity(context: self.context)
            entity.id = logEvent.id.uuidString
            entity.message = logEvent.message
            entity.timestamp = logEvent.timestamp
            entity.isCritical = logEvent.isCritical
            
            try? self.context.save()
        }
    }
}
```

## SwiftUI Integration

```swift
import SwiftUI
import Letopis

class AppLogger: ObservableObject {
    static let shared = AppLogger()
    
    let logger: Letopis
    
    private init() {
        logger = Letopis(interceptors: [
            ConsoleInterceptor(),
            AnalyticsInterceptor()
        ])
    }
}

struct ContentView: View {
    @StateObject private var appLogger = AppLogger.shared
    
    var body: some View {
        Button("Log Event") {
            appLogger.logger
                .event("button_tap")
                .info("Button was tapped")
        }
    }
}
```

---

[Back to Documentation Index](../index.md)
