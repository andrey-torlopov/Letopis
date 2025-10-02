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

`Letopis` — это легковесный модуль для логирования и трейсинга, который позволяет описывать события приложения через декларативный API и доставлять их через цепочку интерцепторов. Пакет не имеет внешних зависимостей, поэтому может использоваться на любом уровне вашего кода.

## Ключевые возможности

- **Единая точка входа для логирования** — один фасад для консоли, сети и аналитики
- **Расширяемая архитектура через интерцепторы** — гибкая фильтрация и маршрутизация событий
- **Гибкое управление сетевым трафиком** — умное буферизование и приоритизация
- **Адаптация к внешним условиям** — динамическая настройка без изменения ядра

## Быстрый старт

```swift
import Letopis

// Определите типы событий
enum AppEventType: String, EventTypeProtocol {
    case userAction = "user_action"
    case apiCall = "api_call"
}

// Инициализируйте логгер
let logger = Letopis(
    interceptors: [ConsoleInterceptor()]
)

// Используйте
logger
    .event(AppEventType.userAction)
    .payload(["screen": "profile"])
    .info("Пользователь открыл экран профиля")
```

## Документация

- 📦 [Установка](Docs/ru/installation.md)
- 🚀 [Быстрый старт](Docs/ru/quick-start.md)
- 📖 [Полная документация](Docs/ru/index.md)

## Примеры использования

```swift
// Логирование с приоритетом
logger
    .event(.apiCall)
    .priority(.critical)
    .error("Сетевой запрос не выполнен")

// Маскирование чувствительных данных
logger
    .payload(["password": "secret123"])
    .sensitive()
    .info("Пользователь вошел в систему")
```

## Лицензия

Этот проект лицензирован под MIT License — подробности см. в файле [LICENSE](LICENSE).
