import Foundation
import SwiftUI

class MessageProtocol {
    
    // MARK: - Variables
    
    var TX_B: [UInt8] = Array(repeating: 0, count: 33)  // Buffer for sending messages
    var headers: [UInt8] = [0x53, 0x45, 0x51, 0x4F]     // Header from working message (was 0x53, 0x45, 0xDF, 0x06)
    var d_byte: Int = 0                                  // Byte position
    var initialMessage: Bool = true
    
    // Additional variables referenced in the code
    var MAC: [UInt8] = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00]  // MAC address
    var chksum_holder: Int = 0
    var ChkSum: UInt8 = 0
    var BLE_Connected: Int = 0
    
    // Reference to BLEManager for sending data
    weak var bleManager: BLEManager?
    
    // MARK: - Common Functions
    
    /// Builds first 5 bytes of the message
    func Message_Header() {
        // Generate random header
        if !initialMessage {  // Use after first 0x26 message to seed roaster
            for ran in 0..<4 {
                headers[ran] = rand_num(min: 1, max: 255)
            }
        }
        
        // Clear TX_B buffer
        TX_B = Array(repeating: 0, count: 34)
        
        // Reset byte position
        d_byte = 0
        
        // Build header
        TX_B[d_byte] = 0x20  // 0. Common Byte [0]
        d_byte += 1
        TX_B[d_byte] = headers[0]
        d_byte += 1
        TX_B[d_byte] = headers[1]
        d_byte += 1
        TX_B[d_byte] = headers[2]
        d_byte += 1
        TX_B[d_byte] = headers[3]
        d_byte += 1
    }
    
    /// All messages from app include the roaster MAC address that 0x27 provided
    func Add_MAC() {
        TX_B[d_byte] = MAC[0]
        d_byte += 1
        TX_B[d_byte] = MAC[1]
        d_byte += 1
        TX_B[d_byte] = MAC[2]
        d_byte += 1
        TX_B[d_byte] = MAC[3]
        d_byte += 1
        TX_B[d_byte] = MAC[4]
        d_byte += 1
        TX_B[d_byte] = MAC[5]
        d_byte += 1
    }
    
    /// Calculate checksum
    @discardableResult
    func Do_ChkSum() -> UInt8 {
        chksum_holder = 0
        
        for t in 1...30 {
            chksum_holder = chksum_holder + Int(TX_B[t])
        }
        
        ChkSum = UInt8(chksum_holder & 255)
        return ChkSum
    }
    
    /// Message ready for sending
    func Message_Set() {
        print("🔧 Message_Set() called - d_byte position: \(d_byte)")
        
        // Fill blanks with random bytes
        while d_byte < 31 {
            TX_B[d_byte] = rand_num(min: 1, max: 255)  // Add random bytes to fill unused bytes
            d_byte += 1
        }
        
        // Calculate checksum
        Do_ChkSum()
        
        // Put checksum in buffer
        TX_B[d_byte] = Do_ChkSum()
        d_byte += 1
        
        TX_B[d_byte] = 0x30
        d_byte += 1
        
        TX_B[d_byte] = 0x03
        //d_byte += 1
        
        print("🔧 BLE_Connected status: \(BLE_Connected)")
        print("🔧 TX_B d_byte length:  \(d_byte)")
        print("🔧 TX_B buffer ready:")// \(TX_B.map { String(format: "%02X", $0) //}.joined(separator: " "))")
        
        if BLE_Connected == 1 {
            print("🔧 Calling bleManager.sendBytes()...")
            
            if let manager = bleManager {
                print("✅ BLEManager exists - sending bytes")
                manager.sendBytes(TX_B)
            } else {
                print("❌ BLEManager is NIL - cannot send bytes")
            }
        } else {
            print("⚠️ BLE_Connected is NOT 1, message will not be sent")
        }
      
    }
    
    // MARK: - Helper Functions
    
    /// Generate random number between min and max (inclusive)
    private func rand_num(min: UInt8, max: UInt8) -> UInt8 {
        return UInt8.random(in: min...max)
    }
    
    // MARK: - Utility Functions
    
    /// Print current buffer state for debugging
    func printBuffer() {
        let hexString = TX_B.map { String(format: "%02X", $0) }.joined(separator: " ")
        print("TX_B: \(hexString)")
    }
    
    /// Get buffer as Data for transmission
    func getBufferAsData() -> Data {
        return Data(TX_B)
    }
}

// MARK: - SwiftUI Preview

struct MessageProtocol_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Message Protocol")
                .font(.title)
            Text("Check console for output")
                .foregroundColor(.secondary)
        }
        .onAppear {
            let protocol_handler = MessageProtocol()
            
            // Example usage
            protocol_handler.Message_Header()
            protocol_handler.Add_MAC()
            protocol_handler.Message_Set()
            protocol_handler.printBuffer()
        }
    }
}
