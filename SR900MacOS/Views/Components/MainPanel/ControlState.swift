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
    @Published var fanMotorLevel: Double = 0 {
        didSet {
            handleSliderChange(for: .fanMotor, oldValue: oldValue, newValue: fanMotorLevel)
        }
    }
    @Published var heatLevel: Double = 0 {
        didSet {
            handleSliderChange(for: .heat, oldValue: oldValue, newValue: heatLevel)
        }
    }
    @Published var roastingTime: Double = 0
    @Published var coolingTime: Double = 0
    @Published var roastInProcess: Bool = false
    @Published var coolInProcess: Bool = false
    
    let temperatureUnit: String = " F"
    
    // MARK: - Debouncing Properties
    private var fanMotorDebounceTimer: Timer?
    private var heatLevelDebounceTimer: Timer?
    private let debounceDelay: TimeInterval = 0.50
    
    // Callback closure to send updates to the roaster
    var onSliderUpdateDebounced: ((SliderType, Double) -> Void)?
    
    enum SliderType {
        case fanMotor
        case heat
    }
    
    // MARK: - Functions
    
    func updateBeanTemp() {
        beanTempValue -= 1
    }
    
    /// Handle slider value changes with debouncing when roast is in process
    private func handleSliderChange(for sliderType: SliderType, oldValue: Double, newValue: Double) {
        // During cooling phase, only allow fan motor changes, block heat changes
        if coolInProcess && sliderType == .heat {
            print("⚠️ Ignoring heat level change during cooling phase")
            return
        }
        
        // Only debounce if roast is in process and value actually changed
        guard roastInProcess, oldValue != newValue else {
            // If roast is not in process, send update immediately
            if !roastInProcess && oldValue != newValue {
                onSliderUpdateDebounced?(sliderType, newValue)
            }
            return
        }
        
        // Cancel existing timer for this slider
        switch sliderType {
        case .fanMotor:
            fanMotorDebounceTimer?.invalidate()
            fanMotorDebounceTimer = Timer.scheduledTimer(withTimeInterval: debounceDelay, repeats: false) { [weak self] _ in
                guard let self = self else { return }
                self.onSliderUpdateDebounced?(.fanMotor, self.fanMotorLevel)
                print("⏱️ Debounced fan motor level update: \(self.fanMotorLevel)")
            }
            
        case .heat:
            heatLevelDebounceTimer?.invalidate()
            heatLevelDebounceTimer = Timer.scheduledTimer(withTimeInterval: debounceDelay, repeats: false) { [weak self] _ in
                guard let self = self else { return }
                self.onSliderUpdateDebounced?(.heat, self.heatLevel)
                print("⏱️ Debounced heat level update: \(self.heatLevel)")
            }
        }
    }
    
    /// Cancel all pending debounce timers (useful when stopping roast)
    func cancelPendingSliderUpdates() {
        fanMotorDebounceTimer?.invalidate()
        fanMotorDebounceTimer = nil
        heatLevelDebounceTimer?.invalidate()
        heatLevelDebounceTimer = nil
        print("🚫 Cancelled all pending slider updates")
    }
    
    deinit {
        cancelPendingSliderUpdates()
    }
}


/*
import Foundation
import Combine

class ControlState: ObservableObject {
    @Published var beanTempValue: Int = 0
}
*/
