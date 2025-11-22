import SwiftUI

struct SlidingPanelsContainer: View {
    @ObservedObject var viewModel: ContentViewModel
    @State private var voltageSupply = "AVERAGE"
    @EnvironmentObject var bleManager: BLEManager
    
    var body: some View {
        ZStack {
            SettingsPanel(voltageSupply: $voltageSupply)
                .zIndex(0)
                // keep settings slightly right so it's flush at right edge
                .offset(x: viewModel.rectangle4Offset + 570)
            
            ProfilesPanel(voltageSupply: $voltageSupply)
                .zIndex(1)
                .offset(x: viewModel.rectangle3Offset + 520)
            
            GraphPanel()
                .zIndex(-1)
                // final tuned value for graphWidth = 607
                .offset(x: viewModel.rectangle2Offset + 570)
                .environmentObject(bleManager)
        }
    }
}

// MARK: - Individual Panels
struct GraphPanel: View {
    @EnvironmentObject var bleManager: BLEManager
    @StateObject private var graphManager: GraphDataManager
    
    init() {
        // Note: We can't access @EnvironmentObject in init, so we create a temporary
        // graphManager without controlState, then update it in onAppear
        _graphManager = StateObject(wrappedValue: GraphDataManager(controlState: nil))
    }
    
    var body: some View {
        FramedRectangle(
            number: "2",
            width: 607, // UPDATED width
            imageName: "GraphNew D5-M4",
            onGraphButtonPressed: nil,
            onProfilesButtonPressed: nil,
            onSettingsButtonPressed: nil,
            rectangle2Extended: .constant(false),
            rectangle3Extended: .constant(false),
            rectangle4Extended: .constant(false),
            voltageSupply: nil,
            graphManager: graphManager,
            controlState: bleManager.controlState
        )
        .onAppear {
            // Connect graphManager to controlState when view appears
            if graphManager.controlState == nil {
                graphManager.controlState = bleManager.controlState
            }
        }
    }
}

struct ProfilesPanel: View {
    @Binding var voltageSupply: String
    
    var body: some View {
        FramedRectangle(
            number: "3",
            width: 410,
            imageName: nil,
            onGraphButtonPressed: nil,
            onProfilesButtonPressed: nil,
            onSettingsButtonPressed: nil,
            rectangle2Extended: .constant(false),
            rectangle3Extended: .constant(false),
            rectangle4Extended: .constant(false),
            voltageSupply: $voltageSupply
        )
    }
}

struct SettingsPanel: View {
    @Binding var voltageSupply: String
    
    var body: some View {
        FramedRectangle(
            number: "4",
            width: 410,
            imageName: nil,
            onGraphButtonPressed: nil,
            onProfilesButtonPressed: nil,
            onSettingsButtonPressed: nil,
            rectangle2Extended: .constant(false),
            rectangle3Extended: .constant(false),
            rectangle4Extended: .constant(false),
            voltageSupply: $voltageSupply
        )
    }
}


////
////  SlidingPanelsContainer.swift
////  SR900MacOS
////
////  Created by Nisarg Mangukiya on 01/11/25.
////
//
//
//import SwiftUI
//
//struct SlidingPanelsContainer: View {
//    @ObservedObject var viewModel: ContentViewModel
//    
//    var body: some View {
//        ZStack {
//            SettingsPanel()
//                .zIndex(0)
//                .offset(x: viewModel.rectangle4Offset + 610)
//            
//            ProfilesPanel()
//                .zIndex(1)
//                .offset(x: viewModel.rectangle3Offset + 570)
//            
//            GraphPanel()
//                .zIndex(-1)
//                .offset(x: viewModel.rectangle2Offset + 570)
//        }
//    }
//}
//
//// MARK: - Individual Panels
//struct GraphPanel: View {
//    var body: some View {
//        FramedRectangle(
//            number: "2",
//            width: 510,
//            imageName: "GraphNew D5-M4",
//            onGraphButtonPressed: nil,
//            onProfilesButtonPressed: nil,
//            onSettingsButtonPressed: nil,
//            rectangle2Extended: .constant(false),
//            rectangle3Extended: .constant(false),
//            rectangle4Extended: .constant(false)
//        )
//    }
//}
//
//struct ProfilesPanel: View {
//    var body: some View {
//        FramedRectangle(
//            number: "3",
//            width: 410,
//            imageName: nil,
//            onGraphButtonPressed: nil,
//            onProfilesButtonPressed: nil,
//            onSettingsButtonPressed: nil,
//            rectangle2Extended: .constant(false),
//            rectangle3Extended: .constant(false),
//            rectangle4Extended: .constant(false)
//        )
//    }
//}
//
//struct SettingsPanel: View {
//    var body: some View {
//        FramedRectangle(
//            number: "4",
//            width: 410,
//            imageName: nil,
//            onGraphButtonPressed: nil,
//            onProfilesButtonPressed: nil,
//            onSettingsButtonPressed: nil,
//            rectangle2Extended: .constant(false),
//            rectangle3Extended: .constant(false),
//            rectangle4Extended: .constant(false)
//        )
//    }
//}
