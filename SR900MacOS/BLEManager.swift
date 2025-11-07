//
//  BLEManager.swift
//  SR900MacOS
//
//  Hybrid BLE Manager using CoreBluetooth + IPWorksBLE
//  - CoreBluetooth: Extracts Complete Local Name (AD 0x09) and Shortened Local Name (AD 0x08)
//  - IPWorksBLE: Handles device connections and communication
//

import Foundation
import SwiftUI
import Combine
import IPWorksBLE
import CoreBluetooth

class BLEManager: NSObject, ObservableObject, BLEClientDelegate, CBCentralManagerDelegate {
    
    // MARK: - Configuration
    
    /// Enable/Disable CoreBluetooth AD 0x09 name extraction
    /// Set to false to use IPWorksBLE only (faster but less accurate names)
    /// Set to true to use hybrid CoreBluetooth + IPWorksBLE (slower but accurate AD 0x09 names)
    private let enableAD0x09Discovery: Bool = false
    
    // MARK: - Published Properties
    
    @Published var isConnected = false
    @Published var isScanning = false
    @Published var sr900Device: (name: String, macAddress: String)? = nil
    @Published var connectionStatus: String = "Not Connected"
    
    // IPWorksBLE for connections
    private var bleClient: BLEClient
    
    // CoreBluetooth for proper name extraction
    private var centralManager: CBCentralManager!
    private var isCoreBTInitialized = false
    
    // Track complete names extracted via CoreBluetooth (AD 0x09)
    private var completeNames: [String: String] = [:]
    
    // Track the writable DF02 characteristic for sending commands
    private var writableCharacteristic: (serviceId: String, characteristicId: String, uuid: String)? = nil
    
    private var targetDeviceName = "SR900"  // Will match any device starting with "SR900"
    
    override init() {
        bleClient = BLEClient()
        super.init()
        bleClient.runtimeLicense = "3131434A4D444E5852463230323631313035423554433134333600444E5842574A4746464246470030303030303030300000395A385655534248335A53530000"
        // Initialize IPWorksBLE
        bleClient.delegate = self
        bleClient.activeScanning = true
        
        // Set log level for debugging (1=Error, 2=Info, 3=Debug)
        try? _ = bleClient.config(configurationString: "LogLevel=2")
        
        // Initialize CoreBluetooth for name extraction (if enabled)
        if enableAD0x09Discovery {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.centralManager = CBCentralManager(
                    delegate: self,
                    queue: .main,
                    options: [CBCentralManagerOptionShowPowerAlertKey: NSNumber(value: true)]
                )
                self.isCoreBTInitialized = true
            }
            
          //  print("Hybrid BLE Manager initialized (CoreBluetooth + IPWorksBLE)")
          //  print("  - CoreBluetooth: For AD 0x09 (Complete Local Name) extraction")
           // print("  - IPWorksBLE: For device connections")
        } else {
          //  print("IPWorksBLE-only BLE Manager initialized")
          //  print("  - AD 0x09 discovery: DISABLED")
          //  print("  - Using IPWorksBLE names only (faster but may be truncated)")
        }
        
