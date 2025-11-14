//
//  MacAddress_027.swift
//  SR900MacOS
//
//  Handles MAC address response message (0x27)
//

import Foundation

extension IncomingMessageHandler {
    /// Handle MAC address response message (0x27)
    func handleMacAddressMessage(_ bytes: [UInt8]) {
        guard bytes.count >= 14 else {
            print("⚠️ MAC message too short: \(bytes.count) bytes")
            return
        }
        
        // Verify it's a proper MAC response (bytes[5] == 0x00)
        guard bytes[5] == 0x00 else {
            print("⚠️ Invalid MAC message format")
            return
        }
        
        // Extract MAC address from bytes[7...12]
        let macBytes = Array(bytes[7...12])
        
        // Format MAC address as string for display
        let macString = macBytes.map { String(format: "%02X", $0) }.joined(separator: ":")
        
        print("✅ MAC Response → \(macString)")
        
        // Check if MAC address is authorized
        if let manager = self.bleManager {
            var isAuthorized = false
            var authorizationSource = ""
            
            // FIRST: Check if MAC address is in saved devices from BLE_Devices
            if manager.isMacAddressSaved(macString) {
                isAuthorized = true
                authorizationSource = "BLE_Devices (previously connected)"
                print("✅ MAC address found in saved devices (BLE_Devices)")
                
                // Show connection history
                if let history = manager.getConnectionHistory(for: macString) {
                    print("   First Approved: \(history.firstApproved ?? "Unknown")")
                    print("   Last Connected: \(history.lastConnected ?? "Unknown")")
                }
            }
            // SECOND: If not found in saved devices, check ApprovedMACAddresses.txt
            else if manager.approvedMacAddresses.contains(macString) {
                isAuthorized = true
                authorizationSource = "ApprovedMACAddresses.txt"
                print("✅ MAC address approved (ApprovedMACAddresses.txt)")
            }
            
            // If not authorized by either method, disconnect
            if !isAuthorized {
                print("⚠️ MAC address \(macString) not authorized - disconnecting")
                print("   Not found in: BLE_Devices OR ApprovedMACAddresses.txt")
                DispatchQueue.main.async {
                    manager.connectionStatus = "Unauthorized MAC: \(macString)"
                }
                // Disconnect after a brief delay to show the message
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    manager.disconnectDevice()
                }
                return
            }
            
            print("✅ MAC address authorized via: \(authorizationSource)")
            
            // Save MAC address to BLE_Devices directory (updates last connected time)
            manager.saveMacAddressToFile(macString)
        }
        
        // Update MessageProtocol headers using MAC bytes and keySeed
        if let manager = self.bleManager {
            let keySeed = manager.keySeed
            
            // Calculate new headers based on MAC and keySeed
            let header0 = (Int(macBytes[5]) * Int(keySeed[0])) & 0xFF
            let header1 = (Int(macBytes[4]) * Int(keySeed[1])) & 0xFF
            let header2 = (Int(macBytes[3]) * Int(keySeed[2])) & 0xFF
            let header3 = (Int(macBytes[2]) * Int(keySeed[3])) & 0xFF
            
            manager.messageProtocol.headers[0] = UInt8(header0)
            manager.messageProtocol.headers[1] = UInt8(header1)
            manager.messageProtocol.headers[2] = UInt8(header2)
            manager.messageProtocol.headers[3] = UInt8(header3)
            
            // Store MAC address in MessageProtocol
            manager.messageProtocol.MAC = macBytes
            
            print("🔑 Headers updated:")
            print("   MAC: [\(macBytes.map { String(format: "%02X", $0) }.joined(separator: ", "))]")
            print("   KeySeed: [\(keySeed.map { String(format: "%02X", $0) }.joined(separator: ", "))]")
            print("   New Headers: [\(manager.messageProtocol.headers.map { String(format: "%02X", $0) }.joined(separator: ", "))]")
        }
        
        // Update BLEManager properties on main thread
        DispatchQueue.main.async { [weak self] in
            guard let bleManager = self?.bleManager else { return }
            bleManager.receivedMAC = macString
            bleManager.connectionStatus = "MAC: \(macString)"
        }
        
        // Clear connection status after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.bleManager?.connectionStatus = ""
        }
    }
}
