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
            // TEMPORARY: Calibration mode - comment out ContentView
            /*
            GraphCalibrationHelper(
                imageName: "GraphNew D5-M4",  // Your SR900 roast graph image
                imageWidth: 700,
               imageHeight: 600
            )
            .frame(width: 900, height: 1000)
            */
            // Uncomment when done calibrating:
             ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
