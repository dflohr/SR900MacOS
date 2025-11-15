///
//  Roast_Finished_0x24.swift
//  SR900MacOS
//
//  Handler for Roast Finished message (0x24)
//

import Foundation

extension IncomingMessageHandler {
    
    /// Handle Roast Finished message (0x24)
    /// - Parameter bytes: 34-byte message array from BLE
    /// - Note: Only bytes 0-12 are processed (header, message type, MAC). Bytes 13+ are ignored per protocol spec.
    func handleRoastFinished(_ bytes: [UInt8]) {
        guard bytes.count >= 13 else {
            print("⚠️ RoastFinished message too short: \(bytes.count) bytes (need at least 13)")
            return
        }
        
        // Verify message type
        guard bytes[6] == 0x24 else {
            print("⚠️ RoastFinished called with wrong message type: 0x\(String(format: "%02X", bytes[6]))")
            return
        }
        
        print("✅ Roast Finished (0x24)")
        print("   Processing only bytes[0-12], ignoring bytes[13-33]")
        
        // Only process bytes 0-12:
        // bytes[0-4]: Header
        // bytes[5]: Subtype
        // bytes[6]: Message type (0x24)
        // bytes[7-12]: MAC address
        // bytes[13-33]: IGNORED (unreliable/unused data)
        
        // Roast is complete - reset both roast and cool flags
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let controlState = self.controlState else { return }
            
            // Cancel any pending debounced slider updates
            controlState.cancelPendingSliderUpdates()
            
            // Roast is now complete
            controlState.roastInProcess = false
            controlState.coolInProcess = false
            
            print("✅ Roast complete:")
            print("   - roastInProcess: false")
            print("   - coolInProcess: false")
            
            // Reset ALL sliders to 0 (including time sliders)
            controlState.fanMotorLevel = 0
            controlState.heatLevel = 0
            controlState.roastingTime = 0
            controlState.coolingTime = 0
            
            print("🔄 All sliders reset to 0 (fan, heat, roast time, cool time)")
        }
        
        // Optional debug: Show only relevant bytes
        if bytes.count >= 13 {
            let relevantBytes = Array(bytes[0...12])
            let hexString = relevantBytes.map { String(format: "%02X", $0) }.joined(separator: " ")
            print("📦 Relevant bytes[0-12]: \(hexString)")
        }
    }
}


