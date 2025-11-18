//
//  AdditionalCoolingRequired_0x28.swift
//  SR900MacOS
//
//  Handles additional cooling required message (0x28)
//

import Foundation

extension IncomingMessageHandler {
    
    /// Handle additional cooling required message (0x28)
    /// - Parameter bytes: 34-byte message array from BLE
    /// - Note: This message is sent by the roaster when it determines additional cooling time is needed
    func handleAdditionalCoolingRequired(_ bytes: [UInt8]) {
        guard bytes.count >= 7 else {
            print("⚠️ Additional cooling message too short: \(bytes.count) bytes")
            return
        }
        
        // Verify message type is 0x28
        guard bytes[6] == 0x28 else {
            print("⚠️ Invalid additional cooling message type: 0x\(String(format: "%02X", bytes[6]))")
            return
        }
        
        print("❄️ Additional Cooling Required (0x28)")
        
        // TODO: Parse additional cooling time if available in message
        // Example: If cooling time is in bytes[7-8]:
        // let additionalCoolingTime: Int
        // if bytes.count > 8 {
        //     additionalCoolingTime = (Int(bytes[7]) << 8) | Int(bytes[8])
        //     print("   Additional cooling time: \(additionalCoolingTime) seconds")
        // }
        
        // Update control state on main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let controlState = self.controlState else { return }
            
            // Display message on connectionStatus
            self.bleManager?.connectionStatus = "Additional Cooling is Underway"
            print("❄️ Roaster requesting additional cooling time")
            
            // Clear the message after 3 seconds
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                self?.bleManager?.connectionStatus = ""
            }
        }
        
        // Debug: Print full message for analysis
        if bytes.count >= 16 {
            let relevantBytes = Array(bytes[7...15])
            let hexString = relevantBytes.map { String(format: "%02X", $0) }.joined(separator: " ")
            print("   Message data: \(hexString)")
        }
    }
}


// MARK: - Additional Cooling Utilities

extension IncomingMessageHandler {
    
    /// Parse cooling time from message bytes
    /// - Parameters:
    ///   - bytes: Message byte array
    ///   - startIndex: Starting byte index for cooling time
    /// - Returns: Cooling time in seconds, or 0 if parsing fails
    func parseAdditionalCoolingTime(from bytes: [UInt8], startIndex: Int) -> Int {
        guard bytes.count > startIndex + 1 else { return 0 }
        // Big-endian: Most significant byte first
        return (Int(bytes[startIndex]) << 8) | Int(bytes[startIndex + 1])
    }
}


// MARK: - Debug Helpers

extension IncomingMessageHandler {
    
    /// Print additional cooling message details for debugging
    func debugPrintAdditionalCooling(_ bytes: [UInt8]) {
        print("🔍 Additional Cooling Message Debug:")
        print("   Message Type (byte[6]): 0x\(String(format: "%02X", bytes[6]))")
        
        if bytes.count >= 10 {
            print("   Bytes[7-9]: \(bytes[7..<10].map { String(format: "%02X", $0) }.joined(separator: " "))")
        }
        
        // Print full message
        let hexString = bytes.map { String(format: "%02X", $0) }.joined(separator: " ")
        print("   Full message: \(hexString)")
    }
}
