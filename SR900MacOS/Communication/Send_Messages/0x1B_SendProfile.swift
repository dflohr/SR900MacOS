//
//  SendProfile_0x1B.swift
//  SR900MacOS
//
//  Handler for Send Profile message (0x1B)
//

import Foundation
import SwiftUI

class SendProfile_0x1B {
    
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
    
    // MARK: - Send Profile Message Function
    
    /// Sends profile data to the roaster device
    /// - Parameters:
    ///   - fanProfile: Array of 18 fan/motor values (0-9, where 0 means no value/"-")
    ///   - heaterProfile: Array of 18 heater values (0-9, where 0 means no value/"-")
    /// - Note: This message (0x1B) is used to transfer roast profile data to the device.
    ///         Each byte in the payload (13-30) encodes: (fanProfile[i] << 4) | heaterProfile[i]
    func sendProfile(fanProfile: [UInt8] = [9, 9, 9, 8, 6, 7, 6, 6, 5, 5, 5, 4, 4, 4, 4, 0, 0, 0], 
                    heaterProfile: [UInt8] = [2, 2, 3, 4, 6, 7, 8, 8, 8, 8, 7, 7, 0, 0, 0, 0, 0, 0]) {
        // Check if BLE is connected before sending
        guard messageProtocol.BLE_Connected == 1 else {
            print("⚠️ SendProfile: BLE not connected. Message not sent.")
            return
        }
        
        print("📤 Sending 0x1B Send Profile message")
        
        // CRITICAL: Set flag to ignore next status message BEFORE sending command
        // This prevents race condition where 0x21 arrives before flag is set
        shouldIgnoreNextStatus = true
        print("🛡️ SendProfile: Ignore flag set BEFORE sending")
        
        // Get Header (bytes 0-4)
        messageProtocol.Message_Header()
        
        // Set message subtype (byte 5)
        messageProtocol.TX_B[messageProtocol.d_byte] = 0x00
        messageProtocol.d_byte += 1
        
        // Set message type (byte 6) - 0x1B for Send Profile
        messageProtocol.TX_B[messageProtocol.d_byte] = 0x1B
        messageProtocol.d_byte += 1

        // Add MAC address (bytes 7-12)
        // The MAC address is 6 bytes, where the 6th byte (byte 12) completes the MAC
        messageProtocol.Add_MAC()
        
        // Add profile data payload (bytes 13-30)
        // Each byte encodes: (FanProfile << 4) | HeaterProfile
        // This packs 18 profile values into 18 bytes (one per minute)
        
        // Validate array lengths
        guard fanProfile.count == 18 && heaterProfile.count == 18 else {
            print("⚠️ SendProfile: Invalid profile array lengths (expected 18 each)")
            return
        }
        
        // Encode 18 profile values into bytes 13-30
        for i in 0..<18 {
            // Combine fan (upper nibble) and heater (lower nibble) into one byte
            // Example: fan=9, heater=2 -> 0x92
            let combinedByte = (fanProfile[i] << 4) | heaterProfile[i]
            messageProtocol.TX_B[messageProtocol.d_byte] = combinedByte
            messageProtocol.d_byte += 1
        }
        
        print("📊 SendProfile: Encoded \(fanProfile.count) profile values into bytes 13-30")
        
        // Fill remaining bytes, calculate checksum and send
        messageProtocol.Message_Set()
        
        // Set initialMessage to false after first message
        messageProtocol.initialMessage = false
        
        print("✅ SendProfile: Sent profile data")
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
