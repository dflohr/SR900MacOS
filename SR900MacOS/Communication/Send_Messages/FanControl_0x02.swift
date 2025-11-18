//
//  FanControl_0x02.swift
//  SR900MacOS
//
//  Handler for Fan Control message (0x02)
//

import Foundation
import SwiftUI

class FanControl_0x02 {
    
    // MARK: - Properties
    
    private var messageProtocol: MessageProtocol
    
    // Time-based ignore window instead of single-message flag
    // This prevents race conditions when multiple 0x21 messages arrive rapidly
    private var ignoreStatusUntil: Date?
    private let ignoreWindowDuration: TimeInterval = 1.5  // Ignore for 1.5 seconds
    
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
        
        // CRITICAL: Set time-based ignore window BEFORE sending command
        // This prevents race condition where 0x21 arrives before ignore is active
        ignoreStatusUntil = Date().addingTimeInterval(ignoreWindowDuration)
        print("🛡️ FanControl: Ignore window activated BEFORE sending (until \(ignoreStatusUntil!.formatted(date: .omitted, time: .standard)))")
        
        // Get Header (bytes 0-4)
        messageProtocol.Message_Header()
        
        // Set message subtype (byte 5)
        messageProtocol.TX_B[messageProtocol.d_byte] = 0x00
        messageProtocol.d_byte += 1
        
        // Set message type (byte 6) - 0x02 for Fan Control
        messageProtocol.TX_B[messageProtocol.d_byte] = 0x02
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
    
    /// Check if status messages should currently be ignored
    /// - Returns: true if we're still within the ignore window
    func shouldIgnoreStatus() -> Bool {
        guard let ignoreUntil = ignoreStatusUntil else {
            return false
        }
        
        let now = Date()
        if now < ignoreUntil {
            let remainingTime = ignoreUntil.timeIntervalSince(now)
            print("⏳ FanControl: Still ignoring (%.1f seconds remaining)", remainingTime)
            return true
        } else {
            // Window expired - clear it
            ignoreStatusUntil = nil
            print("✅ FanControl: Ignore window expired - processing status normally")
            return false
        }
    }
    
    /// Manually clear the ignore window (for testing/debugging)
    func clearIgnoreWindow() {
        ignoreStatusUntil = nil
        print("🔓 FanControl: Cleared ignore window")
    }
    
    /// Get reference to the message protocol handler
    func getMessageProtocol() -> MessageProtocol {
        return messageProtocol
    }
}

