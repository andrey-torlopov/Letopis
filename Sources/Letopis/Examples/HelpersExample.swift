import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(Combine)
import Combine
#endif

// MARK: - Example: Property Wrapper Helpers

/// Example demonstrating the @Logged property wrapper for automatic state logging.
///
/// The @Logged wrapper automatically logs get/set operations on properties.
class UserViewModel {
    let logger = Letopis(interceptors: [ConsoleInterceptor()])

    // Logs every access and mutation of the token property
    @Logged(wrappedValue: nil, "authToken", logger: Letopis(interceptors: [ConsoleInterceptor()]))
    var authToken: String?

    // Custom domain and action for business-critical state
    @Logged(wrappedValue: nil, "userID", logger: Letopis(interceptors: [ConsoleInterceptor()]), domain: "auth".asDomain, action: "state_change".asAction)
    var userID: String?

    func authenticate() {
        // These assignments will automatically log:
        // "Property updated: old_value=nil, new_value=abc123"
        authToken = "abc123"
        userID = "user_001"
    }
}

/// Example demonstrating the @LoggedSet property wrapper.
///
/// Use @LoggedSet when you only want to log mutations, not reads (better performance).
class SettingsManager {
    let logger = Letopis(interceptors: [ConsoleInterceptor()])

    // Only logs when the value is set, not when read
    @LoggedSet(wrappedValue: "light", "theme", logger: Letopis(interceptors: [ConsoleInterceptor()]))
    var currentTheme: String

    @LoggedSet(wrappedValue: "en", "language", logger: Letopis(interceptors: [ConsoleInterceptor()]))
    var language: String

    func updateSettings() {
        currentTheme = "dark"  // Logged
        language = "ru"        // Logged

        let _ = currentTheme   // NOT logged
    }
}

// MARK: - Example: SwiftUI Lifecycle Logging

#if canImport(SwiftUI)

/// Example demonstrating automatic SwiftUI view lifecycle logging.
struct ProfileView: View {
    let logger = Letopis(interceptors: [ConsoleInterceptor()])

    var body: some View {
        VStack {
            Text("User Profile")
        }
        // Automatically logs when view appears/disappears
        .logLifecycle("ProfileView", logger: logger)
    }
}

/// Example with custom domain for lifecycle events.
struct DashboardView: View {
    let logger = Letopis(interceptors: [ConsoleInterceptor()])

    var body: some View {
        VStack {
            Text("Dashboard")
        }
        // Custom domain for business analytics
        .logLifecycle("DashboardView", logger: logger, domain: "analytics.screens".asDomain)
    }
}

/// Example using the modifier directly for more control.
struct SettingsView: View {
    let logger = Letopis(interceptors: [ConsoleInterceptor()])

    var body: some View {
        VStack {
            Text("Settings")
        }
        .modifier(
            LogLifecycle(
                name: "SettingsView",
                logger: logger,
                domain: "ui.navigation".asDomain,
                onAppearAction: "screen_shown".asAction,
                onDisappearAction: "screen_hidden".asAction
            )
        )
    }
}

#endif

// MARK: - Example: Async Operation Logging

/// Example demonstrating automatic logging of async operations.
class DataService {
    let logger = Letopis(interceptors: [ConsoleInterceptor()])

    // Using the static method on Letopis
    func fetchUserData() async throws -> String {
        return try await Letopis.logged(
            "fetchUserData",
            logger: logger,
            domain: "api".asDomain,
            startAction: "request_started".asAction,
            completeAction: "request_completed".asAction,
            errorAction: "request_failed".asAction
        ) {
            // Simulate API call
            try await Task.sleep(nanoseconds: 1_000_000_000)
            return "User data"
        }
    }

    // Using the global convenience function
    func syncData() async throws {
        try await logged("syncData", logger: logger, domain: "sync".asDomain) {
            try await Task.sleep(nanoseconds: 500_000_000)
        }
    }

    // Non-throwing async operation
    func loadCache() async -> [String] {
        return await logged("loadCache", logger: logger, domain: "cache".asDomain) {
            try? await Task.sleep(nanoseconds: 100_000_000)
            return ["cached_item_1", "cached_item_2"]
        }
    }

    // Synchronous operation logging
    func parseJSON(_ data: String) throws -> [String: Any] {
        return try logged("parseJSON", logger: logger, domain: "parsing".asDomain) {
            // Simulate JSON parsing
            if data.isEmpty {
                throw NSError(domain: "ParsingError", code: 1)
            }
            return ["key": "value"]
        }
    }
}

// MARK: - Example: Combine Publisher Logging

#if canImport(Combine)

/// Example demonstrating automatic logging of Combine publishers.
class NetworkManager {
    let logger = Letopis(interceptors: [ConsoleInterceptor()])
    private var cancellables = Set<AnyCancellable>()

