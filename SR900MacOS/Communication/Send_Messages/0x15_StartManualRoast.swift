//
//  StartManualRoast_0x15.swift
//  SR900MacOS
//
//  Created by Daniel Flohr on 11/10/25.
//

import Foundation
import SwiftUI

class StartManualRoast_0x15 {
    
    // MARK: - Properties
    
    private var messageProtocol: MessageProtocol
    
    // Track if next status message should be ignored
    private(set) var shouldIgnoreNextStatus: Bool = false
    
    // MARK: - Initialization
    
    init(messageProtocol: MessageProtocol) {
        self.messageProtocol = messageProtocol
    }
    
    // Convenience initializer to create its own MessageProtocol instance
    convenience init() {
        let protocol_handler = MessageProtocol()
        self.init(messageProtocol: protocol_handler)
    }
    
    // MARK: - Start Manual Roast Message Function
    
    /// Starts a manual roast on the roaster device with specified parameters
    /// - Parameters:
    ///   - fanSpeed: Fan motor level (0-9)
    ///   - heatSetting: Heat level (0-9)
    ///   - roastTime: Roasting time in minutes (0-15)
    ///   - coolTime: Cooling time in minutes (0-4)
    ///   - controlState: Optional ControlState to check if roast/cool is already in process
    ///   - allowDuringRoast: Set to true to allow sending 0x15 during active roast (for slider updates). Default is false.
    ///   - allowDuringCooling: Set to true to allow fan speed adjustments during cooling. Default is false.
    /// - Note: If your device requires minimum values > 0, you should validate before calling this function
    /// - Note: During cooling, only fan speed adjustments are allowed (heat must be 0)
    func startManualRoast(fanSpeed: UInt8, heatSetting: UInt8, roastTime: UInt8, coolTime: UInt8, controlState: ControlState? = nil, allowDuringRoast: Bool = false, allowDuringCooling: Bool = false) {
        // Check if BLE is connected before sending
        guard messageProtocol.BLE_Connected == 1 else {
            print("⚠️ StartManualRoast: BLE not connected. Message not sent.")
            return
        }
        
        // Check roast/cool process if controlState is provided
        if let controlState = controlState {
            // During cooling phase
            if controlState.coolInProcess {
                // If not explicitly allowed during cooling, block
                if !allowDuringCooling {
                    print("⚠️ StartManualRoast: Cannot send 0x15 - cooling process in progress (coolInProcess = true)")
                    return
                }
                
                // During cooling, heat must be 0 (only fan adjustments allowed)
                if heatSetting != 0 {
                    print("⚠️ StartManualRoast: Cannot send 0x15 during cooling with heat > 0. Heat must be 0 during cooling.")
                    print("   Received: heat=\(heatSetting), Only fan adjustments are allowed during cooling.")
                    return
                }
                
                print("✅ Allowing fan adjustment during cooling (heat=0, fan=\(fanSpeed))")
            }
            
            // If roast is in process and we're not explicitly allowing it, block the message
            // This prevents starting a NEW roast when one is already running
            if controlState.roastInProcess && !allowDuringRoast && !allowDuringCooling {
                print("⚠️ StartManualRoast: Cannot send 0x15 - roast already in progress (roastInProcess = true)")
                print("   Hint: This prevents starting a new roast. Use allowDuringRoast=true for slider updates.")
                return
            }
        }
        
        // Validate parameters
        guard fanSpeed <= 9 else {
            print("⚠️ StartManualRoast: Fan speed must be 0-9. Received: \(fanSpeed)")
            return
        }
        
        guard heatSetting <= 9 else {
            print("⚠️ StartManualRoast: Heat setting must be 0-9. Received: \(heatSetting)")
            return
        }
        
        guard roastTime <= 15 else {
            print("⚠️ StartManualRoast: Roast time must be 0-15 minutes. Received: \(roastTime)")
            return
        }
        
        guard coolTime <= 4 else {
            print("⚠️ StartManualRoast: Cool time must be 0-4 minutes. Received: \(coolTime)")
            return
        }
        
        // CRITICAL: Set flag to ignore next status message BEFORE sending command
        // This prevents race condition where 0x21 arrives before flag is set
        shouldIgnoreNextStatus = true
        print("🛡️ StartManualRoast: Ignore flag set BEFORE sending")
        
        // Capture the current bean temperature for graph plotting start point
        if let controlState = controlState {
            controlState.roastStartTemperature = controlState.beanTempValue
            print("📊 Captured roast start temperature: \(controlState.roastStartTemperature)°F (will plot at x=58, y≈440)")
        }
        
        // Get Header (bytes 0-4)
        messageProtocol.Message_Header()
        
        // Set message subtype (byte 5)
        messageProtocol.TX_B[messageProtocol.d_byte] = 0x00
        messageProtocol.d_byte += 1
        
        // Set message type (byte 6) - 0x15 for Start Manual Roast
        messageProtocol.TX_B[messageProtocol.d_byte] = 0x15
        messageProtocol.d_byte += 1
        
        // Add MAC address (bytes 7-12)
        messageProtocol.Add_MAC()
        
        // Byte 13: Roast time in minutes (0-15)
        messageProtocol.TX_B[messageProtocol.d_byte] = roastTime
        messageProtocol.d_byte += 1
        
        // Byte 14: Cool time in minutes (0-4)
        messageProtocol.TX_B[messageProtocol.d_byte] = coolTime
        messageProtocol.d_byte += 1
        
        // Byte 15: Heat setting (0-9)
        messageProtocol.TX_B[messageProtocol.d_byte] = heatSetting
        messageProtocol.d_byte += 1
        
        // Add roast parameters (bytes 13-16)
        // Byte 16: Fan speed (0-9)
        messageProtocol.TX_B[messageProtocol.d_byte] = fanSpeed
        messageProtocol.d_byte += 1
        
        //HOLDER FOR AUTOROAST STOP
        // Add pad (bytes 17 0x00)
        // Byte 1
        messageProtocol.TX_B[messageProtocol.d_byte] = 0x00
        messageProtocol.d_byte += 1
        
  
        

        
        // Remaining bytes (17-30) will be filled with random data by Message_Set()
        
        // Fill remaining bytes, calculate checksum and send
        messageProtocol.Message_Set()
        
        // Set initialMessage to false after first message
        messageProtocol.initialMessage = false
        
        print("✅ StartManualRoast: Sent manual roast command (Fan: \(fanSpeed), Heat: \(heatSetting), Roast: \(roastTime)m, Cool: \(coolTime)m)")
    }
    
