//
//  ProfilePanelView.swift
//  SR900MacOS
//
//  Created by Nisarg Mangukiya on 05/11/25.
//


//
//  ContentView.swift
//  Profiles
//
//  Created on 11/2/25.
//

import SwiftUI

struct ProfilePanelView: View {
    @Binding var rectangle2Extended: Bool
    @Binding var rectangle3Extended: Bool
    @Binding var rectangle4Extended: Bool
    @Binding var voltageSupply: String
    let onGraphButtonPressed: (() -> Void)?
    let onProfilesButtonPressed: (() -> Void)?
    let onSettingsButtonPressed: (() -> Void)?
    
    @EnvironmentObject var bleManager: BLEManager
    
    @State private var autoStopRoast = false {
        didSet {
            // Clear selected roast when autoStopRoast is turned off
            if !autoStopRoast {
                selectedRoast = nil
            }
        }
    }
    @State private var selectedRoast: Int? = nil
    @State private var altitudeBelow = true {
        didSet {
            updateRoastData()
        }
    }
    @State private var onRoaster = true
    @State private var profileName = "Factory_Default_Roast_Profile"
    
    var width: CGFloat

    // MARK: - Editable Roast Data
    // Mutable struct to hold roast data that users can edit
    struct RoastDataEntry: Identifiable {
        let id = UUID()
        let time: String
        var motor: String
        var heater: String
    }
    
    // Changed from tuple array to struct array so motor/heater values can be modified
    @State private var roastData = [
        RoastDataEntry(time: "Minute 1", motor: "9", heater: "2"),
        RoastDataEntry(time: "Minute 2", motor: "9", heater: "2"),
        RoastDataEntry(time: "Minute 3", motor: "9", heater: "3"),
        RoastDataEntry(time: "Minute 4", motor: "8", heater: "4"),
        RoastDataEntry(time: "Minute 5", motor: "6", heater: "6"),
        RoastDataEntry(time: "Minute 6", motor: "7", heater: "7"),
        RoastDataEntry(time: "Minute 7", motor: "6", heater: "8"),
        RoastDataEntry(time: "Minute 8", motor: "6", heater: "8"),
        RoastDataEntry(time: "Minute 9", motor: "5", heater: "8"),
        RoastDataEntry(time: "Minute 10", motor: "5", heater: "8"),
        RoastDataEntry(time: "Minute 11", motor: "5", heater: "7"),
        RoastDataEntry(time: "Minute 12", motor: "4", heater: "7"),
        RoastDataEntry(time: "Minute 13", motor: "4", heater: "-"),
        RoastDataEntry(time: "Minute 14", motor: "4", heater: "-"),
        RoastDataEntry(time: "Minute 15", motor: "4", heater: "-"),
        RoastDataEntry(time: "Minute 16", motor: "-", heater: "-"),
        RoastDataEntry(time: "Minute 17", motor: "-", heater: "-"),
        RoastDataEntry(time: "Minute 18", motor: "-", heater: "-")
    ]
    let roastTypes = [
        "Light Roast (410F)",
        "City Roast (420F)",
        "Medium Roast (430F)",
        "Full City Roast (440F)",
        "Vienna Roast (450F)",
        "French Roast (470F)"
    ]
    
    // Fan profile array containing motor values from roastData
    var FanProfile: [String] {
        return roastData.map { $0.motor }
    }
    
    // Heater profile array containing heater values from roastData
    var HeaterProfile: [String] {
        return roastData.map { $0.heater }
    }
    
