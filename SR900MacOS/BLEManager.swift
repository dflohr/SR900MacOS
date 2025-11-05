////
////  BLEManager.swift
////  SR900MacOS
////
////  BLE connection manager for SR900 coffee roaster
////
//
//import Foundation
//import SwiftUI
//import Combine
//import IPWorksBLE
//
//class BLEManager: NSObject, ObservableObject, BLEClientDelegate {
//    @Published var isConnected = false
//    @Published var isScanning = false
//    @Published var sr900Device: (name: String, macAddress: String)? = nil
//    @Published var connectionStatus: String = "Not Connected"
//    
//    private var bleClient: BLEClient
//    private var targetDeviceName = "SR900"  // Will match any device starting with "SR900"
//    
//    override init() {
//        bleClient = BLEClient()
//        super.init()
//        bleClient.delegate = self
//        
//        // Enable active scanning to receive scan responses with full device names
//        bleClient.activeScanning = true
//        
//        // Set log level for debugging (1=Error, 2=Info, 3=Debug)
//        try? _ = bleClient.config(configurationString: "LogLevel=2")
//        
//        // Start scanning for SR900 device automatically
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            self.startAutoScan()
//        }
//    }
//    
//    // MARK: - Public Functions
//    
//    /// Toggle connection: Connect if disconnected, Disconnect if connected
//    func toggleConnection() {
//        if isConnected {
//            disconnectDevice()
//        } else {
//            if let device = sr900Device {
//                connectDevice(macAddress: device.macAddress)
//            } else {
//                connectionStatus = "No SR900 device found"
//                print("No SR900 device available to connect")
//            }
//        }
//    }
//    
//    /// Start automatic scanning for SR900 devices
//    func startAutoScan() {
//        guard !isScanning else { return }
//        
//        isScanning = true
//        connectionStatus = "Scanning for SR900..."
//        
//        do {
//            print("Starting BLE scan for SR900 devices...")
//            try bleClient.startScanning(serviceUuids: "")
//        } catch {
//            print("Error starting scan: \(error.localizedDescription)")
//            connectionStatus = "Scan Error"
//            isScanning = false
//        }
//    }
//    
//    /// Stop scanning for devices
//    func stopScan() {
//        guard isScanning else { return }
//        
//        do {
//            try bleClient.stopScanning()
//            isScanning = false
//            
//            if sr900Device != nil {
//                connectionStatus = "SR900 Found"
//            } else {
//                connectionStatus = "No SR900 Found"
//            }
//            
//            print("Scan stopped")
//        } catch {
//            print("Error stopping scan: \(error.localizedDescription)")
//        }
//    }
//    
//    // MARK: - Private Functions
//    
//    private func connectDevice(macAddress: String) {
//        connectionStatus = "Connecting..."
//        print("Connecting to SR900: \(macAddress)")
//        
//        DispatchQueue.global(qos: .userInitiated).async {
//            do {
//                self.bleClient.timeout = 15
//                try self.bleClient.connect(serverId: macAddress)
//                
//                DispatchQueue.main.async {
//                    self.isConnected = true
//                    self.connectionStatus = "Connected"
//                    print("✓ Connected to SR900 successfully!")
//                }
//                
//                // Discover services
//                print("Discovering services...")
//                try self.bleClient.discover(
//                    serviceUuids: "",
//                    characteristicUuids: "",
//                    discoverDescriptors: true,
//                    includedByServiceId: ""
//                )
//                
//                print("Found \(self.bleClient.services.count) service(s)")
//                
//            } catch {
//                DispatchQueue.main.async {
//                    self.connectionStatus = "Connection Failed"
//                    print("✗ Connection failed: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//    
//    private func disconnectDevice() {
//        connectionStatus = "Disconnecting..."
//        print("Disconnecting from SR900...")
//        
//        DispatchQueue.global(qos: .userInitiated).async {
//            do {
//                try self.bleClient.disconnect()
//                DispatchQueue.main.async {
//                    self.isConnected = false
//                    self.connectionStatus = "Disconnected"
//                    print("✓ Disconnected from SR900")
//                    
//                    // Restart scanning for SR900 after disconnect
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                        self.startAutoScan()
//                    }
//                }
//            } catch {
//                DispatchQueue.main.async {
//                    self.connectionStatus = "Disconnect Error"
//                    print("✗ Disconnect error: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//    
//    // MARK: - BLEClientDelegate Methods (Correct Signatures)
//    
//    func onAdvertisement(
//        serverId: String,
//        name: String,
//        rssi: Int32,
//        txPower: Int32,
//        serviceUuids: String,
//        servicesWithData: String,
//        solicitedServiceUuids: String,
//        manufacturerCompanyId: Int32,
//        manufacturerData: Data,
//        isConnectable: Bool,
//        isScanResponse: Bool
//    ) {
//        // Only look for devices whose name STARTS WITH "SR900"
//        // This will match: SR900, SR900-001, SR900_ModelA, etc.
//        guard name.hasPrefix(targetDeviceName) else { return }
//        
//        DispatchQueue.main.async {
//            // Always update when we're scanning and not connected
//            // This ensures status updates to "SR900 Found" after reconnect
//            let shouldUpdate = self.sr900Device == nil || 
//                               self.sr900Device?.name != name || 
//                               !self.isConnected
//            
//            if shouldUpdate {
//                self.sr900Device = (name: name, macAddress: serverId)
//                self.connectionStatus = "SR900 Found"
//                print("✓ Found SR900 device: \(name) (\(serverId)) [RSSI: \(rssi)]")
//                
//                // Stop scanning once we find an SR900 device
//                self.stopScan()
//            }
//        }
//    }
//    
//    func onConnected(statusCode: Int32, description: String) {
//        print("Connected: \(description)")
//    }
//    
//    func onDisconnected(statusCode: Int32, description: String) {
//        print("Disconnected: \(description)")
//        DispatchQueue.main.async {
//            self.isConnected = false
//            self.connectionStatus = "Disconnected"
//        }
//    }
//    
//    func onDiscovered(gattType: Int32, serviceId: String, characteristicId: String, descriptorId: String, uuid: String, description: String) {
//        // gattType: 1=Service, 2=Characteristic, 3=Descriptor
//        switch gattType {
//        case 1:
//            print("Service discovered: \(description.isEmpty ? uuid : description)")
//        case 2:
//            print("Characteristic discovered: \(description.isEmpty ? uuid : description)")
//        case 3:
//            print("Descriptor discovered: \(description.isEmpty ? uuid : description)")
//        default:
//            break
//        }
//    }
//    
//    func onError(errorCode: Int32, description: String) {
//        print("Error: \(description) (code: \(errorCode))")
//        DispatchQueue.main.async {
//            self.connectionStatus = "Error: \(description)"
//        }
//    }
//    
//    func onLog(logLevel: Int32, message: String, logType: String) {
//        // Optional: log messages for debugging
//        if logLevel >= 2 {
//            print("Log [\(logType)]: \(message)")
//        }
//    }
//    
//    func onPairingRequest(serverId: String, pairingKind: Int32, pin: inout String, accept: inout Bool) {
//        print("Pairing request from: \(serverId)")
//        accept = true // Auto-accept pairing for SR900
//    }
//    
//    func onServerUpdate(name: String, changedServices: String) {
//        print("Server updated: \(name)")
//    }
//    
//    func onStartScan(serviceUuids: String) {
//        print("Scan started successfully")
//    }
//    
//    func onStopScan(errorCode: Int32, errorDescription: String) {
//        if errorCode != 0 {
//            print("Scan stopped with error: \(errorDescription)")
//        } else {
//            print("Scan stopped")
//        }
//    }
//    
//    func onSubscribed(serviceId: String, characteristicId: String, uuid: String, description: String) {
//        print("Subscribed to: \(description.isEmpty ? uuid : description)")
//    }
//    
//    func onUnsubscribed(serviceId: String, characteristicId: String, uuid: String, description: String) {
//        print("Unsubscribed from: \(description.isEmpty ? uuid : description)")
//    }
//    
//    func onValue(serviceId: String, characteristicId: String, descriptorId: String, uuid: String, description: String, value: Data) {
//        print("Value received: \(description.isEmpty ? uuid : description) - \(value.count) bytes")
//        // TODO: Handle incoming data from SR900 (temperature, status, etc.)
//    }
//    
//    func onWriteResponse(serviceId: String, characteristicId: String, descriptorId: String, uuid: String, description: String) {
//        print("Write response: \(description.isEmpty ? uuid : description)")
//    }
//}
//
//  BLEManager.swift
//  SR900MacOS
//
//  BLE connection manager for SR900 coffee roaster
//  Uses CoreBluetooth for discovery (to get complete local name)
//  Uses IPWorks for connection and communication
//

