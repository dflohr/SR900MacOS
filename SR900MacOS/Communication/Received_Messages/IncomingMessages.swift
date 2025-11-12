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
    public var bleManager: BLEManager?

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
                handleTemperatureMessage(bytes)
            
            case 0x22:  //ResRoasterStartedMessage(data);
                break
            
            case 0x23:  //ResCoolerStartedMessage(data);
                break
            
            case 0x24:  //ResRoasterFinishedMessage(data);
                break
            
            case 0x27:  //ResMacAddressMessage(data);
                handleMacAddressMessage(bytes)
            
            case 0x28:  //ResAdditionalCoolingRequiredMessage(data);
                break
            
        default:
            print("📨 Unknown message type: 0x\(String(format: "%02X", messageType))")
        }
    }
    
    // MARK: - Message Type Handlers
    
    /// Handle temperature data message (0x21)
    private func handleTemperatureMessage(_ bytes: [UInt8]) {
        // TODO: Verify the correct byte positions for SR900 temperature data
        // These byte positions are PLACEHOLDERS - adjust based on SR900 protocol documentation
        
        guard bytes.count >= 10 else {
            print("⚠️ Temperature message too short: \(bytes.count) bytes")
            return
        }
        
        let rawTemp: Int
        
        // Option 1: If temperature is 16-bit value (2 bytes) - BIG ENDIAN
        rawTemp = (Int(bytes[15]) << 8) | Int(bytes[16])
        
        // Option 2: If temperature is 16-bit value (2 bytes) - LITTLE ENDIAN
        // rawTemp = (Int(bytes[9]) << 8) | Int(bytes[8])
        
        // Option 3: If temperature is single byte value
        // rawTemp = Int(bytes[8])
        
        // Option 4: If temperature needs conversion formula (e.g., Celsius to Fahrenheit)
        // let celsius = (Int(bytes[8]) << 8) | Int(bytes[9])
        // rawTemp = (celsius * 9 / 5) + 32
        
        // Update control state on main thread
        DispatchQueue.main.async { [weak self] in
            self?.controlState?.beanTempValue = rawTemp
           // print("🌡️ Updated temperature to: \(rawTemp)°F")
        }
    }

    // MAC address message (0x27) handler is implemented in MacAddress_027.swift extension
}


// MARK: - Temperature Parsing Utilities

extension IncomingMessageHandler {
    
    /// Parse 16-bit temperature value (big-endian)
    private func parseTemperatureBigEndian(from bytes: [UInt8], startIndex: Int) -> Int {
        guard bytes.count > startIndex + 1 else { return 0 }
        return (Int(bytes[startIndex]) << 8) | Int(bytes[startIndex + 1])
    }
    
    /// Parse 16-bit temperature value (little-endian)
    private func parseTemperatureLittleEndian(from bytes: [UInt8], startIndex: Int) -> Int {
        guard bytes.count > startIndex + 1 else { return 0 }
        return (Int(bytes[startIndex + 1]) << 8) | Int(bytes[startIndex])
    }
    
    /// Convert Celsius to Fahrenheit
    private func celsiusToFahrenheit(_ celsius: Int) -> Int {
        return (celsius * 9 / 5) + 32
    }
    
    /// Parse scaled temperature (e.g., value / 10)
    private func parseScaledTemperature(from bytes: [UInt8], startIndex: Int, scale: Int = 10) -> Int {
        guard bytes.count > startIndex + 1 else { return 0 }
        let rawValue = (Int(bytes[startIndex]) << 8) | Int(bytes[startIndex + 1])
        return rawValue / scale
    }
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
    
    /// Print temperature bytes for debugging
    func debugPrintTemperatureBytes(_ bytes: [UInt8]) {
        guard bytes.count >= 10 else { return }
        
        print("🔍 Temperature Debug:")
        print("   Bytes[8-9]: \(String(format: "%02X %02X", bytes[8], bytes[9]))")
        print("   Big-Endian: \(parseTemperatureBigEndian(from: bytes, startIndex: 8))")
        print("   Little-Endian: \(parseTemperatureLittleEndian(from: bytes, startIndex: 8))")
        print("   Byte[8] only: \(bytes[8])")
        print("   Byte[9] only: \(bytes[9])")
    }
}