    var body: some View {
//        ZStack {
            // White canvas background
//            Color.white
            
//            VStack {
//                Spacer()
                
                // Main rectangle with black frame
//                ZStack {
                    // Black frame
//                    Color.black
//                        .frame(width: 440, height: 768)
                    
                    // Interior with custom color and frame insets
//                    ZStack {
//                        Color(red: 0.93, green: 0.93, blue: 0.93)
                        
                        VStack(spacing: 0) {
                            // Title
//                            Text("ROAST PROFILES")
//                                .font(.system(size: 32, weight: .bold))
//                                .padding(.top, 15)
//                                .padding(.bottom, 20)
                            
                            HStack(alignment: .top, spacing: 10) {
                                // Left Section - Levels and Timing
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Levels and Timing")
                                        .font(.system(size: 18, weight: .bold))
                                        //.padding(.leading,15)
                                        .padding(.bottom, 5)
                                        .offset(x: 10)
                                    // Table Header
                                    HStack(spacing: 0) {
                                        Text("Time")
                                            .frame(width: 70, alignment: .leading)
                                            .font(.system(size: 12, weight: .bold))
                                            .padding(.leading, 5)
                                        Text("Motor")
                                            .frame(width: 45, alignment: .center)
                                            .font(.system(size: 12, weight: .bold))
                                        Text("Heater")
                                            .frame(width: 50, alignment: .center)
                                            .font(.system(size: 12, weight: .bold))
                                    }
                                    .padding(.vertical, 5)
//                                    .offset(x: 15)
                                    .background(Color.white.opacity(0.5))
                                    .border(Color.black, width: 1)
                                    
                                    // Table Rows
                                    ForEach(0..<18) { index in
                                        HStack(spacing: 0) {
                                            Text(roastData[index].time)
                                                .frame(width: 70, alignment: .leading)
                                                .font(.system(size: 11, weight: .semibold))
                                                .padding(.leading, 5)
                                            
                                            // Editable Motor field
                                            TextField("", text: $roastData[index].motor)
                                                .frame(width: 45, height: 20)
                                                .font(.system(size: 11, weight: .bold))
                                                .multilineTextAlignment(.center)
                                                .background(Color.white)
                                                .border(Color.black, width: 1)
                                                .focusable(false)
                                            
                                            // Editable Heater field
                                            TextField("", text: $roastData[index].heater)
                                                .frame(width: 50, height: 20)
                                                .font(.system(size: 11, weight: .bold))
                                                .multilineTextAlignment(.center)
                                                .background(Color.white)
                                                .border(Color.black, width: 1)
                                                .focusable(false)
                                        }
//                                        .offset(x: 10)
                                        .background(Color.white.opacity(0.3))
                                        .border(Color.black, width: 1)
                                    }
                                }
                                .offset(x: 10)
                                .frame(width: 165)
                                
                                // Right Section - Desired Roast
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Desired Roast")
                                        .font(.system(size: 18, weight: .bold))
                                        .padding(.bottom, 5)
                                        .offset(x: 15)
                                    
                                    // Auto Stop Roast
                                    Button(action: {
                                        autoStopRoast.toggle()
                                    }) {
                                        HStack {
                                            RoundedRectangle(cornerRadius: 3)
                                                .stroke(Color.black, lineWidth: 2)
                                                .frame(width: 14, height: 14)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 2)
                                                        .fill(autoStopRoast ? Color.blue : Color.clear)
                                                        .frame(width: 10, height: 10)
                                                )
                                            Text("Auto Stop Roast")
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundColor(.black)
                                        }
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)
                                    .focusable(false)
                                    .offset(x: 10)
                                    // Roast Types
                                    ForEach(0..<6) { index in
                                        HStack {
                                            RoundedRectangle(cornerRadius: 3)
                                                .stroke(Color.black, lineWidth: 2)
                                                .frame(width: 14, height: 14)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 2)
                                                        .fill(selectedRoast == index ? Color.blue : Color.clear)
                                                        .frame(width: 10, height: 10)
                                                )
                                            
