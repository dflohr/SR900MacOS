//
//  StartProfileRoast_0x1A.swift
//  SR900MacOS
//
//  Handler for Start Profile Roast message (0x1A)
//

import Foundation
import SwiftUI

class StartProfileRoast_0x1A {
    
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
    
    // MARK: - Start Profile Roast Message Function
    
    /// Starts a saved profile roast on the roaster device
    /// - Parameter controlState: Optional ControlState to capture start temperature and check connection
    /// - Note: This sends command 0x1A which starts a roast using the profile previously uploaded via 0x1B
    /// - Note: The roaster will respond with 0x1C acknowledgment, which sets roastInProcess = true
    func startSavedProfileRoast(controlState: ControlState? = nil) {
        // Check if BLE is connected before sending
        guard messageProtocol.BLE_Connected == 1 else {
            print("⚠️ StartProfileRoast: BLE not connected. Message not sent.")
            return
        }
        
        // Check if roast is already in process
        if let controlState = controlState, controlState.roastInProcess {
            print("⚠️ StartProfileRoast: Cannot send 0x1A - roast already in progress (roastInProcess = true)")
            return
        }
        
        print("📤 Sending 0x1A Start Profile Roast command")
        
        // CRITICAL: Capture the current bean temperature for graph plotting start point
        // This will be used by GraphDataManager to plot the first point at x=58, y≈440
        if let controlState = controlState {
            controlState.roastStartTemperature = controlState.beanTempValue
            print("📊 Captured roast start temperature: \(controlState.roastStartTemperature)°F (will plot at x=58)")
            print("📊 This temperature comes from BeanTemperatureDisplay which shows: \(controlState.beanTempValue)\(controlState.temperatureUnit)")
        }
        
        // CRITICAL: Set flag to ignore next status message BEFORE sending command
        // This prevents race condition where 0x21 arrives before flag is set
        shouldIgnoreNextStatus = true
        print("🛡️ StartProfileRoast: Ignore flag set BEFORE sending")
        
        // Get Header (bytes 0-4)
        messageProtocol.Message_Header()
        
        // Set message subtype (byte 5)
        // For 0x1A, byte[5] determines the action:
        // 0x01: Start the saved profile roast
        // 0x02: Request the saved profile (query)
        messageProtocol.TX_B[messageProtocol.d_byte] = 0x01
        messageProtocol.d_byte += 1
        
        // Set message type (byte 6) - 0x1A for Start Profile Roast
        messageProtocol.TX_B[messageProtocol.d_byte] = 0x1A
        messageProtocol.d_byte += 1
        
        // Add MAC address (bytes 7-12)
        messageProtocol.Add_MAC()
        
        // Remaining bytes (13-30) will be filled with random data by Message_Set()
        // The profile data was already uploaded via 0x1B, so no payload is needed here
        
        // Fill remaining bytes, calculate checksum and send
        messageProtocol.Message_Set()
        
        // Set initialMessage to false after first message
        messageProtocol.initialMessage = false
        
        print("✅ StartProfileRoast: Sent 0x1A command - waiting for 0x1C acknowledgment")
        print("ℹ️  The roaster will respond with 0x1C, which sets roastInProcess=true and starts graph recording")
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