    /// Convenience function to start manual roast using ControlState values
    /// - Parameter controlState: The ControlState object containing current UI values
    func startManualRoast(from controlState: ControlState) {
        let fanSpeed = UInt8(controlState.fanMotorLevel)
        let heatSetting = UInt8(controlState.heatLevel)
        let roastTime = UInt8(controlState.roastingTime)
        let coolTime = UInt8(controlState.coolingTime)
        
        print("🔍 StartManualRoast Debug:")
        print("   ControlState.fanMotorLevel: \(controlState.fanMotorLevel) -> UInt8: \(fanSpeed)")
        print("   ControlState.heatLevel: \(controlState.heatLevel) -> UInt8: \(heatSetting)")
        print("   ControlState.roastingTime: \(controlState.roastingTime) -> UInt8: \(roastTime)")
        print("   ControlState.coolingTime: \(controlState.coolingTime) -> UInt8: \(coolTime)")
        print("   roastInProcess: \(controlState.roastInProcess)")
        print("   coolInProcess: \(controlState.coolInProcess)")
        
        // VALIDATION: All required sliders must have values > 0
        guard fanSpeed > 0 else {
            print("⚠️ StartManualRoast: Cannot start roast - Fan Motor Level must be greater than 0")
            return
        }
        
        guard heatSetting > 0 else {
            print("⚠️ StartManualRoast: Cannot start roast - Heat Level must be greater than 0")
            return
        }
        
        guard roastTime > 0 else {
            print("⚠️ StartManualRoast: Cannot start roast - Roasting Time must be greater than 0")
            return
        }
        
        // Note: coolTime can be 0 (cooling is optional), so we don't validate it
        
        print("✅ All slider values valid (all > 0). Proceeding with manual roast...")
        
        startManualRoast(
            fanSpeed: fanSpeed,
            heatSetting: heatSetting,
            roastTime: roastTime,
            coolTime: coolTime,
            controlState: controlState,
            allowDuringRoast: false  // Initial start must have roastInProcess = false
        )
    }
    