                                            Text(roastTypes[index])
                                                .font(.system(size: 11))
                                                .foregroundColor(.gray)
                                        }
                                        .contentShape(Rectangle())
                                        .focusable(false)
                                        .onTapGesture {
                                            // Only allow selecting a roast type if autoStopRoast is enabled
                                            if autoStopRoast {
                                                selectedRoast = index
                                            }
                                        }
                                        .padding(.vertical, 3)
                                        .offset(x: 10)
                                    }
                                    
                                    // Altitude Section
                                    Text("Altitude")
                                        .font(.system(size: 18, weight: .bold))
                                        .padding(.top, 10)
                                        .offset(x: 30)
                                    
                                    HStack {
                                        RoundedRectangle(cornerRadius: 3)
                                            .stroke(Color.black, lineWidth: 2)
                                            .frame(width: 14, height: 14)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 2)
                                                    .fill(altitudeBelow ? Color.blue : Color.clear)
                                                    .frame(width: 10, height: 10)
                                            )
                                        Text("BELOW 3000' ASL")
                                            .font(.system(size: 11, weight: .bold))
                                    }
                                    .contentShape(Rectangle())
                                    .focusable(false)
                                    .onTapGesture {
                                        if !altitudeBelow {
                                            altitudeBelow = true
                                        }
                                    }
                                    .offset(x: 10)
                                    
                                    HStack {
                                        RoundedRectangle(cornerRadius: 3)
                                            .stroke(Color.black, lineWidth: 2)
                                            .frame(width: 14, height: 14)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 2)
                                                    .fill(!altitudeBelow ? Color.blue : Color.clear)
                                                    .frame(width: 10, height: 10)
                                            )
                                        Text("ABOVE 3000' ASL")
                                            .font(.system(size: 11, weight: .bold))
                                    }
                                    .contentShape(Rectangle())
                                    .focusable(false)
                                    .onTapGesture {
                                        if altitudeBelow {
                                            altitudeBelow = false
                                        }
                                    }
                                    .offset(x: 10)
                                    .offset(y: 5)
                                }
                                .frame(width: 195)
                            }
                            .padding(.horizontal, 10)
                            
                            Spacer()
                            
                            // Bottom Buttons Section
                            VStack(spacing: 10) {
                                // Large Buttons
                                HStack(spacing: 10) {
                                    Button("Send Profile") {
                                        handleSendProfile()
                                    }
                                        .buttonStyle(ProfileButtonStyle(height: 45))
                                        .focusable(false)
                                    
                                    Button("Import Summary") {}
                                        .buttonStyle(ProfileButtonStyle(height: 45))
                                        .focusable(false)
                                }
//                                .offset(y: -7)
                                // Medium Buttons
                                HStack(spacing: 10) {
                                    Button("Load") {}
                                        .buttonStyle(ProfileButtonStyle(height: 38))
                                        .focusable(false)
                                    Button("Save") {}
                                        .buttonStyle(ProfileButtonStyle(height: 38))
                                        .focusable(false)
                                    Button("Delete") {}
                                        .buttonStyle(ProfileButtonStyle(height: 38))
                                        .focusable(false)
                                    Button("Clear") {}
                                        .buttonStyle(ProfileButtonStyle(height: 38))
                                        .focusable(false)
                                }
                               // .offset(y: 3)
                                // Profile Name and On Roaster
                                HStack(spacing: 10) {
                                    TextField("", text: $profileName)
                                        .textFieldStyle(.plain)
                                        .font(.system(size: 11))
                                        .padding(8)
                                        .background(Color.white)
                                        .border(Color.black, width: 2)
                                        .frame(height: 40)
                                        .focusable(false)
                                    
                                    HStack(spacing: 0) {
                                        Toggle("", isOn: $onRoaster)
                                            .labelsHidden()
                                            .toggleStyle(CheckboxToggleStyle())
                                            .focusable(false)
                                        Text("On Roaster")
                                            .font(.system(size: 9, weight: .bold))
                                            .multilineTextAlignment(.center)
                                    }
//                                    .offset(y: 3)
                                    .padding(.horizontal, 5)
                                    .frame(width: 70, height: 40)
                                    .background(Color.white)
                                    .border(Color.black, width: 2)
                                }
                            }
                            .padding(.horizontal, 30)
                            .padding(.bottom, 40)
                        }
//                        .padding(.horizontal, 100)
                        .padding(.top, 120)
                        .onAppear {
                            // Initialize roast data based on default values
                            print("📱 ProfilePanel: onAppear - initializing roast data")
                            updateRoastData()
                        }
                        .onChange(of: voltageSupply) { newValue in
                            // Update roast data when voltage supply changes from SettingsPanel
                            print("⚡️ ProfilePanel: voltageSupply changed to \(newValue)")
                            updateRoastData()
                        }
                    }
