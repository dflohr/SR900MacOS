///
//  RoastStart_0x22.swift
//  SR900MacOS
//
//  Handler for Profile Start Acknowledgment message (0x1C)
//

import Foundation

extension IncomingMessageHandler {
    
    /// Handle Profile Start Acknowledgment message (0x1C)
    /// - Parameter bytes: 34-byte message array from BLE
    func handleRoastFinished(_ bytes: [UInt8]) {
        guard bytes.count >= 7 else {
            print("⚠️ ProfileStartAck message too short: \(bytes.count) bytes")
            return
        }
        
        // Verify message type
        guard bytes[6] == 0x24 else {
            print("⚠️ RoastStart called with wrong message type: 0x\(String(format: "%02X", bytes[6]))")
            return
        }
        
        print("✅ Roast Start Acknowledged (0x24)")
        
        // Check byte[5] to determine if roast is in process
        if bytes[5] == 0x00 {
            DispatchQueue.main.async { [weak self] in
                self?.controlState?.roastInProcess = false
                
                print("🔥 Roast in process: true")
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.controlState?.roastInProcess = false
                print("🔥 Roast in process: false")
            }
        }
        
        // Reset all sliders to 0
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let controlState = self.controlState else { return }
            
            // Cancel any pending debounced slider updates
            controlState.cancelPendingSliderUpdates()
            
            // Reset slider values
            controlState.fanMotorLevel = 0
            controlState.heatLevel = 0
            controlState.roastingTime = 0
            controlState.coolingTime = 0
            
            print("🔄 Sliders reset to 0")
        }
        
        // TODO: Add additional message parsing logic here

        
        
    }
}

