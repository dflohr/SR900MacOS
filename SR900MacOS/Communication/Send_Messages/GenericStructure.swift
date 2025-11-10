import Foundation
import SwiftUI
/*
class Generic {
    
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
    
    /// Requests MAC address from the roaster device
    func Generic() {
        // Get Header
        messageProtocol.Message_Header()
        
        // Set message subtype and type
        messageProtocol.TX_B[messageProtocol.d_byte] = 0x00  //ENTER HERE
        messageProtocol.d_byte += 1
        
        messageProtocol.TX_B[messageProtocol.d_byte] = 0x00  //ENTER HERE
        messageProtocol.d_byte += 1

        messageProtocol.Add_MAC()
        
        /**************************************
        
            ADD IN SPECIFIC MESSAGE
        
        **************************************/
        
        // Fill bytes, do checksum and send
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
*/

