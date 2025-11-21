//
//  UpdateSettings_0x2B.swift
//  SR900MacOS
//
//  Handler for Update Settings message (0x2B)
//

import Foundation
import SwiftUI

class UpdateSettings_0x2B {
    
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
    
    // MARK: - Update Settings Message Function
    
    /// Sends update settings command to the roaster device
    /// - Parameters:
    ///   - subtype: Message subtype for byte 5 (default: 0x00)
    ///   - temperatureUnit: 0 for Fahrenheit, 1 for Celsius
    ///   - thermistor: 0 for Internal, 1 for External
    ///   - voltageSupply: 0 for Low, 1 for Average, 2 for High
    func sendUpdateSettings(subtype: UInt8 = 0x00, temperatureUnit: UInt8, thermistor: UInt8, voltageSupply: UInt8) {
        // Check if BLE is connected before sending
        guard messageProtocol.BLE_Connected == 1 else {
            print("⚠️ UpdateSettings: BLE not connected. Message not sent.")
            return
        }
        
        // Parameter validation
        guard temperatureUnit <= 1 else {
            print("⚠️ UpdateSettings: Temperature unit must be 0-1. Received: \(temperatureUnit)")
            return
        }
        guard thermistor <= 1 else {
            print("⚠️ UpdateSettings: Thermistor must be 0-1. Received: \(thermistor)")
            return
        }
        guard voltageSupply <= 2 else {
            print("⚠️ UpdateSettings: Voltage supply must be 0-2. Received: \(voltageSupply)")
            return
        }
        /*
        // Add 128 to subtype if temperature unit is Celsius (used in ProfilePanel)
        var  adjustedSubtype:  UInt8 = 0//subtype
        
        if temperatureUnit == 1 {
            adjustedSubtype = adjustedSubtype + 128  // Use overflow addition operator to stay in UInt8 range
            print("🌡️ Temperature unit is Celsius adding 128 to adjustedSubtype")
        if thermistor == 1 {
            adjustedSubtype = adjustedSubtype + 64  // Use overflow addition operator to stay in UInt8 range
            print("🌡️ External Thermistor - adding 64 to adjustedSubtype")
        }
        if voltageSupply == 2 {
            adjustedSubtype = adjustedSubtype + 4  // Use overflow addition operator to stay in UInt8 range
            print("🌡️ Voltage High - adding 4 to adjustedSubtype")
        }
        if voltageSupply == 1 {
            adjustedSubtype = adjustedSubtype + 2  // Use overflow addition operator to stay in UInt8 range
            print("🌡️ Voltage Average - adding 2 to adjustedSubtype")
        }
        if voltageSupply == 0 {
            adjustedSubtype = adjustedSubtype + 1  // Use overflow addition operator to stay in UInt8 range
            print("🌡️ Voltage Low - adding 1 to adjustedSubtype")
        }
        */
        
        // CRITICAL: Set flag to ignore next status message BEFORE sending command
        // This prevents race condition where 0x21 arrives before flag is set
        shouldIgnoreNextStatus = true
        print("🛡️ UpdateSettings: Ignore flag set BEFORE sending")
        
        // Get Header (bytes 0-4)
        messageProtocol.Message_Header()
        
        // Set message subtype (byte 5) - can be customized by caller
        messageProtocol.TX_B[messageProtocol.d_byte] = subtype//adjustedSubtype
        messageProtocol.d_byte += 1
       // subtype=0x00//adjustedSubtype=0x00
            
        // Set message type (byte 6) - 0x2B for Update Settings
        messageProtocol.TX_B[messageProtocol.d_byte] = 0x2B
        messageProtocol.d_byte += 1
        
        // Add MAC address (bytes 7-12)
        messageProtocol.Add_MAC()
        
        // Byte 13: Temperature unit (0=F, 1=C)
      //  messageProtocol.TX_B[messageProtocol.d_byte] = temperatureUnit
       // messageProtocol.d_byte += 1
        
        // Byte 14: Thermistor (0=Internal, 1=External)
       // messageProtocol.TX_B[messageProtocol.d_byte] = thermistor
       //messageProtocol.d_byte += 1
        
        // Byte 15: Voltage supply (0=Low, 1=Average, 2=High)
      //  messageProtocol.TX_B[messageProtocol.d_byte] = voltageSupply
      //  messageProtocol.d_byte += 1
        
        // Remaining bytes will be filled with random data by Message_Set()
        
        // Fill remaining bytes, calculate checksum and send
        messageProtocol.Message_Set()
        
        // Set initialMessage to false after first message
        messageProtocol.initialMessage = false
        
        print("✅ UpdateSettings: Sent update settings command (Subtype: 0x\(String(format: "%02X", subtype)), Temp: \(temperatureUnit == 0 ? "F" : "C"), Thermistor: \(thermistor == 0 ? "Internal" : "External"), Voltage: \(voltageSupply == 0 ? "Low" : voltageSupply == 1 ? "Average" : "High"))")
    }
    
