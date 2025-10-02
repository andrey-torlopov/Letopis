## Определение типов событий

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

## Пример для конкретной предметной области

```swift
// Предметная область электронной коммерции
enum EcommerceEventType: String, EventTypeProtocol {
    case product = "product"
    case cart = "cart"
    case checkout = "checkout"
    case payment = "payment"
}

enum EcommerceAction: String, EventActionProtocol {
    case view = "view"
    case add = "add"
    case remove = "remove"
    case purchase = "purchase"
}

// Использование
logger
    .event(EcommerceEventType.product)
    .action(EcommerceAction.view)
    .payload(["product_id": "12345", "category": "electronics"])
    .analytics("Товар просмотрен")

logger
    .event(EcommerceEventType.cart)
    .action(EcommerceAction.add)
    .payload(["product_id": "12345", "price": "299.99"])
    .analytics("Добавлено в корзину")

logger
    .event(EcommerceEventType.payment)
    .action(EcommerceAction.purchase)
    .priority(.critical)
    .payload(["order_id": "ORD-789", "amount": "299.99"])
    .analytics("Покупка завершена")
```

## Пример навигации по UI

```swift
enum ScreenEventType: String, EventTypeProtocol {
    case navigation = "navigation"
    case userInteraction = "user_interaction"
}

enum ScreenAction: String, EventActionProtocol {
    case open = "open"
    case close = "close"
    case tap = "tap"
    case swipe = "swipe"
}

// Использование
logger
    .event(ScreenEventType.navigation)
    .action(ScreenAction.open)
    .payload(["screen": "ProfileViewController", "from": "HomeViewController"])
    .info("Экран открыт")

logger
    .event(ScreenEventType.userInteraction)
    .action(ScreenAction.tap)
    .payload(["button": "logout", "screen": "ProfileViewController"])
    .info("Кнопка нажата")
```

## Лучшие практики

1. **Используйте значимые имена**: Выбирайте имена, которые четко описывают событие
2. **Поддерживайте согласованность**: Используйте одинаковые типы событий во всем приложении
3. **Делайте расширяемыми**: Проектируйте типы, которые могут расти вместе с приложением
4. **Документируйте ваши типы**: Добавляйте комментарии, объясняющие когда использовать каждый тип
5. **Группируйте связанные типы**: Используйте отдельные перечисления для разных предметных областей

---

[Назад к индексу документации](../index.md)
