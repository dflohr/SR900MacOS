//
//  Roaster_Status_0x21.swift
//  SR900MacOS
//
//  Handles roaster status and temperature message (0x21)
//

import Foundation

extension IncomingMessageHandler {
    
    /// Handle temperature data message (0x21)
    /// - Parameter bytes: 34-byte message array from BLE
    /// - Note: Bytes[13-14] (fan/heat levels) are ONLY valid when roastInProcess = true
    ///         When roastInProcess = false, these bytes contain unreliable data and are ignored
    func handleStatusMessage(_ bytes: [UInt8]) {
        // TODO: Verify the correct byte positions for SR900 temperature data
        // These byte positions are PLACEHOLDERS - adjust based on SR900 protocol documentation
        
        guard bytes.count >= 10 else {
            print("⚠️ Status message too short: \(bytes.count) bytes")
            return
        }
        
        let rawTemp: Int
        
        // Option 1: If temperature is 16-bit value (2 bytes) - BIG ENDIAN
        rawTemp = (Int(bytes[15]) << 8) | Int(bytes[16])
        
        // Option 2: If temperature is 16-bit value (2 bytes) - LITTLE ENDIAN
        // rawTemp = (Int(bytes[9]) << 8) | Int(bytes[8])
        
        // Option 3: If temperature is single byte value
        // rawTemp = Int(bytes[8])
        
        // Option 4: If temperature needs conversion formula (e.g., Celsius to Fahrenheit)
        // let celsius = (Int(bytes[8]) << 8) | Int(bytes[9])
        // rawTemp = (celsius * 9 / 5) + 32
        
        // Parse fan motor level from byte 13 and heat level from byte 14
        // IMPORTANT: Only parse these bytes when roastInProcess = true
        // When roastInProcess = false, bytes 13-14 contain unreliable data and MUST be ignored
        let fanMotorLevel: Int
        let heatLevel: Int
        
        // Only parse fan and heat levels when roast is in process
        if controlState?.roastInProcess == true {
            if bytes.count > 13 {
                fanMotorLevel = Int(bytes[13])
                print("📊 Status Message (0x21) → Fan Motor Level: \(fanMotorLevel) (from byte[13])")
            } else {
                fanMotorLevel = 0
                print("⚠️ Status message missing fan motor byte (index 13)")
            }
            
            if bytes.count > 14 {
                heatLevel = Int(bytes[14])
                print("📊 Status Message (0x21) → Heat Level: \(heatLevel) (from byte[14])")
            } else {
                heatLevel = 0
                print("⚠️ Status message missing heat level byte (index 14)")
            }
        } else {
            // When roastInProcess = false, ignore bytes[13-14] completely
            fanMotorLevel = 0
            heatLevel = 0
            print("🚫 Ignoring bytes[13-14] (roastInProcess = false, data unreliable)")
        }
        
        // Check if we should ignore control updates due to recent command sent
        let manualRoastShouldIgnore = bleManager?.manualRoastHandler?.shouldIgnoreNextStatus ?? false
        let heatControlShouldIgnore = bleManager?.heatControl?.shouldIgnoreNextStatus ?? false
        let fanControlShouldIgnore = bleManager?.fanControl?.shouldIgnoreStatus() ?? false
        
        let shouldIgnoreControls = manualRoastShouldIgnore || heatControlShouldIgnore || fanControlShouldIgnore
        
        // Debug: Show which handler requested ignore (if any)
        if shouldIgnoreControls {
            print("🛑 Ignore flags status:")
            print("   - ManualRoast (0x15): \(manualRoastShouldIgnore ? "✓ IGNORE" : "✗")")
            print("   - HeatControl (0x01): \(heatControlShouldIgnore ? "✓ IGNORE" : "✗")")
            print("   - FanControl (0x02): \(fanControlShouldIgnore ? "✓ IGNORE" : "✗")")
        }
        
        
        
        // Update control state on main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let controlState = self.controlState else { return }
            
            controlState.beanTempValue = rawTemp
            
            // Special case: If roasting AND cooling, and both fan & heat are 0, the roast is finished
            if controlState.roastInProcess && controlState.coolInProcess {
                if fanMotorLevel == 0 && heatLevel == 0 {
                    print("✅ Detected roast completion via 0x21 (fan=0, heat=0 during cooling)")
                    
                    // Cancel any pending slider updates
                    controlState.cancelPendingSliderUpdates()
                    
                    // Roast is complete - reset everything
                    controlState.roastInProcess = false
                    controlState.coolInProcess = false
                    controlState.isProfileRoast = false
                    
                    // Set flag to prevent triggering 0x15 when updating sliders to 0
                    controlState.isUpdatingFromRoaster = true
                    controlState.fanMotorLevel = 0
                    controlState.heatLevel = 0
                    controlState.isUpdatingFromRoaster = false
                    
                    print("✅ Roast finished via status message:")
                    print("   - roastInProcess: false")
                    print("   - coolInProcess: false")
                    print("   - isProfileRoast: false")
                    print("   - All sliders reset to 0")
                    
                    // Exit early - don't process further updates
                    return
                }
            }
            
            // Only update fan and heat levels when roast is in process
            // Otherwise, preserve the user's slider settings
            // Also ignore updates if a control command was recently sent (next message after send)
            // OR if sliders have pending updates (during debounce window)
            if controlState.roastInProcess {
                print("🔍 Status message during roast - checking ignore flags...")
                print("   shouldIgnoreControls = \(shouldIgnoreControls)")
                print("   hasPendingFanUpdate = \(controlState.hasPendingFanUpdate)")
                print("   hasPendingHeatUpdate = \(controlState.hasPendingHeatUpdate)")
                print("   Reported fanMotorLevel: \(fanMotorLevel), heatLevel: \(heatLevel)")
                print("   Current UI fanMotorLevel: \(controlState.fanMotorLevel), heatLevel: \(controlState.heatLevel)")
                
                // Determine which values should be updated based on ignore flags
                let shouldUpdateFan = !shouldIgnoreControls && !controlState.hasPendingFanUpdate
                let shouldUpdateHeat = !shouldIgnoreControls && !controlState.hasPendingHeatUpdate
                
                if shouldUpdateFan || shouldUpdateHeat {
                    // CRITICAL: Set flag to prevent these updates from triggering 0x15 messages
                    // These values are coming FROM the roaster (0x21), not from user input
                    // Sending 0x15 in response to 0x21 creates an infinite loop!
                    controlState.isUpdatingFromRoaster = true
                    
                    if shouldUpdateFan {
                        controlState.fanMotorLevel = Double(fanMotorLevel)
                        print("🔄 Updated fanMotorLevel: \(fanMotorLevel) from roaster (0x21)")
                    } else {
                        print("⏳ Skipping fan update (pending user adjustment)")
                    }
                    
                    if shouldUpdateHeat {
                        controlState.heatLevel = Double(heatLevel)
                        print("🔄 Updated heatLevel: \(heatLevel) from roaster (0x21)")
                    } else {
                        print("⏳ Skipping heat update (pending user adjustment)")
                    }
                    
                    controlState.isUpdatingFromRoaster = false
                    print("   ⚠️ NOT sending 0x15 - update is FROM roaster, not from user")
                } else {
                    print("⏳ Ignoring status message (command sent or sliders pending)")
                    print("   Keeping UI values: fanMotorLevel=\(controlState.fanMotorLevel), heatLevel=\(controlState.heatLevel)")
                    // Clear the ignore flags after skipping this message
                    self.bleManager?.manualRoastHandler?.clearIgnoreFlag()
                    self.bleManager?.heatControl?.clearIgnoreFlag()
                    self.bleManager?.fanControl?.clearIgnoreWindow()  // FanControl uses time-based window
                }
            } else {
                print("💾 Preserving user slider settings (roast not in process)")
            }
           // print("🌡️ Updated temperature to: \(rawTemp)°F")
            
           
        }
    }
    
    
    
    
    
    
    
}


