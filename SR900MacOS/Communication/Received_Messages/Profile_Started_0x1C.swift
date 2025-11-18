//
//  ProfileStartAck_0x1C.swift
//  SR900MacOS
//
//  Handler for Profile Start Acknowledgment message (0x1C)
//

import Foundation

extension IncomingMessageHandler {
    
    /// Handle Profile Start Acknowledgment message (0x1C)
    /// - Parameter bytes: 34-byte message array from BLE
    func ProfileStartAck(_ bytes: [UInt8]) {
        guard bytes.count >= 7 else {
            print("⚠️ ProfileStartAck message too short: \(bytes.count) bytes")
            return
        }
        
        // Verify message type
        guard bytes[6] == 0x1C else {
            print("⚠️ ProfileStartAck called with wrong message type: 0x\(String(format: "%02X", bytes[6]))")
            return
        }
        
        print("✅ Profile Start Acknowledged (0x1C)")
        
        // Check byte[5] to determine if roast is in process
        if bytes[5] == 0x01 {
            DispatchQueue.main.async { [weak self] in
                self?.controlState?.roastInProcess = true
                self?.controlState?.isProfileRoast = true  // Mark as profile roast
                
                // Update connection status to show profile roast started
                self?.bleManager?.connectionStatus = "Profile Roast Started"
                
                print("🔥 Roast in process: true (Profile Roast)")
                print("⚠️ DO NOT send 0x15 Start Manual Roast - profile roast is already started")
                
                // Clear connection status after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    self?.bleManager?.connectionStatus = ""
                }
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.controlState?.roastInProcess = false
                self?.controlState?.isProfileRoast = false
                print("🔥 Roast in process: false")
            }
        }
        
        // TODO: Add additional message parsing logic here

        
        
    }
}
