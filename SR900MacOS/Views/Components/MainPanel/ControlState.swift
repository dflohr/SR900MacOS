import Foundation
import Combine

class ControlState: ObservableObject {
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
    @Published var beanTempValue: Int = 0
    @Published var fanMotorLevel: Double = 0
    @Published var heatLevel: Double = 0
    @Published var roastingTime: Double = 0
    @Published var coolingTime: Double = 0
    @Published var roastInProcess: Bool = false
    @Published var coolInProcess: Bool = false
    
    let temperatureUnit: String = " F"
    
    func updateBeanTemp() {
        beanTempValue -= 1
    }
}


/*
import Foundation
import Combine

class ControlState: ObservableObject {
    @Published var beanTempValue: Int = 0
}
*/
