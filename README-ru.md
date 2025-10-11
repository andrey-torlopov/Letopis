<p align="center">
  <img src="Docs/banner.png" alt="Letopis Logo" width="600"/>
</p>

<p align="center">
  <a href="https://swift.org">
    <img src="https://img.shields.io/badge/Swift-6.2-orange.svg?logo=swift" />
  </a>
  <a href="https://swift.org/package-manager/">
    <img src="https://img.shields.io/badge/SPM-compatible-green.svg" />
  </a>
  <img src="https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20Linux-blue.svg" />
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-lightgrey.svg" />
  </a>
</p>

# Letopis

*Читать на других языках: [English](README.md)*

`Letopis` — это легковесный модуль для логирования и трейсинга, который позволяет описывать события приложения через простой и интуитивный API. Пакет предлагает два подхода: прямые методы для повседневного использования и опциональный fluent DSL для более выразительных сценариев. Все события доставляются через цепочку интерцепторов без внешних зависимостей.

## Ключевые возможности

- **Простой и интуитивный API** — прямые методы (`info`, `warning`, `error` и т.д.) для обычных задач логирования
- **Опциональный DSL синтаксис** — выразительный fluent API для продвинутых сценариев
- **Единая точка входа для логирования** — один фасад для консоли, сети и аналитики
- **Расширяемая архитектура через интерцепторы** — гибкая фильтрация и маршрутизация событий
- **Гибкое управление сетевым трафиком** — умное буферизование и приоритизация
- **Адаптация к внешним условиям** — динамическая настройка без изменения ядра

## Быстрый старт

```swift
import Letopis

// Определите типы событий (опционально)
enum AppEventType: String, EventTypeProtocol {
    case userAction = "user_action"
    case apiCall = "api_call"
}

enum UserAction: String, EventActionProtocol {
    case screenOpen = "screen_open"
    case buttonTap = "button_tap"
}

// Инициализируйте логгер
let logger = Letopis(
    interceptors: [ConsoleInterceptor()]
)

// Простое использование - просто залогируйте сообщение
logger.info("Пользователь открыл экран профиля")

// Добавьте метаданные через опциональные параметры
logger.info(
    "Пользователь открыл экран профиля",
    payload: ["screen": "profile", "user_id": "123"],
    eventType: AppEventType.userAction,
    eventAction: UserAction.screenOpen
)
```

## Документация

- 📦 [Установка](Docs/ru/installation.md)
- 🚀 [Быстрый старт](Docs/ru/quick-start.md)
- 📖 [Полная документация](Docs/ru/index.md)

## Примеры использования

### Стандартный API (рекомендуется)

```swift
// Информационное логирование
logger.info("Приложение запущено")

// Предупреждение с метаданными
logger.warning(
    "Приближение к лимиту API",
    payload: ["remaining": "10", "limit": "100"]
)

// Логирование ошибок (критично по умолчанию)
logger.error("Сетевой запрос не выполнен", eventType: .apiCall)

// Отладочное логирование с информацией о местоположении в коде
logger.debug("Попадание в кеш", payload: ["key": "user_profile"], includeSource: true)
// Автоматически захватывает файл, функцию и номер строки

// События аналитики
logger.analytics(
    "Покупка завершена",
    payload: ["item_id": "12345", "price": "9.99"]
)
```

### Опциональный DSL API

Для пользователей, предпочитающих цепочечный синтаксис:

```swift
// Цепочка методов с DSL
logger.log()
    .event(.apiCall)
    .payload(["endpoint": "/users"])
    .critical()
    .error("Сетевой запрос не выполнен")

// Маскирование чувствительных данных
logger.log()
    .payload(["password": "secret123"])
    .sensitive(keys: ["password"])
    .info("Пользователь вошел в систему")

// Добавление информации о местоположении в коде
logger.log()
    .source()
    .debug("Значение переменной в этой точке")
```

## Лицензия

Этот проект лицензирован под MIT License — подробности см. в файле [LICENSE](LICENSE).
