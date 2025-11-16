# Sensitive Data Masking

Letopis provides built-in support for masking sensitive information in log payloads to prevent accidental exposure of passwords, tokens, API keys, and other confidential data.

> **Important:** As of November 2025, sensitive data masking is **enabled by default** for all globally configured sensitive keys. Use `.notSensitive()` to explicitly disable masking when needed.

## Masking Strategies

Four masking strategies are available via `SensitiveDataStrategy`:

### `.full`
Replaces the entire value with `***`

```swift
"secret123" → "***"
```

### `.partial`
Keeps first and last character, masks the rest

```swift
"secret123" → "s***3"
```

### `.email`
Masks the username part of an email

```swift
"user@example.com" → "u***@example.com"
```

### `.last4`
Shows only the last 4 characters (useful for card numbers)

```swift
"1234567890123456" → "***3456"
```

## Global Sensitive Keys

Configure sensitive keys globally when creating the logger:

```swift
let logger = Letopis(
    interceptors: [ConsoleInterceptor()],
    sensitiveKeys: ["password", "token", "api_key", "ssn"]
)

// Add more keys dynamically
logger.addSensitiveKeys(["credit_card", "secret"])

// Remove keys if needed
logger.removeSensitiveKeys(["api_key"])
```

Global keys use the `.partial` strategy by default.

## Default Behavior (November 2025+)

**Masking is now enabled by default.** Any keys in the global `sensitiveKeys` list are automatically masked:

```swift
let logger = Letopis(
    interceptors: [ConsoleInterceptor()],
    sensitiveKeys: ["password", "token"]
)

// Masking happens automatically - no .sensitive() call needed
logger.log()
    .payload(["password": "secret123", "username": "john"])
    .info("User logged in")

// Output: password=s***3, username=john ✅ password is masked by default
```

### Disabling Masking

Use `.notSensitive()` to explicitly disable masking for specific logs:

```swift
logger.log()
    .payload(["password": "secret123", "token": "abc123"])
    .notSensitive()  // Disable masking for this log only
    .info("Debug authentication flow")

// Output: password=secret123, token=abc123 (shown in plain text)
```

> **Warning:** Only use `.notSensitive()` in development/debugging scenarios. Production logs should keep default masking enabled.

## Per-Log Masking

### Mask Specific Keys with Custom Strategies

```swift
logger.log()
    .payload(["email": "user@example.com", "card": "1234567890123456"])
    .sensitive(key: "email", strategy: .email)
    .sensitive(key: "card", strategy: .last4)
    .info("Payment processed")

// Output: email=u***@example.com, card=***3456
```

### Mask Multiple Keys with Same Strategy

```swift
logger.log()
    .payload(["token": "abc123", "refresh_token": "xyz789"])
    .sensitive(keys: ["token", "refresh_token"], strategy: .full)
    .info("Auth completed")

// Output: token=***, refresh_token=***
```

## Important Notes

- **Masking is enabled by default** for all keys in the global `sensitiveKeys` list (as of November 2025)
- Use `.notSensitive()` to explicitly disable masking for specific log events
- Custom key strategies (via `.sensitive(keys:strategy:)`) take precedence over global sensitive keys
- Masking happens before the event reaches interceptors
- Source metadata (`source_file`, `source_function`, etc.) is never masked

## Best Practices

1. **Define sensitive keys early**: Configure global keys at logger initialization
2. **Use appropriate strategies**: Choose masking strategies that balance security and debugging
3. **Review logs regularly**: Ensure no sensitive data leaks through
4. **Document sensitive fields**: Keep a list of fields that should always be masked
5. **Test masking logic**: Verify sensitive data is properly masked in all scenarios

## Common Sensitive Fields

```swift
let logger = Letopis(
    interceptors: [...],
    sensitiveKeys: [
        // Authentication
        "password", "token", "refresh_token", "api_key", "secret",
        
        // Personal Information
        "ssn", "passport", "driver_license",
        
        // Financial
        "credit_card", "cvv", "account_number",
        
        // Health
        "medical_record", "diagnosis"
    ]
)
```

---

[Back to Documentation Index](../index.md)