    // Full lifecycle logging (subscription, output, completion, cancel)
    func fetchDataWithFullLogging() {
        Just("Sample data")
            .delay(for: 1.0, scheduler: RunLoop.main)
            .logged("fetchData", logger: logger, domain: "network".asDomain)
            .sink { completion in
                print("Completed: \(completion)")
            } receiveValue: { value in
                print("Received: \(value)")
            }
            .store(in: &cancellables)
    }

    // Log only errors
    func fetchDataWithErrorLogging() {
        Fail<String, Error>(error: NSError(domain: "NetworkError", code: 404))
            .logErrors("fetchDataWithError", logger: logger, domain: "network".asDomain)
            .sink { completion in
                print("Completed: \(completion)")
            } receiveValue: { value in
                print("Received: \(value)")
            }
            .store(in: &cancellables)
    }

    // Log only lifecycle (no output values)
    func streamWithLifecycleLogging() {
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .logLifecycle("timerStream", logger: logger, domain: "streams".asDomain)
            .sink { value in
                print("Timer: \(value)")
            }
            .store(in: &cancellables)
    }

    // Custom actions for different events
    func customPublisherLogging() {
        Just("data")
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

#endif

// MARK: - Example: Real-World Usage Scenarios

/// Example: Authentication flow with comprehensive logging
class AuthenticationService {
    let logger = Letopis(interceptors: [ConsoleInterceptor()])

    @Logged(wrappedValue: nil, "accessToken", logger: Letopis(interceptors: [ConsoleInterceptor()]), domain: "auth".asDomain, action: "token_updated".asAction)
    private var accessToken: String?

    @Logged(wrappedValue: nil, "refreshToken", logger: Letopis(interceptors: [ConsoleInterceptor()]), domain: "auth".asDomain, action: "token_updated".asAction)
    private var refreshToken: String?

    @LoggedSet(wrappedValue: nil, "userId", logger: Letopis(interceptors: [ConsoleInterceptor()]), domain: "auth".asDomain, action: "user_identified".asAction)
    var userId: String?

    func login(username: String, password: String) async throws {
        let tokens = try await logged("login", logger: logger, domain: "auth".asDomain) {
            // Simulate API call
            try await Task.sleep(nanoseconds: 500_000_000)
            return (access: "access_token_123", refresh: "refresh_token_456")
        }

        // These assignments are automatically logged
        accessToken = tokens.access
        refreshToken = tokens.refresh
        userId = username
    }

    func refreshAccessToken() async throws {
        let newToken = try await logged("refreshToken", logger: logger, domain: "auth".asDomain) {
            guard refreshToken != nil else {
                throw NSError(domain: "AuthError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No refresh token"])
            }
            try await Task.sleep(nanoseconds: 300_000_000)
            return "new_access_token_789"
        }

        accessToken = newToken
    }
}

/// Example: E-commerce cart with state tracking
class ShoppingCart {
    let logger = Letopis(interceptors: [ConsoleInterceptor()])

    @Logged(wrappedValue: [], "items", logger: Letopis(interceptors: [ConsoleInterceptor()]), domain: "cart".asDomain, action: "items_changed".asAction)
    private var items: [String]

    @Logged(wrappedValue: 0.0, "total", logger: Letopis(interceptors: [ConsoleInterceptor()]), domain: "cart".asDomain, action: "total_updated".asAction)
    private var totalPrice: Double

    func addItem(_ item: String, price: Double) async {
        await Letopis.logged("addItem", logger: logger, domain: "cart".asDomain, operation: {
            self.items.append(item)
            self.totalPrice += price
        } as () async -> Void)
    }

    func checkout() async throws {
        try await logged("checkout", logger: logger, domain: "payment".asDomain) {
            guard !items.isEmpty else {
                throw NSError(domain: "CartError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cart is empty"])
            }
            try await Task.sleep(nanoseconds: 1_000_000_000)
            items.removeAll()
            totalPrice = 0.0
        }
    }
}

// MARK: - Example Usage in Real App

func demonstrateHelpers() async {
    print("=== Letopis Helpers Demo ===\n")

    // Property wrapper example
    print("1. Property Wrapper:")
    let viewModel = UserViewModel()
    viewModel.authenticate()

    // Settings example
    print("\n2. Settings Manager:")
    let settings = SettingsManager()
    settings.updateSettings()

    // Async operation example
    print("\n3. Async Operations:")
    let dataService = DataService()
    do {
        let data = try await dataService.fetchUserData()
        print("Fetched: \(data)")
    } catch {
        print("Error: \(error)")
    }

    // Authentication flow example
    print("\n4. Authentication Flow:")
    let auth = AuthenticationService()
    do {
        try await auth.login(username: "john_doe", password: "secret")
        try await auth.refreshAccessToken()
    } catch {
        print("Auth error: \(error)")
    }

    // Shopping cart example
    print("\n5. Shopping Cart:")
    let cart = ShoppingCart()
    await cart.addItem("iPhone", price: 999.0)
    await cart.addItem("AirPods", price: 249.0)
    do {
        try await cart.checkout()
    } catch {
        print("Checkout error: \(error)")
    }
}
