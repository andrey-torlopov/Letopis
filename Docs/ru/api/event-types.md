## Пользовательские типы событий

Вы можете создавать собственные типы событий, соответствуя протоколам:

```swift
enum CustomEventType: String, EventTypeProtocol {
    case authentication = "auth"
    case dataSync = "data_sync"
    case featureFlag = "feature_flag"
}

enum CustomAction: String, EventActionProtocol {
    case enable = "enable"
    case disable = "disable"
    case refresh = "refresh"
}
```

## Использование пользовательских типов

```swift
logger
    .event(CustomEventType.authentication)
    .action(CustomAction.enable)
    .info("Двухфакторная аутентификация включена")
```

## Пример: Действия экрана

```swift
public enum ScreenAction: String, EventActionProtocol, Sendable {
    case open
    case close
}

public enum AppEventType: String, EventTypeProtocol, Sendable {
    case uiAction = "ui_action"
    case businessLogic = "business_logic"
}
```

## Лучшие практики

- Используйте перечисления со строковыми значениями для типобезопасности
- Делайте типы соответствующими `Sendable` при работе с акторами
- Выбирайте описательные имена, отражающие вашу предметную область
- Поддерживайте согласованность таксономии событий во всем приложении

---

[Назад к индексу документации](../index.md)
