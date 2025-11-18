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
            // Only trigger slider change handling if change is from user input
            // When isUpdatingFromRoaster is true, the change is from a 0x21 status message
            // and should NOT trigger a 0x15 manual roast message
            if !isUpdatingFromRoaster {
                handleSliderChange(for: .fanMotor, oldValue: oldValue, newValue: fanMotorLevel)
            }
        }
    }
    @Published var heatLevel: Double = 0 {
        didSet {
            // Only trigger slider change handling if change is from user input
            // When isUpdatingFromRoaster is true, the change is from a 0x21 status message
            // and should NOT trigger a 0x15 manual roast message
            if !isUpdatingFromRoaster {
                handleSliderChange(for: .heat, oldValue: oldValue, newValue: heatLevel)
            }
        }
    }
    @Published var roastingTime: Double = 0
    @Published var coolingTime: Double = 0
    @Published var roastInProcess: Bool = false
    @Published var coolInProcess: Bool = false
    @Published var isProfileRoast: Bool = false  // Track if current roast is a profile roast
    
    /// Flag to prevent slider updates from roaster (0x21 messages) from triggering 0x15 manual roast messages
    /// When true, fan/heat level changes are from the roaster and should NOT send new commands
    /// When false, changes are from user slider interactions and SHOULD send commands (during active roast)
    var isUpdatingFromRoaster: Bool = false
    
    /// Track if sliders have pending updates (during debounce window)
    /// When true, incoming 0x21 status messages should NOT update slider values
    /// This prevents race condition where status overwrites user's value during debounce delay
    private(set) var hasPendingFanUpdate: Bool = false
    private(set) var hasPendingHeatUpdate: Bool = false
    
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
            // CRITICAL: Set pending flag immediately to block incoming 0x21 from overwriting
            hasPendingFanUpdate = true
            print("🛡️ Fan slider pending - ignoring incoming status updates")
            
            // CRITICAL: Capture newValue immediately to prevent race condition
            // If we read self.fanMotorLevel when timer fires, a 0x21 status message
            // could have overwritten it during the debounce delay
            fanMotorDebounceTimer = Timer.scheduledTimer(withTimeInterval: debounceDelay, repeats: false) { [weak self, capturedValue = newValue] _ in
                guard let self = self else { return }
                self.onSliderUpdateDebounced?(.fanMotor, capturedValue)
                print("⏱️ Debounced fan motor level update: \(capturedValue)")
                // Clear pending flag after callback fires
                self.hasPendingFanUpdate = false
            }
            
        case .heat:
            heatLevelDebounceTimer?.invalidate()
            // CRITICAL: Set pending flag immediately to block incoming 0x21 from overwriting
            hasPendingHeatUpdate = true
            print("🛡️ Heat slider pending - ignoring incoming status updates")
            
            // CRITICAL: Capture newValue immediately to prevent race condition
            // If we read self.heatLevel when timer fires, a 0x21 status message
            // could have overwritten it during the debounce delay
            heatLevelDebounceTimer = Timer.scheduledTimer(withTimeInterval: debounceDelay, repeats: false) { [weak self, capturedValue = newValue] _ in
                guard let self = self else { return }
                self.onSliderUpdateDebounced?(.heat, capturedValue)
                print("⏱️ Debounced heat level update: \(capturedValue)")
                // Clear pending flag after callback fires
                self.hasPendingHeatUpdate = false
            }
        }
    }
    
    /// Cancel all pending debounce timers (useful when stopping roast)
    func cancelPendingSliderUpdates() {
        fanMotorDebounceTimer?.invalidate()
        fanMotorDebounceTimer = nil
        hasPendingFanUpdate = false
        
        heatLevelDebounceTimer?.invalidate()
        heatLevelDebounceTimer = nil
        hasPendingHeatUpdate = false
        
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




/*
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
            // Only trigger slider change handling if change is from user input
            // When isUpdatingFromRoaster is true, the change is from a 0x21 status message
            // and should NOT trigger a 0x15 manual roast message
            if !isUpdatingFromRoaster {
                handleSliderChange(for: .fanMotor, oldValue: oldValue, newValue: fanMotorLevel)
            }
        }
    }
    @Published var heatLevel: Double = 0 {
        didSet {
            // Only trigger slider change handling if change is from user input
            // When isUpdatingFromRoaster is true, the change is from a 0x21 status message
            // and should NOT trigger a 0x15 manual roast message
            if !isUpdatingFromRoaster {
                handleSliderChange(for: .heat, oldValue: oldValue, newValue: heatLevel)
            }
        }
    }
    @Published var roastingTime: Double = 0
    @Published var coolingTime: Double = 0
    @Published var roastInProcess: Bool = false
    @Published var coolInProcess: Bool = false
    @Published var isProfileRoast: Bool = false  // Track if current roast is a profile roast
    
    /// Flag to prevent slider updates from roaster (0x21 messages) from triggering 0x15 manual roast messages
    /// When true, fan/heat level changes are from the roaster and should NOT send new commands
    /// When false, changes are from user slider interactions and SHOULD send commands (during active roast)
    var isUpdatingFromRoaster: Bool = false
    
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

*/
