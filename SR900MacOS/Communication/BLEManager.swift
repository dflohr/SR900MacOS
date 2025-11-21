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
import CryptoKit
import AVFoundation

class BLEManager: NSObject, ObservableObject, BLEClientDelegate, CBCentralManagerDelegate {
    
    // MARK: - Configuration
    
    /// Enable/Disable CoreBluetooth AD 0x09 name extraction
    /// Set to false to use IPWorksBLE only (faster but less accurate names)
    /// Set to true to use hybrid CoreBluetooth + IPWorksBLE (slower but accurate AD 0x09 names)
    private let enableAD0x09Discovery: Bool = true
    
    // MARK: - Published Properties
    @Published var controlState = ControlState()
    private var messageHandler: IncomingMessageHandler!  // Message parser
    @Published var isConnected = false
    @Published var isScanning = false
    @Published var sr900Device: (name: String, macAddress: String)? = nil
    @Published var connectionStatus: String = "Not Connected"
    @Published var receivedMAC: String = ""
    @Published var lastReceivedBytes: [UInt8] = Array(repeating: 0, count: 34)
    @Published var activityIN: Bool = false
    @Published var activityOUT: Bool = false
    @Published var keySeed: [UInt8] = [0, 0, 0, 0]  // 4-byte array for key seed (from bytes 7-10 when byte[6]=0x26)
    
    // List of approved MAC addresses loaded from ApprovedMACAddresses.txt
    private(set) var approvedMacAddresses: Set<String> = []
    
    // Array of saved MAC addresses loaded from BLE_Devices directory
    @Published var savedMacAddresses: [[String: String]] = []
    
    private var df01ServiceId: String = ""
    private var df01CharacteristicId: String = ""
    private var df02ServiceId: String = ""
    private var df02CharacteristicId: String = ""
    private let DF02_SERVICE_ID = "DF0000000000"
    private let DF02_CHARACTERISTIC_ID = "DF00DF020000"
    private let DF01_SERVICE_ID = "DF0000000000"
    private let DF01_CHARACTERISTIC_ID = "DF00DF010000"
    // IPWorksBLE for connections
    private var bleClient: BLEClient
    
    // MARK: - Protocol Handler Properties
    var messageProtocol: MessageProtocol!
    //private var messageProtocol: MessageProtocol!
   //StartProfileRoast_0x1 @Published var messageProtocol = MessageProtocol()
    
    private var requestForMac: RequestForMac!
    private var startProfileRoast: StartProfileRoast_0x1A!
    internal var manualRoastHandler: StartManualRoast_0x15!
    internal var heatControl: HeatControl_0x01!
    internal var fanControl: FanControl_0x02!
    private var coolDown: CoolDown_0x18!
    private var stopRoast: StopRoast_0x19!
    internal var updateSettings: UpdateSettings_0x2B!
    
    // CoreBluetooth for proper name extraction
    private var centralManager: CBCentralManager!
    private var isCoreBTInitialized = false
   
    private var showIncomingMessages=false
    
    // Sound player for audio notifications
    private var audioPlayer: AVAudioPlayer?
    
    // Track complete names extracted via CoreBluetooth (AD 0x09)
    private var completeNames: [String: String] = [:]
    
    // Track the writable DF02 characteristic for sending commands
    private var writableCharacteristic: (serviceId: String, characteristicId: String, uuid: String)? = nil
    
    private var targetDeviceName = "SR900"  // Will match any device starting with "SR900"
    
