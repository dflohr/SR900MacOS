import SwiftUI
import Combine

struct MainControlInterface: View {
    let width: CGFloat
    let onGraphButtonPressed: (() -> Void)?
    let onProfilesButtonPressed: (() -> Void)?
    let onSettingsButtonPressed: (() -> Void)?
    
    @Binding var rectangle2Extended: Bool
    @Binding var rectangle3Extended: Bool
    @Binding var rectangle4Extended: Bool
    
    @StateObject private var controlState = MainControlState()
    
    var body: some View {
        let buttonLabels = ["GRAPH", "PROFILES", "SETTINGS", "READ-ME"]
        
        HStack(alignment: .top, spacing: 0) {
            VStack(spacing: 0) {
                HeaderSection()
                ConnectionSection(controlState: controlState)
                TimeInputSection(controlState: controlState)
                ControlButtonsSection(controlState: controlState)
                Spacer()
                DisplaySection(controlState: controlState)
                BottomSection()
            }
            .frame(width: 567, height: 728)
            .background(Color(red: 0.93, green: 0.93, blue: 0.93))
//            .border(Color.black, width: 2)           // ✅ Black border
            .padding()
        }
//        .frame(width: 607)

        
        BottomButtonsBar(
            buttonLabels: buttonLabels,
            width: width,
            onGraphButtonPressed: onGraphButtonPressed,
            onProfilesButtonPressed: onProfilesButtonPressed,
            onSettingsButtonPressed: onSettingsButtonPressed,
            rectangle2Extended: $rectangle2Extended,
            rectangle3Extended: $rectangle3Extended,
            rectangle4Extended: $rectangle4Extended
        )
    }
}

// MARK: - Main Control State
class MainControlState: ObservableObject {
    @Published var displayText: String = ""
    @Published var isConnected: Bool = false
    @Published var isUSBConnected: Bool = false
    @Published var connectionActivityIN: Bool = false
    @Published var connectionActivityOUT: Bool = false
    @Published var selectedButtons: Set<String> = []
    @Published var timeMinutes1: String = "-"
    @Published var timeMinutes2: String = "-"
    @Published var timeSeconds1: String = "-"
    @Published var timeSeconds2: String = "-"
    @Published var showGraphPanel: Bool = false
    @Published var showPanelText: Bool = false
    @Published var showSettingsPanel: Bool = false
    @Published var showSettingsPanelText: Bool = false
    @Published var showProfilesPanel: Bool = false
    @Published var showProfilesPanelText: Bool = false
    @Published var heatingCoolingMode: String = "Heating"
    @Published var beanTempValue: Int = 996
    @Published var fanMotorLevel: Double = 0
    @Published var heatLevel: Double = 0
    @Published var roastingTime: Double = 0
    @Published var coolingTime: Double = 0
    
    let temperatureUnit: String = " F"
    
    func updateBeanTemp() {
        beanTempValue -= 1
    }
}
