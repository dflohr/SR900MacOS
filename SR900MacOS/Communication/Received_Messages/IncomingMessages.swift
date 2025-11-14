//
//  IncomingMessages.swift
//  SR900MacOS
//
//  Message parser for incoming BLE data from SR900 roaster
//

import Foundation
import Combine

class IncomingMessageHandler: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    weak var controlState: ControlState?
    private var checksumHolder: Int = 0
    
    // Make the bleManager property public or internal
    public weak var bleManager: BLEManager?

    // Initialize with reference to control state and BLE manager
    init(controlState: ControlState, bleManager: BLEManager? = nil) {
        self.controlState = controlState
        self.bleManager = bleManager
    }
    
    // MARK: - Main Message Processing
    /// Process incoming message bytes from SR900
    /// - Parameter bytes: 34-byte message array from BLE
    func processMessage(_ bytes: [UInt8]) {
        guard bytes.count >= 7 else {
            print("⚠️ Message too short: \(bytes.count) bytes")
            return
        }
        
        //verify checksum byte[31]
        
        for t in 1...30 {
            checksumHolder += Int(bytes[t])
        }
        let chkSum = checksumHolder & 0xFF   // mask to low 8 bits

        // Compare to byte[31] (C# index), which is bytes[31] in Swift (same index)
        if chkSum != bytes[31] {
            print("Bad Checksum")
        }
        else{
           // print("Good Checksum")
            checksumHolder = 0
        }
        

        // Get message type from byte[6]
        let messageType = bytes[6]
        
        // Route to appropriate handler based on message type
        switch messageType {
            
            
            case 0x0B:   //ResRoastTimeAckMessage(data);
                break
          
            case 0x0C:  // ResCoolTimeAckMessage(data);
                break
            
            case 0x1C:
                ProfileStartAck(bytes)
                
               
            case 0x20:  //ResFanHeaterAckMessage(data);
                break
            
            case 0x21:
                handleStatusMessage(bytes)
            
            case 0x22:  //ResRoasterStartedMessage(data);
                handleRoastStart(bytes)
            
            case 0x23:  //ResCoolerStartedMessage(data);
                handleCoolStart(bytes)
            
            case 0x24:  //ResRoasterFinishedMessage(data);
                handleRoastFinished(bytes)
            
            case 0x27:  //ResMacAddressMessage(data);
                handleMacAddressMessage(bytes)
            
            case 0x28:  //ResAdditionalCoolingRequiredMessage(data);
                break
            
        default:
            print("📨 Unknown message type: 0x\(String(format: "%02X", messageType))")
        }
    }
    
    // MARK: - Message Type Handlers
    
    // Temperature message (0x21) handler is implemented in Roaster_Status_0x21.swift extension
    // MAC address message (0x27) handler is implemented in MacAddress_027.swift extension
}


// MARK: - Message Type Constants

extension IncomingMessageHandler {
    
    /// SR900 Message Type Identifiers (byte[6])
    enum MessageType: UInt8 {
        case temperature = 0x21
        case macAddress = 0x27
        // Add more message types as you discover them
        // case fanSpeed = 0x??
        // case heatLevel = 0x??
        // case roastTime = 0x??
    }
}


// MARK: - Debug Helpers

extension IncomingMessageHandler {
    
    /// Print formatted hex dump of message
    func debugPrintMessage(_ bytes: [UInt8]) {
        let hex = bytes.map { String(format: "%02X", $0) }.joined(separator: " ")
        print("📦 Message [\(bytes.count) bytes]: \(hex)")
        
        if bytes.count >= 7 {
            print("   Message Type: 0x\(String(format: "%02X", bytes[6]))")
        }
    }
}