    // MARK: - Helper Functions
    
    /// Reset the ignore flag after status message has been processed
    func clearIgnoreFlag() {
        shouldIgnoreNextStatus = false
    }
    
    /// Get reference to the message protocol handler
    func getMessageProtocol() -> MessageProtocol {
        return messageProtocol
    }
}
/*
//  StartManualRoast_0x15.swift
//  SR900MacOS
//
//  Created by Daniel Flohr on 11/10/25.
//

import Foundation
import SwiftUI

class StartManualRoast_0x15 {
    
    // MARK: - Properties
    
    private var messageProtocol: MessageProtocol
    
    // Track if next status message should be ignored
    private(set) var shouldIgnoreNextStatus: Bool = false
    
    // MARK: - Initialization
    
    init(messageProtocol: MessageProtocol) {
        self.messageProtocol = messageProtocol
    }
    
    // Convenience initializer to create its own MessageProtocol instance
    convenience init() {
        let protocol_handler = MessageProtocol()
        self.init(messageProtocol: protocol_handler)
    }
    
    // MARK: - Start Manual Roast Message Function
    
    /// Starts a manual roast on the roaster device with specified parameters
    /// - Parameters:
    ///   - fanSpeed: Fan motor level (0-9)
    ///   - heatSetting: Heat level (0-9)
    ///   - roastTime: Roasting time in minutes (0-15)
    ///   - coolTime: Cooling time in minutes (0-4)
    ///   - controlState: Optional ControlState to check if roast/cool is already in process
    ///   - allowDuringRoast: Set to true to allow sending 0x15 during active roast (for slider updates). Default is false.
    ///   - allowDuringCooling: Set to true to allow fan speed adjustments during cooling. Default is false.
    /// - Note: If your device requires minimum values > 0, you should validate before calling this function
    /// - Note: During cooling, only fan speed adjustments are allowed (heat must be 0)
    func startManualRoast(fanSpeed: UInt8, heatSetting: UInt8, roastTime: UInt8, coolTime: UInt8, controlState: ControlState? = nil, allowDuringRoast: Bool = false, allowDuringCooling: Bool = false) {
        // Check if BLE is connected before sending
        guard messageProtocol.BLE_Connected == 1 else {
            print("⚠️ StartManualRoast: BLE not connected. Message not sent.")
            return
        }
        
        // Check roast/cool process if controlState is provided
        if let controlState = controlState {
            // During cooling phase
            if controlState.coolInProcess {
                // If not explicitly allowed during cooling, block
                if !allowDuringCooling {
                    print("⚠️ StartManualRoast: Cannot send 0x15 - cooling process in progress (coolInProcess = true)")
                    return
                }
                
                // During cooling, heat must be 0 (only fan adjustments allowed)
                if heatSetting != 0 {
                    print("⚠️ StartManualRoast: Cannot send 0x15 during cooling with heat > 0. Heat must be 0 during cooling.")
                    print("   Received: heat=\(heatSetting), Only fan adjustments are allowed during cooling.")
                    return
                }
                
                print("✅ Allowing fan adjustment during cooling (heat=0, fan=\(fanSpeed))")
            }
            
            // If roast is in process and we're not explicitly allowing it, block the message
            // This prevents starting a NEW roast when one is already running
            if controlState.roastInProcess && !allowDuringRoast && !allowDuringCooling {
                print("⚠️ StartManualRoast: Cannot send 0x15 - roast already in progress (roastInProcess = true)")
                print("   Hint: This prevents starting a new roast. Use allowDuringRoast=true for slider updates.")
                return
            }
        }
        
        // Validate parameters
        guard fanSpeed <= 9 else {
            print("⚠️ StartManualRoast: Fan speed must be 0-9. Received: \(fanSpeed)")
            return
        }
        
        guard heatSetting <= 9 else {
            print("⚠️ StartManualRoast: Heat setting must be 0-9. Received: \(heatSetting)")
            return
        }
        
        guard roastTime <= 15 else {
            print("⚠️ StartManualRoast: Roast time must be 0-15 minutes. Received: \(roastTime)")
            return
        }
        
        guard coolTime <= 4 else {
            print("⚠️ StartManualRoast: Cool time must be 0-4 minutes. Received: \(coolTime)")
            return
        }
        
        // Get Header (bytes 0-4)
        messageProtocol.Message_Header()
        
        // Set message subtype (byte 5)
        messageProtocol.TX_B[messageProtocol.d_byte] = 0x00
        messageProtocol.d_byte += 1
        
        // Set message type (byte 6) - 0x15 for Start Manual Roast
        messageProtocol.TX_B[messageProtocol.d_byte] = 0x15
        messageProtocol.d_byte += 1
        
        // Add MAC address (bytes 7-12)
        messageProtocol.Add_MAC()
        
        // Byte 13: Roast time in minutes (0-15)
        messageProtocol.TX_B[messageProtocol.d_byte] = roastTime
        messageProtocol.d_byte += 1
        
        // Byte 14: Cool time in minutes (0-4)
        messageProtocol.TX_B[messageProtocol.d_byte] = coolTime
        messageProtocol.d_byte += 1
        
        // Byte 15: Heat setting (0-9)
        messageProtocol.TX_B[messageProtocol.d_byte] = heatSetting
        messageProtocol.d_byte += 1
        
        // Add roast parameters (bytes 13-16)
        // Byte 16: Fan speed (0-9)
        messageProtocol.TX_B[messageProtocol.d_byte] = fanSpeed
        messageProtocol.d_byte += 1
        
        //HOLDER FOR AUTOROAST STOP
        // Add pad (bytes 17 0x00)
        // Byte 1
        messageProtocol.TX_B[messageProtocol.d_byte] = 0x00
        messageProtocol.d_byte += 1
        
  
        

        
        // Remaining bytes (17-30) will be filled with random data by Message_Set()
        
        // Fill remaining bytes, calculate checksum and send
        messageProtocol.Message_Set()
        
        // Set initialMessage to false after first message
        messageProtocol.initialMessage = false
        
        // Set flag to ignore next status message
        shouldIgnoreNextStatus = true
        
        print("✅ StartManualRoast: Sent manual roast command (Fan: \(fanSpeed), Heat: \(heatSetting), Roast: \(roastTime)m, Cool: \(coolTime)m)")
    }
    
    /// Convenience function to start manual roast using ControlState values
    /// - Parameter controlState: The ControlState object containing current UI values
    func startManualRoast(from controlState: ControlState) {
        let fanSpeed = UInt8(controlState.fanMotorLevel)
        let heatSetting = UInt8(controlState.heatLevel)
        let roastTime = UInt8(controlState.roastingTime)
        let coolTime = UInt8(controlState.coolingTime)
        
        print("🔍 StartManualRoast Debug:")
        print("   ControlState.fanMotorLevel: \(controlState.fanMotorLevel) -> UInt8: \(fanSpeed)")
        print("   ControlState.heatLevel: \(controlState.heatLevel) -> UInt8: \(heatSetting)")
        print("   ControlState.roastingTime: \(controlState.roastingTime) -> UInt8: \(roastTime)")
        print("   ControlState.coolingTime: \(controlState.coolingTime) -> UInt8: \(coolTime)")
        print("   roastInProcess: \(controlState.roastInProcess)")
        print("   coolInProcess: \(controlState.coolInProcess)")
        
        startManualRoast(
            fanSpeed: fanSpeed,
            heatSetting: heatSetting,
            roastTime: roastTime,
            coolTime: coolTime,
            controlState: controlState,
            allowDuringRoast: false  // Initial start must have roastInProcess = false
        )
    }
    
    // MARK: - Helper Functions
    
    /// Reset the ignore flag after status message has been processed
    func clearIgnoreFlag() {
        shouldIgnoreNextStatus = false
    }
    
    /// Get reference to the message protocol handler
    func getMessageProtocol() -> MessageProtocol {
        return messageProtocol
    }
}
*/