    override init() {
        bleClient = BLEClient()
        centralManager = CBCentralManager(delegate: nil, queue: nil)
        
        super.init()
        
        // Load approved MAC addresses from file
        loadApprovedMacAddresses()
        
        // Load saved MAC addresses from BLE_Devices directory
        loadSavedMacAddresses()
        
        // Initialize message protocol
        messageProtocol = MessageProtocol()
       // messageHandler = IncomingMessageHandler(controlState: controlState)
        messageHandler = IncomingMessageHandler(controlState: controlState, bleManager: self)
        // Pass BLEManager reference to MessageProtocol
        messageProtocol.bleManager = self
        
        // Initialize RequestForMac with the message protocol
        requestForMac = RequestForMac(messageProtocol: messageProtocol)
        
        // Initialize StartProfileRoast with the message protocol
        startProfileRoast = StartProfileRoast_0x1A(messageProtocol: messageProtocol)
        
        // Initialize StartManualRoast with the message protocol
        manualRoastHandler = StartManualRoast_0x15(messageProtocol: messageProtocol)
        
        // Initialize HeatControl with the message protocol
        heatControl = HeatControl_0x01(messageProtocol: messageProtocol)
        
        // Initialize FanControl with the message protocol
        fanControl = FanControl_0x02(messageProtocol: messageProtocol)
        
        // Initialize CoolDown with the message protocol
        coolDown = CoolDown_0x18(messageProtocol: messageProtocol)
        
        // Initialize StopRoast with the message protocol
        stopRoast = StopRoast_0x19(messageProtocol: messageProtocol)
        
        // Initialize UpdateSettings with the message protocol
        updateSettings = UpdateSettings_0x2B(messageProtocol: messageProtocol)
        
        // Set up debounced slider update callback
        setupSliderDebounceCallback()
        
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
        
        // Display welcome message, play sound, and start scanning
        DispatchQueue.main.async {
            self.connectionStatus = "Welcome Roaster!"
            self.playSound("tada")
        }
        
        // Start scanning for SR900 device after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.connectionStatus = ""
            self.startAutoScan()
        }
    }
    
    // MARK: - Sound Playback
    
    /// Play a sound file from the app bundle
    /// - Parameter soundName: Name of the sound file (without extension)
    private func playSound(_ soundName: String) {
        // Try to find the sound file in the bundle
        guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: "aiff") else {
            print("⚠️ Sound file '\(soundName).aiff' not found in bundle")
            return
        }
        
        do {
            // Create and configure the audio player
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            print("🔊 Playing sound: \(soundName).aiff")
        } catch {
            print("⚠️ Error playing sound '\(soundName).aiff': \(error.localizedDescription)")
        }
    }
    
    // MARK: - Slider Debouncing Setup
    
    /// Set up the callback for debounced slider updates
    public func setupSliderDebounceCallback() {
        controlState.onSliderUpdateDebounced = { [weak self] sliderType, newValue in
            guard let self = self else { return }
            
            // Only send updates if roast is in process and connected
            guard self.controlState.roastInProcess, self.isConnected else {
                print("⚠️ Cannot send slider update: roast not in process or not connected")
                return
            }
            
            // CRITICAL: Handle profile roast differently than manual roast
            if self.controlState.isProfileRoast {
                // During profile roast: Allow BOTH fan and heat adjustments via individual commands
                if sliderType == .fanMotor {
                    print("✅ Profile Roast: Allowing fan adjustment via 0x02")
                    
                    // Note: FanControl automatically sets time-based ignore window
                    // when sendFanControl() is called (1.5 second window)
                    self.fanControl.sendFanControl(from: self.controlState)
                    return
                } else if sliderType == .heat {
                    print("✅ Profile Roast: Allowing heat adjustment via 0x01")
                    
                    // Send heat control command
                    self.heatControl.sendHeatControl(from: self.controlState)
                    return
                } else {
                    print("⚠️ Unknown slider type during profile roast")
                    return
                }
            }
            
            
            
            
            // Handle cooling phase
            if self.controlState.coolInProcess {
                // During cooling, only allow fan motor adjustments
                if sliderType == .heat {
                    print("⚠️ Cannot send heat level update during cooling phase")
                    return
                }
                // Allow fan adjustments during cooling
                print("✅ Allowing fan motor adjustment during cooling")
            }
            
            // Send manual roast command with updated values
            let fanSpeed = UInt8(self.controlState.fanMotorLevel)
            let heatSetting = UInt8(self.controlState.heatLevel)
            let roastTime = UInt8(self.controlState.roastingTime)
            let coolTime = UInt8(self.controlState.coolingTime)
            
            // Determine which flag to use based on cooling state
            let allowDuringRoast = !self.controlState.coolInProcess
            let allowDuringCooling = self.controlState.coolInProcess && sliderType == .fanMotor
            
            self.manualRoastHandler.startManualRoast(
                fanSpeed: fanSpeed,
                heatSetting: heatSetting,
                roastTime: roastTime,
                coolTime: coolTime,
                controlState: self.controlState,
                allowDuringRoast: allowDuringRoast,
                allowDuringCooling: allowDuringCooling
            )
            
            let sliderName = sliderType == .fanMotor ? "Fan Motor" : "Heat Level"
            print("📤 Sent debounced update for \(sliderName): \(Int(newValue))")
        }
    }
   
    // MARK: - MAC Address Management
    
    /// Load approved MAC addresses from ApprovedMACAddresses.txt
    private func loadApprovedMacAddresses() {
        // Try to find the file in the app bundle
        guard let fileURL = Bundle.main.url(forResource: "ApprovedMACAddresses", withExtension: "txt") else {
            print("⚠️ ApprovedMACAddresses.txt not found in bundle")
            return
        }
        
        do {
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines)
            
            // Filter out empty lines and trim whitespace
            let macAddresses = lines
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
            
            approvedMacAddresses = Set(macAddresses)
            
            print("✅ Loaded \(approvedMacAddresses.count) approved MAC address(es):")
            for mac in approvedMacAddresses.sorted() {
                print("   - \(mac)")
            }
        } catch {
            print("⚠️ Error reading ApprovedMACAddresses.txt: \(error)")
        }
    }
    
    /// Load saved MAC addresses from BLE_Devices directory on app launch
    private func loadSavedMacAddresses() {
        // Get the Application Support directory
        guard let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            print("⚠️ Could not access Application Support directory")
            return
        }
        
        // Create Roast-Tech/BLE_Devices directory path
        let roastTechDir = appSupportDir.appendingPathComponent("Roast-Tech")
        let bleDevicesDir = roastTechDir.appendingPathComponent("BLE_Devices")
        let filename = "approved_devices.enc"
        let fileURL = bleDevicesDir.appendingPathComponent(filename)
        
        // Check if file exists
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("ℹ️ No saved MAC addresses found in Roast-Tech/BLE_Devices")
            savedMacAddresses = []
            return
        }
        
        // Read and decrypt the file
        do {
            let encryptedData = try Data(contentsOf: fileURL)
            
            // Decrypt the data
            guard let decryptedContent = decryptData(encryptedData) else {
                print("⚠️ Failed to decrypt saved MAC addresses")
                savedMacAddresses = []
                return
            }
            
            // Parse the records
            savedMacAddresses = parseMacRecords(from: decryptedContent)
            
            print("✅ Loaded \(savedMacAddresses.count) saved MAC address(es) from Roast-Tech/BLE_Devices:")
            for record in savedMacAddresses {
                if let mac = record["mac"],
                   let firstApproved = record["firstApproved"],
                   let lastConnected = record["lastConnected"] {
                    print("   - \(mac)")
                    print("     First: \(firstApproved) | Last: \(lastConnected)")
                }
            }
        } catch {
            print("⚠️ Error reading saved MAC addresses: \(error)")
            savedMacAddresses = []
        }
    }
    
    /// Save MAC address to Roast-Tech/BLE_Devices directory with encryption
    /// Supports multiple MAC addresses in a single consolidated file
    func saveMacAddressToFile(_ macAddress: String) {
        // Get the Application Support directory
        guard let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            print("⚠️ Could not access Application Support directory")
            return
        }
        
        // Create Roast-Tech/BLE_Devices directory path
        let roastTechDir = appSupportDir.appendingPathComponent("Roast-Tech")
        let bleDevicesDir = roastTechDir.appendingPathComponent("BLE_Devices")
        
        // Create directories if they don't exist
        do {
            try FileManager.default.createDirectory(at: bleDevicesDir, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("⚠️ Error creating Roast-Tech/BLE_Devices directory: \(error)")
            return
        }
        
        // Use a single consolidated file for all MAC addresses
        let filename = "approved_devices.enc"
        let fileURL = bleDevicesDir.appendingPathComponent(filename)
        
        // Create timestamp
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timestamp = dateFormatter.string(from: Date())
        
        // Structure to hold MAC address records
        var macRecords: [[String: String]] = []
        
        // Check if file already exists
        if FileManager.default.fileExists(atPath: fileURL.path) {
            // File exists - decrypt and parse existing records
            if let existingData = try? Data(contentsOf: fileURL),
               let decryptedContent = decryptData(existingData) {
                // Parse existing records
                macRecords = parseMacRecords(from: decryptedContent)
            }
        }
        
        // Check if this MAC address already exists
        if let existingIndex = macRecords.firstIndex(where: { $0["mac"] == macAddress }) {
            // Update existing record - only update last connected time
            macRecords[existingIndex]["lastConnected"] = timestamp
            print("✅ Updated existing MAC address record: \(macAddress)")
        } else {
            // Add new record
            let newRecord: [String: String] = [
                "mac": macAddress,
                "firstApproved": timestamp,
                "lastConnected": timestamp
            ]
            macRecords.append(newRecord)
            print("✅ Added new MAC address record: \(macAddress)")
        }
        
        // Convert records to string format
        let content = formatMacRecords(macRecords)
        
        // Encrypt the content
        guard let encryptedData = encryptData(content) else {
            print("⚠️ Failed to encrypt MAC address data")
            return
        }
        
        // Write encrypted data to file
        do {
            try encryptedData.write(to: fileURL, options: .atomic)
            print("✅ Saved encrypted MAC address to: \(fileURL.path)")
            print("   Total devices stored: \(macRecords.count)")
            
            // Update the in-memory array on the main thread
            DispatchQueue.main.async { [weak self] in
                self?.savedMacAddresses = macRecords
            }
        } catch {
            print("⚠️ Error writing encrypted MAC address file: \(error)")
        }
    }
    
    /// Get array of just MAC address strings from saved devices
    func getSavedMacAddressStrings() -> [String] {
        return savedMacAddresses.compactMap { $0["mac"] }
    }
    
    /// Check if a MAC address has been previously saved
    func isMacAddressSaved(_ macAddress: String) -> Bool {
        return savedMacAddresses.contains { $0["mac"] == macAddress }
    }
    
    /// Get connection history for a specific MAC address
    func getConnectionHistory(for macAddress: String) -> (firstApproved: String?, lastConnected: String?)? {
        guard let record = savedMacAddresses.first(where: { $0["mac"] == macAddress }) else {
            return nil
        }
        return (firstApproved: record["firstApproved"], lastConnected: record["lastConnected"])
    }
    
    /// Retrieve all saved MAC addresses from encrypted file
    func getAllSavedMacAddresses() -> [[String: String]] {
        // Get the Application Support directory
        guard let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            print("⚠️ Could not access Application Support directory")
            return []
        }
        
        // Create Roast-Tech/BLE_Devices directory path
        let roastTechDir = appSupportDir.appendingPathComponent("Roast-Tech")
        let bleDevicesDir = roastTechDir.appendingPathComponent("BLE_Devices")
        let filename = "approved_devices.enc"
        let fileURL = bleDevicesDir.appendingPathComponent(filename)
        
        // Check if file exists
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("ℹ️ No saved MAC addresses found")
            return []
        }
        
        // Decrypt and parse records
        if let existingData = try? Data(contentsOf: fileURL),
           let decryptedContent = decryptData(existingData) {
            let records = parseMacRecords(from: decryptedContent)
            print("📋 Found \(records.count) saved MAC address(es)")
            return records
        }
        
        return []
    }
    
    /// Print all saved MAC addresses to console (for debugging)
    func printAllSavedMacAddresses() {
        let records = getAllSavedMacAddresses()
        
        if records.isEmpty {
            print("📋 No saved MAC addresses")
            return
        }
        
        print("📋 Saved MAC Addresses (\(records.count) total):")
        print("=" + String(repeating: "=", count: 60))
        
        for (index, record) in records.enumerated() {
            if let mac = record["mac"],
               let firstApproved = record["firstApproved"],
               let lastConnected = record["lastConnected"] {
                print("\n[\(index + 1)] \(mac)")
                print("    First Approved:  \(firstApproved)")
                print("    Last Connected:  \(lastConnected)")
            }
        }
        print("\n" + String(repeating: "=", count: 60))
    }
    
    // MARK: - MAC Address Record Helpers
    
    /// Parse MAC address records from decrypted content
    private func parseMacRecords(from content: String) -> [[String: String]] {
        var records: [[String: String]] = []
        let lines = content.components(separatedBy: .newlines)
        
        var currentRecord: [String: String] = [:]
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine.isEmpty {
                // Empty line indicates end of record
                if !currentRecord.isEmpty {
                    records.append(currentRecord)
                    currentRecord = [:]
                }
            } else if trimmedLine.hasPrefix("MAC Address:") {
                let mac = trimmedLine.replacingOccurrences(of: "MAC Address:", with: "")
                    .trimmingCharacters(in: .whitespaces)
                currentRecord["mac"] = mac
            } else if trimmedLine.hasPrefix("First Approved:") {
                let timestamp = trimmedLine.replacingOccurrences(of: "First Approved:", with: "")
                    .trimmingCharacters(in: .whitespaces)
                currentRecord["firstApproved"] = timestamp
            } else if trimmedLine.hasPrefix("Last Connected:") {
                let timestamp = trimmedLine.replacingOccurrences(of: "Last Connected:", with: "")
                    .trimmingCharacters(in: .whitespaces)
                currentRecord["lastConnected"] = timestamp
            } else if trimmedLine == "---" {
                // Separator line - end of record
                if !currentRecord.isEmpty {
                    records.append(currentRecord)
                    currentRecord = [:]
                }
            }
        }
        
        // Add the last record if it exists
        if !currentRecord.isEmpty {
            records.append(currentRecord)
        }
        
        return records
    }
    
    /// Format MAC address records to string
    private func formatMacRecords(_ records: [[String: String]]) -> String {
        var output = ""
        
        for (index, record) in records.enumerated() {
            if let mac = record["mac"],
               let firstApproved = record["firstApproved"],
               let lastConnected = record["lastConnected"] {
                
                output += "MAC Address: \(mac)\n"
                output += "First Approved: \(firstApproved)\n"
                output += "Last Connected: \(lastConnected)\n"
                
                // Add separator between records (but not after the last one)
                if index < records.count - 1 {
                    output += "---\n"
                }
            }
        }
        
        return output
    }
    
    // MARK: - Encryption Helpers
    
    /// Get or create encryption key stored in Keychain
    private func getEncryptionKey() -> SymmetricKey {
        let keychainService = "com.sr900macos.bledevices"
        let keychainAccount = "encryption-key"
        
        // Try to retrieve existing key from Keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess, let keyData = result as? Data {
            // Key exists in Keychain
            return SymmetricKey(data: keyData)
        } else {
            // Generate new key and store in Keychain
            let newKey = SymmetricKey(size: .bits256)
            let keyData = newKey.withUnsafeBytes { Data($0) }
            
            let addQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: keychainService,
                kSecAttrAccount as String: keychainAccount,
                kSecValueData as String: keyData,
                kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
            ]
            
            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            if addStatus == errSecSuccess {
                print("🔐 Generated and stored new encryption key in Keychain")
            } else {
                print("⚠️ Failed to store encryption key in Keychain: \(addStatus)")
            }
            
            return newKey
        }
    }
    
    /// Encrypt data using AES-GCM
    private func encryptData(_ plaintext: String) -> Data? {
        guard let plaintextData = plaintext.data(using: .utf8) else {
            return nil
        }
        
        let key = getEncryptionKey()
        
        do {
            let sealedBox = try AES.GCM.seal(plaintextData, using: key)
            
            // Combine nonce + ciphertext + tag into a single Data object
            guard let combined = sealedBox.combined else {
                return nil
            }
            
            return combined
        } catch {
            print("⚠️ Encryption error: \(error)")
            return nil
        }
    }
    
    /// Decrypt data using AES-GCM
    private func decryptData(_ encryptedData: Data) -> String? {
        let key = getEncryptionKey()
        
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            
            return String(data: decryptedData, encoding: .utf8)
        } catch {
            print("⚠️ Decryption error: \(error)")
            return nil
        }
    }
    
    // MARK: - Public Functions
    //RECEIVING
    
    func onValue(serviceId: String,
                 characteristicId: String,
                 descriptorId: String,
                 uuid: String,
                 description: String,
                 value: Data) {

        // Always 34 bytes
        let bytes = [UInt8](value)
        lastReceivedBytes = bytes
        
        // Trigger IN activity indicator blink
        blinkActivityIN()

        let hex = bytes.map { String(format: "%02X", $0) }.joined(separator: " ")
        print("📥 RX (\(uuid)) [34 bytes]: \(hex)")

        // --- DELEGATE ALL MESSAGE PARSING TO IncomingMessageHandler ---
        // All message types (including 0x27 MAC address) are now handled by the message parser
        messageHandler.processMessage(bytes)
        
        // Note: Removed the MAC handling code that was here - now in IncomingMessageHandler
        // Note: Removed the temperature parsing code - already in IncomingMessageHandler
        
        // --- Update connection status with hex display ---
        if showIncomingMessages==true{
            let hexDisplay = lastReceivedBytes.map { String(format: "%02X", $0) }.joined(separator: " ")
            
            DispatchQueue.main.async {
                self.connectionStatus = "Received: \(hexDisplay)"
            }
        }
    }

    //SENDING
    func sendCommand(_ bytes: [UInt8]) {  //From MessageProtocol
        let hex = bytes.map { String(format: "%02X", $0) }.joined(separator: " ")
        let data = Data(bytes)
        
        // Check if byte[6] = 0x26 and save bytes 7-10 to keySeed
        if bytes.count >= 11 && bytes[6] == 0x26 {
            DispatchQueue.main.async {
                self.keySeed = Array(bytes[7...10])
                let seedHex = self.keySeed.map { String(format: "%02X", $0) }.joined(separator: " ")
                print("🔑 KeySeed captured (0x26): \(seedHex)")
            }
        }
        
        // Trigger OUT activity indicator blink
        blinkActivityOUT()

        DispatchQueue.global(qos: .background).async {
            do {
                self.bleClient.service = self.DF02_SERVICE_ID
                self.bleClient.characteristic = self.DF02_CHARACTERISTIC_ID

                try self.bleClient.writeValue(
                    serviceId: self.DF02_SERVICE_ID,
                    characteristicId: self.DF02_CHARACTERISTIC_ID,
                    descriptorId: "",
                    value: data
                )

                print("✅ DF02 Write Successful: \(hex)")

            } catch {
                print("❌ DF02 Write Failed:", error)
            }
        }
    }
    
    // MARK: - Roast Commands
    
    /// Start a saved profile roast on the connected device
    func startSavedProfileRoast() {
        guard isConnected else {
            print("⚠️ Cannot start roast - device not connected")
            return
        }
        
        print("🔥 Starting saved profile roast...")
        startProfileRoast.startSavedProfileRoast()
    }
    
    /// Start cooldown process on the connected device
    func startCoolDown() {
        guard isConnected else {
            print("⚠️ Cannot start cooldown - device not connected")
            return
        }
        
        print("❄️ Starting cooldown...")
        coolDown.CoolDown()
    }
    
    /// Start manual roast with current control state settings
    func startManualRoast() {
        guard isConnected else {
            print("⚠️ Cannot start manual roast - device not connected")
            return
        }
        
        print("🔥 Starting manual roast...")
        manualRoastHandler.startManualRoast(from: controlState)
    }
    
    /// Start cooldown process on the connected device
    func startEndRoast() {
        guard isConnected else {
            print("⚠️ Cannot start endroast - device not connected")
            return
        }
        
        print("❄️ Starting end roast...")
        stopRoast.stopRoast()
    }
    
    
    
    
    
    
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
    
    /// Manually send MAC request message
    ///
    ///
    ////


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
                
                // Clear status after 5 seconds, but only if still not scanning and not connected
                // This gives time for CoreBluetooth packets to settle
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
                    guard let self = self else { return }
                    // Only clear if we're still not scanning and not connected
                    if !self.isScanning && !self.isConnected {
                        self.connectionStatus = ""
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
                        print("    ✏️ This is DF02 - will use for writing")
                        writableCharacteristic = (
                            serviceId: service.id,
                            characteristicId: characteristic.id,
                            uuid: characteristic.uuid
                        )
                    }
                    
                    // Try to subscribe to this characteristic for notifications
                    do {
                        try bleClient.subscribe(
                            serviceId: service.id,
                            characteristicId: characteristic.id
                        )
                        print("    ✓ Successfully subscribed to \(characteristic.uuid)")
                        subscribedCount += 1
                    } catch let subscribeError {
                        print("    ⚠️ Could not subscribe (may not support notifications): \(subscribeError.localizedDescription)")
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
            print("✓ Found DF02 characteristic - ready for commands")
            
            // Auto-send MAC request after connection (now with correct header!)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                print("═══════════════════════════════════")
                print("✅ BLE Setup Complete - Sending MAC Request")
                
                // Set BLE_Connected
                self.messageProtocol.BLE_Connected = 1
                
                // Send the MAC request message
                self.requestForMac.RequestMacMessage()
                
                print("📤 MAC request sent with correct header")
                print("⏳ Waiting for MAC address response...")
                print("═══════════════════════════════════")
                
                // Update UI
                DispatchQueue.main.async {
                    self.connectionStatus = "MAC Request Sent"
                }
                
                // Clear status after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.connectionStatus = ""
                }
            }
        } else {
            print("⚠ No DF02 characteristic found")
        }
        
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
                    self.messageProtocol.BLE_Connected = 0
                    self.connectionStatus = "Disconnected"
                    self.receivedMAC = ""
                  //  print("✓ Disconnected from SR900")
                   // print("═══════════════════════════════════")
                    
                    // Reset sliders to 0
                    self.controlState.fanMotorLevel = 0
                    self.controlState.heatLevel = 0
                    
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
                        // Only update status if we're actively scanning
                        // This prevents status flickering from late CoreBluetooth packets
                        if self.isScanning {
                            self.connectionStatus = "SR900 Found - AD 0x09: \(completeName)"
                            if isNewOrUpdated {
                              //  print("   ✓ Status updated with AD 0x09 name")
                            }
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
    

    
    func onDisconnected(statusCode: Int32, description: String) {
        print("═══════════════════════════════════")
        print("⚠️ Device Disconnected: \(description)")
        print("   Status Code: \(statusCode)")
        
        DispatchQueue.main.async {
            // Reset connection state
            self.isConnected = false
            self.connectionStatus = "Disconnected"
            self.writableCharacteristic = nil
            self.messageProtocol.BLE_Connected = 0
            self.receivedMAC = ""
            
            // Reset roast state
            self.controlState.roastInProcess = false
            print("   ✓ Reset roastInProcess to false")
            
            // Reset sliders to 0
            self.controlState.fanMotorLevel = 0
            self.controlState.heatLevel = 0
            print("   ✓ Reset sliders to 0")
            
            // Clear the device to force fresh discovery
            self.sr900Device = nil
            print("   ✓ Cleared device cache")
            
            // Restart scanning after a brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                print("🔄 Restarting scan for SR900 devices...")
                print("═══════════════════════════════════")
                self.startAutoScan()
            }
        }
    }
   
    func onError(errorCode: Int32, description: String) {
       // print("Error: \(description) (code: \(errorCode))")
        DispatchQueue.main.async {
            self.connectionStatus = "Error: \(description)"
        }
    }
    
    // MARK: - Activity Indicator Helpers
    
    /// Trigger a brief blink on the IN activity indicator
    func blinkActivityIN() {
        DispatchQueue.main.async {
            self.activityIN = true
        }
        
        // Auto-reset after 150ms
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.activityIN = false
        }
    }
    
    /// Trigger a brief blink on the OUT activity indicator
    func blinkActivityOUT() {
        DispatchQueue.main.async {
            self.activityOUT = true
        }
        
        // Auto-reset after 150ms
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.activityOUT = false
        }
    }


    func onWriteResponse(serviceId: String, characteristicId: String, descriptorId: String, uuid: String, description: String) {}
    func onDiscovered(gattType: Int32, serviceId: String, characteristicId: String, descriptorId: String, uuid: String, description: String) {}
    func onConnected(statusCode: Int32, description: String) {}
    func onStopScan(errorCode: Int32, errorDescription: String) {}
    func onLog(logLevel: Int32, message: String, logType: String) {}
    func onServerUpdate(name: String, changedServices: String) {}
    func onStartScan(serviceUuids: String) {}
    func onSubscribed(serviceId: String, characteristicId: String, uuid: String, description: String) {}
    func onUnsubscribed(serviceId: String, characteristicId: String, uuid: String, description: String) {}
    func onPairingRequest(serverId: String, pairingKind: Int32, pin: inout String, accept: inout Bool) {}
        //print("Pairing request from: \(serverId)")
      //  accept = true // Auto-accept pairing for SR900
    
    
}

