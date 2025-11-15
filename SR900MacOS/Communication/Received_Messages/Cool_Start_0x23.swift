///
//  Cool_Start_0x24.swift
//  SR900MacOS
//
//  Handler for Profile Start Acknowledgment message (0x1C)
//

import Foundation

extension IncomingMessageHandler {
    
    /// Handle Profile Start Acknowledgment message (0x1C)
    /// - Parameter bytes: 34-byte message array from BLE
    func handleCoolStart(_ bytes: [UInt8]) {
        guard bytes.count >= 7 else {
            print("⚠️ ProfileStartAck message too short: \(bytes.count) bytes")
            return
        }
        
        // Verify message type
        guard bytes[6] == 0x23 else {
            print("⚠️ RoastStart called with wrong message type: 0x\(String(format: "%02X", bytes[6]))")
            return
        }
        
        print("✅ Cooling Started (0x23)")
        
        // Check byte[5] to determine if cooling is in process
        if bytes[5] == 0x00 {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                // Cooling has started - roast is still in process
                // roastInProcess stays TRUE until 0x24 (Roast Finished) is received
                self.controlState?.coolInProcess = true
                
                // Cancel any pending slider updates that might send unwanted 0x15 messages
                self.controlState?.cancelPendingSliderUpdates()
                
                // The roaster typically sets heat to 0 during cooling
                // This will be reported in status messages (0x21)
                // We don't manually set heatLevel here to avoid triggering didSet
                
                print("❄️ Cooling started:")
                print("   - roastInProcess: \(self.controlState?.roastInProcess ?? false) (unchanged)")
                print("   - coolInProcess: true")
                print("   - Cancelled pending slider updates")
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.controlState?.coolInProcess = false
                print("❄️ Cooling process: false")
            }
        }

        
        
    }
}