import Foundation
import SwiftUI
import Combine
import CoreBluetooth
import IPWorksBLE

class BLEManager: NSObject, ObservableObject, BLEClientDelegate, CBCentralManagerDelegate {
    @Published var isConnected = false
    @Published var isScanning = false
    @Published var sr900Device: (name: String, peripheral: CBPeripheral)? = nil
    @Published var connectionStatus: String = "Not Connected"
    @Published var discoveredDevices: [(name: String, peripheral: CBPeripheral, rssi: Int)] = []
    
    private var bleClient: BLEClient
    private var centralManager: CBCentralManager!
    private var targetDeviceName = "SR900"
    
    // Store the mapping of peripheral to complete name
    private var peripheralToName: [UUID: String] = [:]
    private var peripheralToRSSI: [UUID: Int] = [:]
    
    override init() {
        bleClient = BLEClient()
        super.init()
        
        bleClient.delegate = self
        bleClient.activeScanning = true
        try? _ = bleClient.config(configurationString: "LogLevel=2")
        
        // Initialize CoreBluetooth - THIS is the Apple framework Daniel mentioned
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - CoreBluetooth Delegate (Apple Framework for Complete Local Name)
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("✓ CoreBluetooth powered on")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.startAutoScan()
            }
        case .poweredOff:
            connectionStatus = "Bluetooth Off"
        case .unauthorized:
            connectionStatus = "Bluetooth Unauthorized"
        case .unsupported:
            connectionStatus = "Bluetooth Not Supported"
        default:
            print("CoreBluetooth state: \(central.state.rawValue)")
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                       didDiscover peripheral: CBPeripheral,
                       advertisementData: [String: Any],
                       rssi RSSI: NSNumber) {
        
        // THIS IS THE KEY: Get the COMPLETE local name from advertisement data
        // IPWorks cannot access this - only CoreBluetooth can
        guard let completeLocalName = advertisementData[CBAdvertisementDataLocalNameKey] as? String else {
            return
        }
        
        // Check if it's an SR900 device
        guard completeLocalName.hasPrefix(targetDeviceName) else {
            return
        }
        
        let rssiValue = RSSI.intValue
        
        print("📡 Found SR900 via CoreBluetooth:")
        print("   Complete Name: \(completeLocalName)")  // e.g., "SR900A1B2C3"
        print("   Peripheral UUID: \(peripheral.identifier.uuidString)")
        print("   RSSI: \(rssiValue) dBm")
        
        // Store the complete name mapping
        peripheralToName[peripheral.identifier] = completeLocalName
        peripheralToRSSI[peripheral.identifier] = rssiValue
        
        DispatchQueue.main.async {
            // Update discovered devices list
            let existingIndex = self.discoveredDevices.firstIndex { $0.peripheral.identifier == peripheral.identifier }
            
            if let index = existingIndex {
                // Update existing entry
                self.discoveredDevices[index] = (
                    name: completeLocalName,
                    peripheral: peripheral,
                    rssi: rssiValue
                )
            } else {
                // Add new entry
                self.discoveredDevices.append((
                    name: completeLocalName,
                    peripheral: peripheral,
                    rssi: rssiValue
                ))
            }
            
            // Auto-select first SR900 if none selected
            if self.sr900Device == nil {
                self.sr900Device = (name: completeLocalName, peripheral: peripheral)
                self.connectionStatus = "Found: \(completeLocalName)"
                print("✓ Auto-selected: \(completeLocalName)")
                
                // Optionally stop scanning after finding first device
                // self.stopScan()
            }
        }
    }
    
    // MARK: - Public Functions
    
    func toggleConnection() {
        if isConnected {
            disconnectDevice()
        } else {
            if let device = sr900Device {
                connectDevice(peripheral: device.peripheral, name: device.name)
            } else {
                connectionStatus = "No SR900 device found"
                print("No SR900 device available to connect")
            }
        }
    }
    
    func startAutoScan() {
        guard !isScanning else { return }
        guard centralManager.state == .poweredOn else {
            print("⚠️ Cannot scan - Bluetooth not ready")
            return
        }
        
        isScanning = true
        connectionStatus = "Scanning for SR900..."
        
        // Clear previous discoveries
        discoveredDevices.removeAll()
        peripheralToName.removeAll()
        peripheralToRSSI.removeAll()
        
        print("🔍 Starting CoreBluetooth scan...")
        
        // Scan for all peripherals
        // We filter by name in the didDiscover callback
        centralManager.scanForPeripherals(
            withServices: nil,
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        )
    }
    
    func stopScan() {
        guard isScanning else { return }
        
        centralManager.stopScan()
        isScanning = false
        
        connectionStatus = sr900Device != nil ? "SR900 Found" : "No SR900 Found"
        print("Scan stopped")
    }
    
    func selectDevice(name: String, peripheral: CBPeripheral) {
        sr900Device = (name: name, peripheral: peripheral)
        connectionStatus = "Selected: \(name)"
        print("Selected device: \(name)")
    }
    
    // MARK: - Private Functions
    
    private func connectDevice(peripheral: CBPeripheral, name: String) {
        connectionStatus = "Connecting..."
        print("Connecting to \(name)...")
        print("   Peripheral UUID: \(peripheral.identifier.uuidString)")
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                self.bleClient.timeout = 15
                
                // Connect using the peripheral's UUID
                // IPWorks uses this UUID to identify the device
                try self.bleClient.connect(serverId: peripheral.identifier.uuidString)
                
                DispatchQueue.main.async {
                    self.isConnected = true
                    self.connectionStatus = "Connected: \(name)"
                    print("✓ Connected to \(name)")
                }
                
                // Discover services
                print("Discovering services...")
                try self.bleClient.discover(
                    serviceUuids: "",
                    characteristicUuids: "",
                    discoverDescriptors: true,
                    includedByServiceId: ""
                )
                
                print("Found \(self.bleClient.services.count) service(s)")
                
            } catch {
                DispatchQueue.main.async {
                    self.connectionStatus = "Connection Failed"
                    print("✗ Connection failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /*private*/ func disconnectDevice() {
        guard let device = sr900Device else { return }
        
        connectionStatus = "Disconnecting..."
        print("Disconnecting from \(device.name)...")
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.bleClient.disconnect()
                
                DispatchQueue.main.async {
                    self.isConnected = false
                    self.connectionStatus = "Disconnected"
                    print("✓ Disconnected")
                    
                    // Restart scanning
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.startAutoScan()
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.connectionStatus = "Disconnect Error"
                    print("✗ Disconnect error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - BLEClientDelegate Methods (IPWorks)
    
    func onAdvertisement(
        serverId: String,
        name: String,
        rssi: Int32,
        txPower: Int32,
        serviceUuids: String,
        servicesWithData: String,
        solicitedServiceUuids: String,
        manufacturerCompanyId: Int32,
        manufacturerData: Data,
        isConnectable: Bool,
        isScanResponse: Bool
    ) {
        // Not used - we rely on CoreBluetooth for discovery
        // This is because IPWorks cannot see the complete local name
    }
    
    func onConnected(statusCode: Int32, description: String) {
        print("IPWorks: Connected - \(description)")
    }
    
    func onDisconnected(statusCode: Int32, description: String) {
        print("IPWorks: Disconnected - \(description)")
        DispatchQueue.main.async {
            self.isConnected = false
            self.connectionStatus = "Disconnected"
        }
    }
    
    func onDiscovered(gattType: Int32, serviceId: String, characteristicId: String, descriptorId: String, uuid: String, description: String) {
        switch gattType {
        case 1:
            print("Service: \(description.isEmpty ? uuid : description)")
        case 2:
            print("Characteristic: \(description.isEmpty ? uuid : description)")
        case 3:
            print("Descriptor: \(description.isEmpty ? uuid : description)")
        default:
            break
        }
    }
    
    func onError(errorCode: Int32, description: String) {
        print("IPWorks Error: \(description) (code: \(errorCode))")
        DispatchQueue.main.async {
            self.connectionStatus = "Error: \(description)"
        }
    }
    
    func onLog(logLevel: Int32, message: String, logType: String) {
        if logLevel >= 2 {
            print("[\(logType)]: \(message)")
        }
    }
    
    func onPairingRequest(serverId: String, pairingKind: Int32, pin: inout String, accept: inout Bool) {
        print("Pairing request")
        accept = true
    }
    
    func onServerUpdate(name: String, changedServices: String) {
        print("Server updated: \(name)")
    }
    
    func onStartScan(serviceUuids: String) {
        print("IPWorks: Scan started")
    }
    
    func onStopScan(errorCode: Int32, errorDescription: String) {
        if errorCode != 0 {
            print("IPWorks: Scan error - \(errorDescription)")
        }
    }
    
    func onSubscribed(serviceId: String, characteristicId: String, uuid: String, description: String) {
        print("Subscribed: \(description.isEmpty ? uuid : description)")
    }
    
    func onUnsubscribed(serviceId: String, characteristicId: String, uuid: String, description: String) {
        print("Unsubscribed: \(description.isEmpty ? uuid : description)")
    }
    
    func onValue(serviceId: String, characteristicId: String, descriptorId: String, uuid: String, description: String, value: Data) {
        print("Value: \(description.isEmpty ? uuid : description) - \(value.count) bytes")
        // TODO: Handle roaster data
    }
    
    func onWriteResponse(serviceId: String, characteristicId: String, descriptorId: String, uuid: String, description: String) {
        print("Write response: \(description.isEmpty ? uuid : description)")
    }
}
