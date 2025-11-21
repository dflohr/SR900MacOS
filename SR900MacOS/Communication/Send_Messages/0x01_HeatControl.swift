//
//  HeatControl_0x01.swift
//  SR900MacOS
//
//  Handler for Heat Control message (0x01)
//

import Foundation
import SwiftUI

class HeatControl_0x01 {
    
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
    
    // MARK: - Heat Control Message Function
    
    /// Sends heat level control command to the roaster device
    /// - Parameter heatLevel: Heat level value (0-9)
    func sendHeatControl(heatLevel: UInt8) {
        // Check if BLE is connected before sending
        guard messageProtocol.BLE_Connected == 1 else {
            print("⚠️ HeatControl: BLE not connected. Message not sent.")
            return
        }
        
        // Validate heat level parameter
        guard heatLevel <= 9 else {
            print("⚠️ HeatControl: Heat level must be 0-9. Received: \(heatLevel)")
            return
        }
        
        // CRITICAL: Set flag to ignore next status message BEFORE sending command
        // This prevents race condition where 0x21 arrives before flag is set
        shouldIgnoreNextStatus = true
        print("🛡️ HeatControl: Ignore flag set BEFORE sending")
        
        // Get Header (bytes 0-4)
        messageProtocol.Message_Header()
        
        // Set message subtype (byte 5)
        messageProtocol.TX_B[messageProtocol.d_byte] = 0x00
        messageProtocol.d_byte += 1
        
        // Set message type (byte 6) - 0x01 for Heat Control
        messageProtocol.TX_B[messageProtocol.d_byte] = 0x01
        messageProtocol.d_byte += 1
        
        // Add MAC address (bytes 7-12)
        messageProtocol.Add_MAC()
        
        // Byte 13: Heat level value (0-9)
        messageProtocol.TX_B[messageProtocol.d_byte] = heatLevel
        messageProtocol.d_byte += 1
        
        // Remaining bytes (14-30) will be filled with random data by Message_Set()
        
        // Fill remaining bytes, calculate checksum and send
        messageProtocol.Message_Set()
        
        // Set initialMessage to false after first message
        messageProtocol.initialMessage = false
        
        print("✅ HeatControl: Sent heat level command (Heat: \(heatLevel))")
    }
    
    /// Convenience function to send heat control using ControlState value
    /// - Parameter controlState: The ControlState object containing current heat level
    func sendHeatControl(from controlState: ControlState) {
        let heatLevel = UInt8(controlState.heatLevel)
        
        print("🔍 HeatControl Debug:")
        print("   ControlState.heatLevel: \(controlState.heatLevel) -> UInt8: \(heatLevel)")
        
        sendHeatControl(heatLevel: heatLevel)
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
