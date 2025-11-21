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
        
        // Check byte[5] to determine response type
        // byte[5] = 0x01: Profile roast started
        // byte[5] = 0x03: New profile accepted (uploaded but not started)
        // byte[5] = 0x04: Profile error
        // byte[5] = 0x05: No saved profile exists
        
        if bytes[5] == 0x01 {
            // Profile roast actually started - start timer and set roastInProcess
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
        }
        else if bytes[5] == 0x03 {
            // Profile uploaded successfully but NOT started
            // Do NOT set roastInProcess or start timer
            DispatchQueue.main.async { [weak self] in
                // Keep roastInProcess as false - this is just profile upload
                self?.controlState?.roastInProcess = false
                self?.controlState?.isProfileRoast = false
                
                // Update connection status to show profile accepted
                self?.bleManager?.connectionStatus = "New Profile Accepted"
                
                print("✅ Profile uploaded successfully (0x1C byte[5]=0x03)")
                print("ℹ️ roastInProcess remains false - profile uploaded but not started")
                
                // Clear connection status after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    self?.bleManager?.connectionStatus = ""
                }
            }
        }
        else if bytes[5] == 0x04 {
            // Profile error - do NOT start roast
            DispatchQueue.main.async { [weak self] in
                self?.controlState?.roastInProcess = false
                self?.controlState?.isProfileRoast = false
                
                // Update connection status to show profile error
                self?.bleManager?.connectionStatus = "Profile Error. Please Try Again"
                
                print("⚠️ Profile error (0x1C byte[5]=0x04)")
                print("ℹ️ roastInProcess remains false")
                
                // Clear connection status after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    self?.bleManager?.connectionStatus = ""
                }
            }
        }
        else if bytes[5] == 0x05 {
            // No saved profile - do NOT start roast
            DispatchQueue.main.async { [weak self] in
                self?.controlState?.roastInProcess = false
                self?.controlState?.isProfileRoast = false
                
                // Update connection status to show no profile
                self?.bleManager?.connectionStatus = "Roaster Does Not Have A Saved Profile"
                
                print("⚠️ No saved profile (0x1C byte[5]=0x05)")
                print("ℹ️ roastInProcess remains false")
                
                // Clear connection status after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    self?.bleManager?.connectionStatus = ""
                }
            }
        }
        else {
            // Unknown response - do NOT start roast
            DispatchQueue.main.async { [weak self] in
                self?.controlState?.roastInProcess = false
                self?.controlState?.isProfileRoast = false
                print("⚠️ Unknown 0x1C response: byte[5]=0x\(String(format: "%02X", bytes[5]))")
                print("ℹ️ roastInProcess set to false")
            }
        }
        
        // TODO: Add additional message parsing logic here

        
        
    }
}