//                    .frame(width: 400, height: 688)
//                    .offset(y: 20)
//                }
//                .frame(width: 440, height: 768)
//                
//                Spacer()
//            }
//        }
//        .frame(width: 560, height: 900)
//    }
    
    // MARK: - Helper Functions
    
    /// Update roast data based on voltage supply and altitude
    private func updateRoastData() {
        print("🔄 ProfilePanel: updateRoastData() called - voltage: \(voltageSupply), altitude: \(altitudeBelow ? "LOW" : "HIGH")")
        
        let motorValues: [String]
        let heaterValues: [String]
        
        if altitudeBelow {
            // Low altitude (below 3000' ASL)
            switch voltageSupply {
            case "LOW":
                motorValues = ["1", "9", "9", "8", "8", "8", "8", "7", "7", "7", "7", "7", "6", "6", "5", "5", "5", "-"]
                heaterValues = ["2", "2", "3", "4", "6", "7", "8", "8", "7", "6", "6", "6", "6", "6", "-", "-", "-", "-"]
            case "AVERAGE":
                motorValues = ["2", "9", "9", "8", "6", "7", "6", "6", "5", "5", "5", "4", "4", "4", "4", "4", "4", "-"]
                heaterValues = ["2", "2", "3", "4", "6", "7", "8", "8", "8", "8", "7", "7", "-", "-", "-", "-", "-", "-"]
            case "HIGH":
                motorValues = ["3", "9", "9", "8", "8", "8", "8", "7", "7", "7", "7", "7", "6", "6", "5", "5", "5", "-"]
                heaterValues = ["2", "2", "3", "4", "6", "7", "8", "8", "7", "6", "6", "6", "6", "6", "-", "-", "-", "-"]
            default:
                motorValues = ["9", "9", "9", "8", "6", "7", "6", "6", "5", "5", "5", "4", "4", "4", "4", "4", "4", "-"]
                heaterValues = ["2", "2", "3", "4", "6", "7", "8", "8", "8", "8", "7", "7", "-", "-", "-", "-", "-", "-"]
            }
        } else {
            // High altitude (above 3000' ASL)
            switch voltageSupply {
            case "LOW":
                motorValues = ["4", "9", "9", "8", "8", "8", "8", "7", "7", "7", "7", "7", "6", "6", "5", "5", "5", "-"]
                heaterValues = ["2", "2", "3", "4", "6", "7", "8", "8", "7", "6", "6", "6", "6", "6", "-", "-", "-", "-"]
            case "AVERAGE":
                motorValues = ["5", "9", "9", "8", "8", "8", "8", "7", "7", "7", "7", "7", "6", "6", "5", "5", "5", "5"]
                heaterValues = ["2", "2", "3", "4", "6", "7", "8", "8", "7", "6", "6", "6", "6", "6", "-", "-", "-", "-"]
            case "HIGH":
                motorValues = ["6", "9", "9", "8", "8", "8", "8", "7", "7", "7", "7", "7", "6", "6", "5", "5", "5", "-"]
                heaterValues = ["2", "2", "3", "4", "6", "7", "8", "8", "7", "6", "6", "6", "6", "6", "-", "-", "-", "-"]
            default:
                motorValues = ["9", "9", "9", "8", "8", "8", "8", "7", "7", "7", "7", "7", "6", "6", "5", "5", "5", "5"]
                heaterValues = ["2", "2", "3", "4", "6", "7", "8", "8", "7", "6", "6", "6", "6", "6", "-", "-", "-", "-"]
            }
        }
        
        // Update roastData array with new values
        for index in 0..<min(18, motorValues.count) {
            roastData[index].motor = motorValues[index]
            roastData[index].heater = heaterValues[index]
        }
    }
    
    /// Handle Send Profile button press
    private func handleSendProfile() {
        // Check if BLE is connected
        guard bleManager.messageProtocol.BLE_Connected == 1 else {
            print("⚠️ ProfilePanel: Cannot send profile - BLE not connected")
            bleManager.connectionStatus = "Not Connected"
            
            // Clear status after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                bleManager.connectionStatus = ""
            }
            return
        }
        
        print("📤 ProfilePanel: Sending profile via 0x1B")
        
        // Convert string arrays to UInt8 arrays
        // "-" represents no value (0), otherwise parse the numeric string
        let fanProfileBytes: [UInt8] = FanProfile.map { value in
            if value == "-" {
                return 0
            } else {
                return UInt8(value) ?? 0
            }
        }
        
        let heaterProfileBytes: [UInt8] = HeaterProfile.map { value in
            if value == "-" {
                return 0
            } else {
                return UInt8(value) ?? 0
            }
        }
        
        // Validate we have exactly 18 values
        guard fanProfileBytes.count == 18 && heaterProfileBytes.count == 18 else {
            print("⚠️ ProfilePanel: Invalid profile data - expected 18 values each")
            bleManager.connectionStatus = "Invalid Profile Data"
            
            // Clear status after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                bleManager.connectionStatus = ""
            }
            return
        }
        
        // Update connection status
        bleManager.connectionStatus = "Sending Profile..."
        
        // Initialize the message handler with the bleManager's message protocol
        let sender = SendProfile_0x1B(messageProtocol: bleManager.messageProtocol)
        sender.sendProfile(fanProfile: fanProfileBytes, heaterProfile: heaterProfileBytes)
        
        // Clear status after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            bleManager.connectionStatus = ""
        }
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            HStack {
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color.black, lineWidth: 2)
                    .frame(width: 14, height: 14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .fill(configuration.isOn ? Color.blue : Color.clear)
                            .frame(width: 10, height: 10)
                    )
                configuration.label
            }
        }
        .buttonStyle(.plain)
        .focusable(false)
    }
}

struct ProfileButtonStyle: ButtonStyle {
    let height: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .bold))
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(Color.white)
            .foregroundColor(.black)
            .border(Color.black, width: 2)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}
