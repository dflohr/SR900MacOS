//
//  FanControl_0x01.swift
//  SR900MacOS
//
//  Handler for Fan Control message (0x01)
//

import Foundation
import SwiftUI

class FanControl_0x01 {
    
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
    
    // MARK: - Fan Control Message Function
    
    /// Sends fan speed control command to the roaster device
    /// - Parameter fanSpeed: Fan speed value (0-9)
    func sendFanControl(fanSpeed: UInt8) {
        // Check if BLE is connected before sending
        guard messageProtocol.BLE_Connected == 1 else {
            print("⚠️ FanControl: BLE not connected. Message not sent.")
            return
        }
        
        // Validate fan speed parameter
        guard fanSpeed <= 9 else {
            print("⚠️ FanControl: Fan speed must be 0-9. Received: \(fanSpeed)")
            return
        }
        
        // Get Header (bytes 0-4)
        messageProtocol.Message_Header()
        
        // Set message subtype (byte 5)
        messageProtocol.TX_B[messageProtocol.d_byte] = 0x00
        messageProtocol.d_byte += 1
        
        // Set message type (byte 6) - 0x01 for Fan Control
        messageProtocol.TX_B[messageProtocol.d_byte] = 0x01
        messageProtocol.d_byte += 1
        
        // Add MAC address (bytes 7-12)
        messageProtocol.Add_MAC()
        
        // Byte 13: Fan speed value (0-9)
        messageProtocol.TX_B[messageProtocol.d_byte] = fanSpeed
        messageProtocol.d_byte += 1
        
        // Remaining bytes (14-30) will be filled with random data by Message_Set()
        
        // Fill remaining bytes, calculate checksum and send
        messageProtocol.Message_Set()
        
        // Set initialMessage to false after first message
        messageProtocol.initialMessage = false
        
        // Set flag to ignore next status message
        shouldIgnoreNextStatus = true
        
        print("✅ FanControl: Sent fan speed command (Fan: \(fanSpeed))")
    }
    
    /// Convenience function to send fan control using ControlState value
    /// - Parameter controlState: The ControlState object containing current fan motor level
    func sendFanControl(from controlState: ControlState) {
        let fanSpeed = UInt8(controlState.fanMotorLevel)
        
        print("🔍 FanControl Debug:")
        print("   ControlState.fanMotorLevel: \(controlState.fanMotorLevel) -> UInt8: \(fanSpeed)")
        
        sendFanControl(fanSpeed: fanSpeed)
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