        // Start scanning for SR900 device automatically
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.startAutoScan()
        }
    }
    
    // MARK: - Public Functions
    
    /// Toggle connection: Connect if disconnected, Disconnect if connected
    func toggleConnection() {
        if isConnected {
            disconnectDevice()
        } else {
            if let device = sr900Device {
                connectDevice(macAddress: device.macAddress)
            } else {
                connectionStatus = "No SR900 device found"
              //  print("No SR900 device available to connect")
            }
        }
    }
    
    /// Send data to the SR900 device via the writable DF02 characteristic
    func sendData(_ text: String) {
        guard let writable = writableCharacteristic else {
          //  print("⚠ No writable characteristic found (DF02)")
            connectionStatus = "No writable characteristic"
            return
        }
        
        guard let data = text.data(using: .utf8) else {
           // print("✗ Failed to convert text to data")
            return
        }
        
        print("📤 Sending to \(writable.uuid): '\(text)' (\(data.count) bytes)")
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.bleClient.writeValue(
                    serviceId: writable.serviceId,
                    characteristicId: writable.characteristicId,
                    descriptorId: "",
                    value: data
                )
                
                DispatchQueue.main.async {
                   // print("✓ Write initiated to \(writable.uuid)")
                }
            } catch let error {
                DispatchQueue.main.async {
                   // print("✗ Failed to write: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Start automatic scanning for SR900 devices
    func startAutoScan() {
        guard !isScanning else { return }
        
        isScanning = true
        connectionStatus = "Scanning for SR900..."
        
        print("═══════════════════════════════════")
        if enableAD0x09Discovery {
          //  print("Starting hybrid BLE scan...")
        } else {
          //  print("Starting IPWorksBLE-only scan...")
        }
        
        // Start CoreBluetooth scan for Complete Local Name (AD 0x09) extraction (if enabled)
        if enableAD0x09Discovery && isCoreBTInitialized && centralManager.state == .poweredOn {
            print("✓ CoreBluetooth scanning started (for Complete Local Name extraction)")
            // IMPORTANT: Allow duplicates so CoreBluetooth keeps discovering the device
            // This helps with reconnection scenarios
            centralManager.scanForPeripherals(
                withServices: nil,
                options: [CBCentralManagerScanOptionAllowDuplicatesKey: NSNumber(value: true)]
            )
        } else if enableAD0x09Discovery {
           // print("⚠ CoreBluetooth not ready yet")
        } else {
           // print("ℹ️ CoreBluetooth AD 0x09 discovery disabled (using IPWorksBLE names only)")
        }
        
        // Start IPWorksBLE scan for device discovery and connection
        do {
         //   print("Starting BLE scan for SR900 devices...")
            try bleClient.startScanning(serviceUuids: "")
         //   print("✓ IPWorksBLE scanning started (for device connections)")
        } catch {
          //  print("Error starting scan: \(error.localizedDescription)")
            connectionStatus = "Scan Error"
            isScanning = false
        }
        
       // print("═══════════════════════════════════")
    }
    
    /// Stop scanning for devices
    func stopScan() {
        guard isScanning else { return }
        
       // print("═══════════════════════════════════")
       // print("Stopping BLE scan...")
        
        // Stop both scanners (CoreBluetooth only if enabled)
        if enableAD0x09Discovery && isCoreBTInitialized {
            centralManager.stopScan()
          //  print("✓ CoreBluetooth scan stopped")
        }
        
        do {
            try bleClient.stopScanning()
            isScanning = false
         //   print("✓ IPWorksBLE scan stopped")
            
            if sr900Device != nil {
                if enableAD0x09Discovery, let device = sr900Device, let completeName = completeNames[device.macAddress] {
                    connectionStatus = "SR900 Found - AD 0x09: \(completeName)"
                    print("✓ Final status: SR900 Found with AD 0x09 name")
                } else {
                    connectionStatus = "SR900 Found"
                    if enableAD0x09Discovery {
                      //  print("ℹ️ Final status: SR900 Found (no AD 0x09)")
                    } else {
                       // print("ℹ️ Final status: SR900 Found (AD 0x09 disabled)")
                    }
                }
            } else {
                connectionStatus = "No SR900 Found"
            }
            
           // print("═══════════════════════════════════")
        } catch {
            //print("Error stopping IPWorksBLE scan: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Functions
    
    private func connectDevice(macAddress: String) {
        connectionStatus = "Connecting..."
       // print("Connecting to SR900: \(macAddress)")
        
        // Show the complete name we extracted via CoreBluetooth
        if let completeName = completeNames[macAddress] {
           // print("📱 Complete Local Name (AD 0x09): '\(completeName)'")
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                self.bleClient.timeout = 15
                try self.bleClient.connect(serverId: macAddress)
                
                DispatchQueue.main.async {
                    self.isConnected = true
                    self.connectionStatus = "Connected"
                  //  print("✓ Connected to SR900 successfully!")
                }
                
                // Discover services
              //  print("Discovering services...")
                try self.bleClient.discover(
                    serviceUuids: "",
                    characteristicUuids: "",
                    discoverDescriptors: true,
                    includedByServiceId: ""
                )
                
              //  print("Found \(self.bleClient.services.count) service(s)")
                
                // STEP 1: Read Device Name from Generic Access Service (0x1800)
                self.readDeviceNameFromGATT(macAddress: macAddress)
                
                // STEP 2: Find and subscribe to characteristics starting with "DF"
                self.discoverAndSubscribeToDFCharacteristics()
                
            } catch {
                DispatchQueue.main.async {
                    self.connectionStatus = "Connection Failed"
                   // print("✗ Connection failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Read the complete device name from Generic Access Service (0x1800)
    private func readDeviceNameFromGATT(macAddress: String) {
      //  print("═══════════════════════════════════")
      //  print("Reading Device Name from GATT...")
        
        var actualDeviceName = ""
        
        for service in bleClient.services {
           // print("  Service: \(service.uuid) - \(service.description_)")
            
            // Generic Access Service UUID (0x1800 or 00001800-0000-1000-8000-00805f9b34fb)
            if service.uuid.lowercased().contains("1800") {
               // print(">>> Found Generic Access Service (0x1800)!")
                
                // Set this service as active
                bleClient.service = service.id
                
                // Look for Device Name characteristic (0x2A00)
                for characteristic in bleClient.characteristics {
                  //  print("    Char: \(characteristic.uuid)")
                    
                    if characteristic.uuid.lowercased().contains("2a00") {
                       // print(">>> Found Device Name characteristic (0x2A00)! Reading...")
                        
                        do {
                            // Read the device name value
                            let nameData = try bleClient.readValue(
                                serviceId: service.id,
                                characteristicId: characteristic.id,
                                descriptorId: ""
                            )
                            
                            // Decode as UTF-8 string
                            if let decodedName = String(data: nameData, encoding: .utf8) {
                                actualDeviceName = decodedName
                                //print("✓✓✓ Complete Device Name from GATT: '\(decodedName)'")
                                
                                // Update device with actual name
                                DispatchQueue.main.async {
                                    if let currentDevice = self.sr900Device, currentDevice.macAddress == macAddress {
                                        let oldName = currentDevice.name
                                        if oldName != actualDeviceName {
                                            self.sr900Device = (name: actualDeviceName, macAddress: macAddress)
                                           // print("✓ UPDATED: '\(oldName)' → '\(actualDeviceName)'")
                                            self.connectionStatus = "Connected - \(actualDeviceName)"
                                        }
                                    }
                                }
                            } else {
                              //  print("✗ Failed to decode name as UTF-8")
                            }
                        } catch {
                           // print("✗ Error reading Device Name: \(error.localizedDescription)")
                        }
                        break
                    }
                }
                break
            }
        }
        
        if actualDeviceName.isEmpty {
          //  print("⚠ Could not find Device Name characteristic (0x2A00)")
        }
        
       // print("═══════════════════════════════════")
    }
    
    /// Discover and subscribe to all characteristics starting with "DF"
    private func discoverAndSubscribeToDFCharacteristics() {
      //  print("═══════════════════════════════════")
      //  print("Searching for characteristics starting with 'DF'...")
        
        var subscribedCount = 0
        
        for service in bleClient.services {
            // Set this service as active to access its characteristics
            bleClient.service = service.id
            
            for characteristic in bleClient.characteristics {
                // Check if this characteristic starts with "DF" (case-insensitive)
                // Check both UUID and ID since they might be formatted differently
                let uuid = characteristic.uuid.uppercased().replacingOccurrences(of: "-", with: "")
                let charId = characteristic.id.uppercased().replacingOccurrences(of: "-", with: "")
                
                if uuid.hasPrefix("DF") || charId.hasPrefix("DF") {
                    print(">>> Found DF characteristic!")
                    print("    UUID: \(characteristic.uuid)")
                    print("    ID: \(characteristic.id)")
                    
                    // Check if this is DF02 for writing
                    if charId.contains("DF00DF020000") || charId.hasPrefix("DF00DF02") || uuid.hasPrefix("DF00DF02") {
                       // print("    ✏️ This is DF02 - will use for writing")
                        writableCharacteristic = (
                            serviceId: service.id,
                            characteristicId: characteristic.id,
                            uuid: characteristic.uuid
                        )
                    }
                    
                    // Subscribe to this characteristic for notifications
                    do {
                        try bleClient.subscribe(
                            serviceId: service.id,
                            characteristicId: characteristic.id
                        )
                      //  print("✓ Successfully subscribed to \(characteristic.uuid)!")
                        subscribedCount += 1
                    } catch let subscribeError {
                      //  print("✗ Failed to subscribe: \(subscribeError.localizedDescription)")
                    }
                }
            }
        }
        
        if subscribedCount == 0 {
          //  print("⚠ No characteristics starting with 'DF' found")
        } else {
           // print("📊 Subscribed to \(subscribedCount) DF characteristic(s)")
            DispatchQueue.main.async {
                self.connectionStatus = "Connected & Subscribed"
            }
        }
        
        if writableCharacteristic != nil {
            // print("✓ Writable DF02 characteristic ready for commands")
            
            // Wait 2 seconds after "Connected & Subscribed"
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                // Clear the status textbox
                self.connectionStatus = ""
            }
        }
        /*
                // Send "Hello World"
               // print("Sending test message...")
                self.sendData("Hello Sam")
                
                // Immediately display "Message sent"
                self.connectionStatus = "Message sent"
                
                // Clear textbox after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.connectionStatus = ""
                }
            }
        } else {
          //  print("⚠ No writable DF02 characteristic found")
        }
        */
      ///  print("═══════════════════════════════════")
    }
    
    func disconnectDevice() {
        connectionStatus = "Disconnecting..."
      //  print("═══════════════════════════════════")
       // print("Disconnecting from SR900...")
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.bleClient.disconnect()
                DispatchQueue.main.async {
                    self.isConnected = false
                    self.writableCharacteristic = nil
                    self.connectionStatus = "Disconnected"
                  //  print("✓ Disconnected from SR900")
                   // print("═══════════════════════════════════")
                    
                    // Clear the sr900Device to force a fresh discovery
                    self.sr900Device = nil
                   // print("ℹ️ Cleared device cache for fresh discovery")
                    
                    // Restart scanning for SR900 after disconnect
                    // Give a longer delay to ensure CoreBluetooth is ready
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                       // print("🔄 Restarting scan after disconnect...")
                        self.startAutoScan()
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.connectionStatus = "Disconnect Error"
                   // print("✗ Disconnect error: \(error.localizedDescription)")
                  //  print("═══════════════════════════════════")
                }
            }
        }
    }
    
    // MARK: - CoreBluetooth Delegate (for Complete Local Name extraction)
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // Only process if AD 0x09 discovery is enabled
        guard enableAD0x09Discovery else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            switch central.state {
            case .poweredOn:
                print("✓ CoreBluetooth ready (for AD 0x08/0x09 extraction)")
            case .poweredOff:
                print("⚠ CoreBluetooth powered off")
            case .unauthorized:
                print("⚠ CoreBluetooth unauthorized")
            case .unsupported:
                print("⚠ CoreBluetooth not supported on this device")
            default:
                break
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        // Only process if AD 0x09 discovery is enabled
        guard enableAD0x09Discovery else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // KEY TECHNIQUE: Extract Complete Local Name (AD Type 0x09)
            // This uses CBAdvertisementDataLocalNameKey to get the full device name
            // from the advertisement packet (AD 0x09)
            //
            // Note: CBAdvertisementDataLocalNameKey can represent either:
            // - AD 0x08 (Shortened Local Name) if name is truncated
            // - AD 0x09 (Complete Local Name) if full name is present
            // CoreBluetooth automatically provides whichever is available
            let completeLocalName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
            
            // Convert UUID to string for matching with IPWorksBLE
            let macAddress = peripheral.identifier.uuidString
            
            // Store the complete name (AD 0x09) for this device
            if let completeName = completeLocalName {
                // Check if this is a new name or update
                let isNewOrUpdated = self.completeNames[macAddress] != completeName
                
                self.completeNames[macAddress] = completeName
                
                // Only log SR900 devices
                if completeName.hasPrefix("SR900") {
                    if isNewOrUpdated {
                        print("📱 [CoreBluetooth] Extracted Local Name (AD 0x08/0x09):")
                        print("   Device: '\(completeName)'")
                        print("   UUID: \(macAddress)")
                        print("   RSSI: \(RSSI) dBm")
                    } else {
                        // Still log duplicate discoveries but less verbose
                       // print("📱 [CoreBluetooth] Re-discovered: '\(completeName)' (RSSI: \(RSSI))")
                    }
                    
                    // Update the sr900Device if this is the one we're tracking
                    if let currentDevice = self.sr900Device,
                       currentDevice.macAddress == macAddress {
                        // Update if name changed or if we didn't have AD 0x09 before
                        if currentDevice.name != completeName {
                          //  print("   🔄 Updating device name from '\(currentDevice.name)' to '\(completeName)'")
                            self.sr900Device = (name: completeName, macAddress: macAddress)
                        }
                        // Always update status to show AD 0x09
                        self.connectionStatus = "SR900 Found - AD 0x09: \(completeName)"
                        if isNewOrUpdated {
                          //  print("   ✓ Status updated with AD 0x09 name")
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - IPWorksBLE Delegate Methods
    
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
        // Only look for devices whose name STARTS WITH "SR900"
        // This will match: SR900, SR900-001, SR900_ModelA, etc.
        guard name.hasPrefix(targetDeviceName) else { return }
        
        DispatchQueue.main.async {
            // Determine the best name to use:
            // 1. Prefer the Complete Local Name from CoreBluetooth (AD 0x09) if enabled
            // 2. Fall back to IPWorksBLE name if CoreBluetooth hasn't found it yet or is disabled
            let displayName = self.completeNames[serverId] ?? name
            
            // Debug: Check if we have the AD 0x09 name (only if feature is enabled)
            if self.enableAD0x09Discovery {
                if self.completeNames[serverId] != nil {
                   // print("   ✓ AD 0x09 name available in cache: '\(self.completeNames[serverId]!)'")
                } else {
                   // print("   ⚠️ AD 0x09 name NOT in cache yet (will wait for CoreBluetooth)")
                }
            }
            
            // Always update when we're scanning and not connected
            // This ensures status updates to "SR900 Found" after reconnect
            let shouldUpdate = self.sr900Device == nil ||
                               self.sr900Device?.name != displayName ||
                               !self.isConnected
            
            if shouldUpdate {
                self.sr900Device = (name: displayName, macAddress: serverId)
                
                let packetType = isScanResponse ? "SCAN_RSP" : "ADV"
                
                // Check if AD 0x09 discovery is enabled
                if !self.enableAD0x09Discovery {
                    // AD 0x09 disabled - use IPWorksBLE name immediately
                    self.connectionStatus = "SR900 Found"
                  //  print("✓ [IPWorksBLE-\(packetType)] Found SR900 device: '\(displayName)' (\(serverId)) [RSSI: \(rssi)]")
                  //  print("   ℹ️ Using IPWorksBLE name (AD 0x09 discovery disabled)")
                    
                    // Stop scanning immediately
                    self.stopScan()
                } else if let completeName = self.completeNames[serverId] {
                    // AD 0x09 enabled and name already available
                    self.connectionStatus = "SR900 Found - AD 0x09: \(completeName)"
                    
                    //print("✓ [IPWorksBLE-\(packetType)] Found SR900 device: '\(displayName)' (\(serverId)) [RSSI: \(rssi)]")
                    //print("   ✓ AD 0x09 name: '\(completeName)' (using this)")
                    
                    // Stop scanning immediately since we have the complete name
                    self.stopScan()
                } else {
                    // AD 0x09 enabled but not yet available - wait for CoreBluetooth
                    self.connectionStatus = "SR900 Found (waiting for AD 0x09...)"
                    
                    print("✓ [IPWorksBLE-\(packetType)] Found SR900 device: '\(displayName)' (\(serverId)) [RSSI: \(rssi)]")
                    print("   ⏳ Waiting for CoreBluetooth to extract AD 0x09 name...")
                    print("   ℹ️ CoreBluetooth may need a few seconds to discover the device")
                    
                    // Give CoreBluetooth 4 seconds to discover and extract the name
                    // Increased from 2 to 4 seconds for better reliability
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                        // Update status with whatever name we have now
                        if let completeName = self.completeNames[serverId] {
                            self.connectionStatus = "SR900 Found - AD 0x09: \(completeName)"
                          //  print("   ✓ CoreBluetooth extracted: '\(completeName)'")
                        } else {
                            self.connectionStatus = "SR900 Found"
                          //  print("   ⚠️ CoreBluetooth did not extract AD 0x09 name within 4 seconds")
                           // print("   ℹ️ Using IPWorksBLE name: '\(displayName)'")
                        }
                        
                        // Now stop scanning
                        self.stopScan()
                    }
                }
            }
        }
    }
    
    func onConnected(statusCode: Int32, description: String) {
       // print("Connected: \(description)")
    }
    
    func onDisconnected(statusCode: Int32, description: String) {
      //  print("Disconnected: \(description)")
        DispatchQueue.main.async {
            self.isConnected = false
            self.connectionStatus = "Disconnected"
        }
    }
    
    func onDiscovered(gattType: Int32, serviceId: String, characteristicId: String, descriptorId: String, uuid: String, description: String) {
        // gattType: 1=Service, 2=Characteristic, 3=Descriptor
        switch gattType {
        case 1:
            print("Service discovered: \(description.isEmpty ? uuid : description)")
        case 2:
            print("Characteristic discovered: \(description.isEmpty ? uuid : description)")
        case 3:
            print("Descriptor discovered: \(description.isEmpty ? uuid : description)")
        default:
            break
        }
    }
    
    func onError(errorCode: Int32, description: String) {
       // print("Error: \(description) (code: \(errorCode))")
        DispatchQueue.main.async {
            self.connectionStatus = "Error: \(description)"
        }
    }
    
    func onLog(logLevel: Int32, message: String, logType: String) {
        // Optional: log messages for debugging
        if logLevel >= 2 {
          //  print("Log [\(logType)]: \(message)")
        }
    }
    
    func onPairingRequest(serverId: String, pairingKind: Int32, pin: inout String, accept: inout Bool) {
        //print("Pairing request from: \(serverId)")
        accept = true // Auto-accept pairing for SR900
    }
    
    func onServerUpdate(name: String, changedServices: String) {
        //print("Server updated: \(name)")
    }
    
    func onStartScan(serviceUuids: String) {
       // print("Scan started successfully")
    }
    
    func onStopScan(errorCode: Int32, errorDescription: String) {
        if errorCode != 0 {
           // print("Scan stopped with error: \(errorDescription)")
        } else {
          //  print("Scan stopped")
        }
    }
    
    func onSubscribed(serviceId: String, characteristicId: String, uuid: String, description: String) {
       // print("Subscribed to: \(description.isEmpty ? uuid : description)")
    }
    
    func onUnsubscribed(serviceId: String, characteristicId: String, uuid: String, description: String) {
       // print("Unsubscribed from: \(description.isEmpty ? uuid : description)")
    }
    /*
    func onValue(serviceId: String, characteristicId: String, descriptorId: String, uuid: String, description: String, value: Data) {
        let characteristicName = description.isEmpty ? uuid : description
        
        // Convert data to hex string for display
        let hexString = value.map { String(format: "%02X", $0) }.joined(separator: " ")
        
        // Build display message
        var displayMessage = "📥 Value from \(characteristicName):\n"
        displayMessage += "   Bytes: \(value.count)\n"
        displayMessage += "   Hex: \(hexString)"
        
        // Try to decode as UTF-8 string
        if let stringValue = String(data: value, encoding: .utf8), !stringValue.isEmpty {
            displayMessage += "\n   UTF-8: \(stringValue)"
            
        }
        self.connectionStatus = "Received: \(String(data: value, encoding: .utf8) ?? hexString)"
       // print(displayMessage)
        
        // TODO: Parse SR900-specific data formats here
        // (temperature readings, roast profiles, status updates, etc.)
    }
    */
    /*
    func onValue(serviceId: String, characteristicId: String, descriptorId: String, uuid: String, description: String, value: Data) {
        let characteristicName = description.isEmpty ? uuid : description
        let hexString = value.map { String(format: "%02X", $0) }.joined(separator: " ")
        
        var displayMessage = "📥 Value from \(characteristicName):\n"
        displayMessage += "   Bytes: \(value.count)\n"
        displayMessage += "   Hex: \(hexString)"
        
        if let stringValue = String(data: value, encoding: .utf8), !stringValue.isEmpty {
            displayMessage += "\n   UTF-8: \(stringValue)"
        }
        
        print(displayMessage)
        
        let normalizedUUID = uuid.uppercased().replacingOccurrences(of: "-", with: "")
        if normalizedUUID.hasPrefix("DF01") {
            DispatchQueue.main.async {
                self.connectionStatus = "Received: \(String(data: value, encoding: .utf8) ?? hexString)"
            }
        }
    }
    */
    
    func onValue(serviceId: String, characteristicId: String, descriptorId: String, uuid: String, description: String, value: Data) {
        let normalizedUUID = uuid.uppercased().replacingOccurrences(of: "-", with: "")
       // print("onValue received for UUID: \(normalizedUUID)")

        let hexString = value.map { String(format: "%02X", $0) }.joined(separator: " ")
        //print("Received raw bytes: \(hexString)")

        DispatchQueue.main.async {
            if normalizedUUID.contains("DF01") {
                // This matches DF01 anywhere in UUID
                DispatchQueue.main.async {
                    self.connectionStatus = "Received: \(String(data: value, encoding: .utf8) ?? hexString)"
                }
            }
        }
    }

    
    
    func sendBytes(_ bytes: [UInt8]) {
        guard let writable = writableCharacteristic else {
            print("⚠ No writable characteristic found (DF02)")
            connectionStatus = "No writable characteristic"
            return
        }
        
        let data = Data(bytes)
        
        print("📤 Sending bytes to \(writable.uuid): \(data.count) bytes")
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.bleClient.writeValue(
                    serviceId: writable.serviceId,
                    characteristicId: writable.characteristicId,
                    descriptorId: "",
                    value: data
                )
                DispatchQueue.main.async {
                    print("✓ Write initiated to \(writable.uuid)")
                }
            } catch let error {
                DispatchQueue.main.async {
                    print("✗ Failed to write: \(error.localizedDescription)")
                }
            }
        }
    }
    
    

    func onWriteResponse(serviceId: String, characteristicId: String, descriptorId: String, uuid: String, description: String) {
        //print("Write response: \(description.isEmpty ? uuid : description)")
    }
}
