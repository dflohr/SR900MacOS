import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @StateObject private var bleManager = BLEManager()

    
    var body: some View {
        ZStack {
            // Black background for entire window
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            HStack(spacing: 20) {
                MainControlPanel(
                    viewModel: viewModel,
                    onGraphButtonPressed: viewModel.handleGraphButtonPress,
                    onProfilesButtonPressed: viewModel.handleProfilesButtonPress,
                    onSettingsButtonPressed: viewModel.handleSettingsButtonPress
                )
                .zIndex(2)
                .environmentObject(bleManager)
                SlidingPanelsContainer(viewModel: viewModel)
                    .offset(x: -570)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .onAppear(perform: viewModel.startInitialAnimationSequence)
    }
}

#Preview {
    ContentView()
}
