# Default Events

This directory contains predefined domains and actions for common logging scenarios.

## Structure

### CommonDomains.swift
Contains comprehensive enums for typical application logging needs:

- **CommonDomain**: 24 domains covering app, ui, network, auth, database, etc.
- **CommonAction**: 50+ actions covering lifecycle, CRUD, network, user interactions, etc.

### DefaultDomain.swift
Provides convenient typealiases:
- `DefaultDomain` = `CommonDomain`
- `DefaultAction` = `CommonAction`

## Usage

### Using predefined domains and actions:

```swift
logger
    .domain(CommonDomain.network)
    .action(CommonAction.requestSent)
    .info("API request initiated")
```

Or with the convenience typealias:

```swift
logger
    .domain(DefaultDomain.auth)
    .action(DefaultAction.loggedIn)
    .info("User authenticated")
```

### Using custom string values:

```swift
logger
    .domain("custom.module".asDomain)
    .action("custom_event".asAction)
    .info("Custom event")
```

### Creating your own domain/action enums:

```swift
enum MyAppDomain: String, DomainProtocol {
    case payment = "payment"
    case subscription = "subscription"
}

enum MyAppAction: String, ActionProtocol {
    case purchased = "purchased"
    case refunded = "refunded"
}

logger
    .domain(MyAppDomain.payment)
    .action(MyAppAction.purchased)
    .info("Payment processed")
```

## Available Domains

**Core**: app, ui, navigation  
**Data**: network, api, database, parsing, cache  
**User**: auth, user, session  
**Business**: business, validation, state  
**Technical**: error, performance, debug, analytics  
**Reactive**: combine, async  
**System**: fileSystem, system, background  

## Available Actions

**Lifecycle**: started, completed, failed, cancelled, suspended, resumed  
**CRUD**: created, read, updated, deleted  
**Network**: requestSent, responseReceived, connected, disconnected, retried, timedOut  
**User**: clicked, submitted, navigated, searched, loggedIn, loggedOut  
**UI**: appeared, disappeared, loaded, refreshed, rendered  
**Data**: validated, cached, synced, transformed  
**Error**: errorOccurred, errorRecovered, errorLogged  
**Performance**: measured, benchmarkStarted, benchmarkEnded  
**Debug**: checkpoint, inspected, dumped  
**Reactive**: subscribed, emitted, output, streamCompleted  

And many more...
