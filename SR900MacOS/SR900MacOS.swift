import SwiftUI

@main
struct SR900MacOS: App {
    init() {
        // Register custom fonts for macOS
        registerCustomFonts()
        
        // Verify and create application directories if needed
        AppDataManager.shared.verifyAndCreateDirectories()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
