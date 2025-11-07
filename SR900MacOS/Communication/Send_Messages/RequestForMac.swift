
import Foundation
import SwiftUI

class RequestForMac {
    
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
    func RequestMacMessage() {
        // Get Header
        messageProtocol.Message_Header()
        
        // Set message subtype and type
        messageProtocol.TX_B[messageProtocol.d_byte] = 0x00
        messageProtocol.d_byte += 1
        
        messageProtocol.TX_B[messageProtocol.d_byte] = 0x26
        messageProtocol.d_byte += 1
        
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
    
    /// Set MAC address for subsequent messages
    func setMAC(_ macAddress: [UInt8]) {
        guard macAddress.count == 6 else {
            print("Error: MAC address must be 6 bytes")
            return
        }
        messageProtocol.MAC = macAddress
    }
    
    /// Set BLE connection status
    func setBLEConnected(_ connected: Bool) {
        messageProtocol.BLE_Connected = connected ? 1 : 0
    }
}

// MARK: - SwiftUI Preview
/*
struct RequestForMac_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            Text("Request MAC Message")
                .font(.title)
            Text("Check console for output")
                .foregroundColor(.secondary)
            
            Button("Send MAC Request") {
                let macRequest = RequestForMac()
                macRequest.setBLEConnected(true)
                macRequest.RequestMacMessage()
                
                // Print the buffer
                macRequest.getMessageProtocol().printBuffer()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}
*/
