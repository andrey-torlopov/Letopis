## Интеграция в пакет

При создании пакета с Letopis в качестве зависимости определите специфичные для предметной области типы событий:

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
            .info("Пользователь открыл главный экран")
        
        logger
            .event(AppEventType.businessLogic)
            .payload(["operation": "data_sync", "records_count": "150"])
            .source()
            .info("Обработка данных пользователя")
        
        Thread.sleep(forTimeInterval: 2.0)
    }
}
```

## Интеграция с сервисами аналитики

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

// Настройка
let logger = Letopis(interceptors: [
    ConsoleInterceptor(),
    MixpanelInterceptor(mixpanel: Mixpanel.mainInstance())])
```

## Интеграция с отчетами о сбоях

```swift
import Letopis
import FirebaseCrashlytics

final class CrashlyticsInterceptor: LetopisInterceptor {
    func handle(_ logEvent: LogEvent) {
        // Логировать все ошибки в Crashlytics
        if logEvent.type == .error {
            Crashlytics.crashlytics().log(logEvent.message)
            
            // Записать пользовательские ключи
            for (key, value) in logEvent.payload {
                Crashlytics.crashlytics().setCustomValue(value, forKey: key)
            }
        }
    }
}

// Настройка
let logger = Letopis(interceptors: [
    ConsoleInterceptor(),
    CrashlyticsInterceptor()])
```

## Интеграция с Core Data

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

## Интеграция с SwiftUI

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
        Button("Залогировать событие") {
            appLogger.logger
                .event("button_tap")
                .info("Кнопка была нажата")
        }
    }
}
```

---

[Назад к индексу документации](../index.md)