// MARK: - Temperature Parsing Utilities

extension IncomingMessageHandler {
    
    /// Parse 16-bit temperature value (big-endian)
    func parseTemperatureBigEndian(from bytes: [UInt8], startIndex: Int) -> Int {
        guard bytes.count > startIndex + 1 else { return 0 }
        return (Int(bytes[startIndex]) << 8) | Int(bytes[startIndex + 1])
    }
    
    /// Parse 16-bit temperature value (little-endian)
    func parseTemperatureLittleEndian(from bytes: [UInt8], startIndex: Int) -> Int {
        guard bytes.count > startIndex + 1 else { return 0 }
        return (Int(bytes[startIndex + 1]) << 8) | Int(bytes[startIndex])
    }
    
    /// Convert Celsius to Fahrenheit
    func celsiusToFahrenheit(_ celsius: Int) -> Int {
        return (celsius * 9 / 5) + 32
    }
    
    /// Parse scaled temperature (e.g., value / 10)
    func parseScaledTemperature(from bytes: [UInt8], startIndex: Int, scale: Int = 10) -> Int {
        guard bytes.count > startIndex + 1 else { return 0 }
        let rawValue = (Int(bytes[startIndex]) << 8) | Int(bytes[startIndex + 1])
        return rawValue / scale
    }
}


// MARK: - Temperature Debug Helpers

extension IncomingMessageHandler {
    
    /// Print temperature bytes for debugging
    func debugPrintTemperatureBytes(_ bytes: [UInt8]) {
        guard bytes.count >= 10 else { return }
        
        print("🔍 Temperature Debug:")
        print("   Bytes[8-9]: \(String(format: "%02X %02X", bytes[8], bytes[9]))")
        print("   Big-Endian: \(parseTemperatureBigEndian(from: bytes, startIndex: 8))")
        print("   Little-Endian: \(parseTemperatureLittleEndian(from: bytes, startIndex: 8))")
        print("   Byte[8] only: \(bytes[8])")
        print("   Byte[9] only: \(bytes[9])")
    }
}