    /// Convenience function to send update settings with specific values
    /// - Parameters:
    ///   - subtype: Message subtype for byte 5 (default: 0x00)
    ///   - temperatureIsFahrenheit: true for Fahrenheit, false for Celsius
    ///   - thermistorIsExternal: true for External thermistor, false for Internal
    ///   - voltageSupply: "LOW", "AVERAGE", or "HIGH"
    func sendUpdateSettings(subtype: UInt8 = 0x00, temperatureIsFahrenheit: Bool, thermistorIsExternal: Bool, voltageSupply: String) {
        // Convert UI values to protocol bytes
        let tempUnit: UInt8 = temperatureIsFahrenheit ? 0 : 1  // 0=F, 1=C
        let thermistor: UInt8 = thermistorIsExternal ? 1 : 0   // 0=Internal, 1=External
        let voltage: UInt8 = {
            switch voltageSupply.uppercased() {
            case "LOW": return 0
            case "AVERAGE": return 1
            case "HIGH": return 2
            default: return 1  // Default to Average
            }
        }()
        
        // Calculate adjusted subtype based on settings
        var adjustedSubtype: UInt8 = subtype
        
        // Add 128 if temperature is Fahrenheit
        if temperatureIsFahrenheit {
            adjustedSubtype = adjustedSubtype &+ 128
            print("🌡️ Temperature is Fahrenheit - adding 128 to adjustedSubtype")
        }
        
        // Add 64 if thermistor is External
        if thermistorIsExternal {
            adjustedSubtype = adjustedSubtype &+ 64
            print("🌡️ External Thermistor - adding 64 to adjustedSubtype")
        }
        
        // Add voltage supply adjustment
        switch voltage {
        case 0: // LOW
            adjustedSubtype = adjustedSubtype &+ 1
            print("⚡ Voltage Low - adding 1 to adjustedSubtype")
        case 1: // AVERAGE
            adjustedSubtype = adjustedSubtype &+ 2
            print("⚡ Voltage Average - adding 2 to adjustedSubtype")
        case 2: // HIGH
            adjustedSubtype = adjustedSubtype &+ 4
            print("⚡ Voltage High - adding 4 to adjustedSubtype")
        default:
            break
        }
        
        print("🔍 UpdateSettings Debug:")
        print("   Original Subtype: 0x\(String(format: "%02X", subtype))")
        print("   Adjusted Subtype: 0x\(String(format: "%02X", adjustedSubtype))")
        print("   Temperature: \(temperatureIsFahrenheit ? "Fahrenheit" : "Celsius") (\(tempUnit))")
        print("   Thermistor: \(thermistorIsExternal ? "External" : "Internal") (\(thermistor))")
        print("   Voltage: \(voltageSupply) (\(voltage))")
        
        // Call main function with adjusted subtype
        sendUpdateSettings(subtype: adjustedSubtype, temperatureUnit: tempUnit, thermistor: thermistor, voltageSupply: voltage)
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
