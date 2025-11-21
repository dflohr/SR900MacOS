import Foundation
import SwiftUI

class StartProfileRoast_0x1A {
    
    // MARK: - Properties
    
    private var messageProtocol: MessageProtocol
    
    // MARK: - Initialization
    
    init(messageProtocol: MessageProtocol) {
        self.messageProtocol = messageProtocol
    }
    
    // Convenience initializer to create its own MessageProtocol instance
    convenience init() {
        let protocol_handler = MessageProtocol()
        self.init(messageProtocol: protocol_handler)
    }
    
    // MARK: - Request MAC Message Function
    
    /// Starts a saved profile roast on the roaster device
    /// 
    /// Important: After sending 0x1A and receiving 0x1C Profile Start Acknowledged,
    /// do NOT send 0x15 Start Manual Roast message. The profile roast is already started.
    /// Sending 0x15 during a profile roast will interfere with the roast process.
    func startSavedProfileRoast() {
        // Check if BLE is connected before sending
        guard messageProtocol.BLE_Connected == 1 else {
            print("⚠️ StartProfileRoast: BLE not connected. Message not sent.")
            return
        }
        
        print("📤 Sending 0x1A Start Profile Roast message")
        
        // Get Header (bytes 0-4)
        messageProtocol.Message_Header()
        
        // Set message subtype (byte 5)
        messageProtocol.TX_B[messageProtocol.d_byte] = 0x00
        messageProtocol.d_byte += 1
        
        // Set message type (byte 6) - 0x1A for Start Profile Roast
        messageProtocol.TX_B[messageProtocol.d_byte] = 0x1A
        messageProtocol.d_byte += 1

        // Add MAC address (bytes 7-12)
        // The MAC address is 6 bytes, where the 6th byte (byte 12) completes the MAC
        messageProtocol.Add_MAC()
        
        // Remaining bytes (13-30) will be filled with random data by Message_Set()
        
        // Fill remaining bytes, calculate checksum and send
        messageProtocol.Message_Set()
        
        // Set initialMessage to false after first message
        messageProtocol.initialMessage = false
    }
    
    // MARK: - Helper Functions
    
    /// Get reference to the message protocol handler
    func getMessageProtocol() -> MessageProtocol {
        return messageProtocol
    }
    

}
