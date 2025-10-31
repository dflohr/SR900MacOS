import SwiftUI

@main
struct SR900_SlidingPanels: App {
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
