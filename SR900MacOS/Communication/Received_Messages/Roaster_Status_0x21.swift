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
        let shouldIgnoreControls = (bleManager?.manualRoastHandler?.shouldIgnoreNextStatus ?? false) ||
                                    (bleManager?.heatControl?.shouldIgnoreNextStatus ?? false) ||
                                    (bleManager?.fanControl?.shouldIgnoreNextStatus ?? false)
        
        
        
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
                    controlState.fanMotorLevel = 0
                    controlState.heatLevel = 0
                    
                    print("✅ Roast finished via status message:")
                    print("   - roastInProcess: false")
                    print("   - coolInProcess: false")
                    print("   - All sliders reset to 0")
                    
                    // Exit early - don't process further updates
                    return
                }
            }
            
            // Only update fan and heat levels when roast is in process
            // Otherwise, preserve the user's slider settings
            // Also ignore updates if a control command was recently sent (next message after send)
            if controlState.roastInProcess {
                if !shouldIgnoreControls {
                    controlState.fanMotorLevel = Double(fanMotorLevel)
                    controlState.heatLevel = Double(heatLevel)
                    print("🔄 Updated fanMotorLevel: \(fanMotorLevel), heatLevel: \(heatLevel) from roaster")
                } else {
                    print("⏳ Ignoring next status message after control command sent")
                    // Clear the ignore flags after skipping this message
                    self.bleManager?.manualRoastHandler?.clearIgnoreFlag()
                    self.bleManager?.heatControl?.clearIgnoreFlag()
                    self.bleManager?.fanControl?.clearIgnoreFlag()
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
