# Установка

Letopis можно установить через Swift Package Manager.

## Swift Package Manager

### Через Xcode

Добавьте Letopis в ваш Xcode проект:

1. В Xcode откройте ваш проект и перейдите в **File → Add Package Dependencies...**
2. Введите URL репозитория:
   ```
   https://github.com/yourusername/Letopis.git
   ```
3. Выберите правило версии (рекомендуется: "Up to Next Major Version")
4. Нажмите **Add Package**

### Через Package.swift

Добавьте в зависимости вашего `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/Letopis.git", from: "1.0.0")
]
```

Затем добавьте в ваш таргет:

```swift
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["Letopis"]
    )
]
```

## Системные требования

- Swift 6.2 или выше
- Поддерживаемые платформы: iOS, macOS, Linux

---

[Вернуться к главному README](../../README-ru.md) | [Быстрый старт](quick-start.md)
