import SwiftUI

@main
struct SR900MacOS: App {
    init() {
        // Register custom fonts for macOS
        registerCustomFonts()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
