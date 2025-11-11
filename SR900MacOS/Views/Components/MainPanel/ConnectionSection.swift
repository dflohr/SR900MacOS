//
//  ConnectionSection.swift
//  SR900MacOS
//
//  Created by Nisarg Mangukiya on 01/11/25.
//


import SwiftUI

struct ConnectionSection: View {
    @ObservedObject var controlState: ControlState
    @EnvironmentObject var bleManager: BLEManager

    var body: some View {
        HStack(spacing: 6) {
            BLEConnectButton(controlState: controlState,bleManager: bleManager)
            Spacer()
            USBConnectButton(controlState: controlState)
            Spacer()
            ConnectionActivityButton(controlState: controlState)
//            Spacer()
        }
        .frame(height: 55) // ✅ unified height
        .padding(.top, 15)
        .padding(.horizontal, 15)
    }
}

struct BLEConnectButton: View {
    @ObservedObject var controlState: ControlState
    @ObservedObject var bleManager: BLEManager
    
    var body: some View {
        Button(action: {
            handleButtonAction()
        }) {
            HStack {
                Image("BLE_BTN")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26, height: 26)
                    .padding(.leading, 10)

                Text("BLE Connect")
                    .font(.openSansBold(size: 14))
                    .foregroundColor(.black)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .offset(x: -4)

                Spacer()

                ConnectionIndicator(isConnected: bleManager.isConnected)
            }
            .padding(.leading, 0)
            .frame(width: 147.5, height: 51)
            .background(Color(red: 0.85, green: 0.75, blue: 0.6))
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color.black, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            controlState.displayText = bleManager.connectionStatus
            controlState.isConnected = bleManager.isConnected
        }
        .onChange(of: bleManager.connectionStatus) { oldStatus, newStatus in
            controlState.displayText = newStatus
        }
        .onChange(of: bleManager.isConnected) { oldValue, isConnected in
            controlState.isConnected = isConnected
        }
    }
    
    public func handleButtonAction() {
        if bleManager.isConnected {
            // Disconnect
            bleManager.disconnectDevice()
        } else if bleManager.isScanning {
            // Stop scanning
            bleManager.stopScan()
        } else if bleManager.sr900Device != nil {
            // Connect to found device
            bleManager.toggleConnection()
        } else {
            // No device found - start scanning
            bleManager.startAutoScan()
        }
    }
}

// MARK: - USB Connect Button
struct USBConnectButton: View {
    @ObservedObject var controlState: ControlState
    
    var body: some View {
        Button(action: {
            controlState.displayText = "USB Not Implemented In SR900"
        }) {
            HStack {
                Image(systemName: "cable.connector")
                    .font(.openSans(size: 20))
                    .foregroundColor(.gray)
                    .padding(.leading, 10)
                
                Text("USB")
                    .font(.openSansBold(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .offset(x: 15)
                
                Spacer()
                
                ConnectionIndicator(isConnected: false, isEnabled: false)
            }
            .padding(.leading, 0)
            .frame(width: 100.5, height: 51)
            .background(Color(red: 0.85, green: 0.75, blue: 0.6))
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color.black, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())// ✅ removes default rounded button style
    }
}

// MARK: - Connection Activity Button
struct ConnectionActivityButton: View {
    @ObservedObject var controlState: ControlState
    @EnvironmentObject var bleManager: BLEManager
    
    var body: some View {
        Button(action: {
            controlState.displayText = "Connection Activity"
        }) {
            HStack(spacing: 8) {
                Text("Connection Activity")
                    .font(.openSansBold(size: 14))
                    .foregroundColor(.black)
                    .offset(x: 10)
                
                Spacer()
                
                ActivityIndicator(label: "IN", isActive: bleManager.activityIN, activeColor: .red)
                ActivityIndicator(label: "OUT", isActive: bleManager.activityOUT, activeColor: .blue)
            }
            .padding(.horizontal, 10)
            .frame(width: 230, height: 51)
            .background(Color(red: 0.85, green: 0.75, blue: 0.6))
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color.black, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())// ✅ removes default rounded button style
    }
}

// MARK: - Reusable Components
struct ConnectionIndicator: View {
    let isConnected: Bool
    var isEnabled: Bool = true
    
    var body: some View {
        Circle()
            .strokeBorder(Color.gray, lineWidth: 2)
            .background(Circle().fill(isConnected && isEnabled ? Color.green : Color.white))
            .frame(width: 12, height: 12)
            .padding(.top, -20)
            .padding(.horizontal, -22)
    }
}

struct ActivityIndicator: View {
    let label: String
    let isActive: Bool
    var activeColor: Color = .green  // Default to green for backwards compatibility
    
    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.openSansBold(size: 9))
                .foregroundColor(.black)
                .offset(y: -2)
            
            Circle()
                .strokeBorder(Color.gray, lineWidth: 2)
                .background(Circle().fill(isActive ? activeColor : Color.white))
                .frame(width: 14, height: 14)
                .offset(y: -2)
        }
    }
}


/*

//
//  ConnectionSection.swift
//  SR900MacOS
//
//  Created by Nisarg Mangukiya on 01/11/25.
//


import SwiftUI

struct ConnectionSection: View {
    @ObservedObject var controlState: MainControlState
    @EnvironmentObject var bleManager: BLEManager

    var body: some View {
        HStack(spacing: 6) {
            BLEConnectButton(controlState: controlState,bleManager: bleManager)
            Spacer()
            USBConnectButton(controlState: controlState)
            Spacer()
            ConnectionActivityButton(controlState: controlState)
//            Spacer()
        }
        .frame(height: 55) // ✅ unified height
        .padding(.top, 15)
        .padding(.horizontal, 15)
    }
}


// MARK: - BLE Connect Button
//struct BLEConnectButton: View {
//    @ObservedObject var controlState: MainControlState
//    @ObservedObject var bleManager: BLEManager
//
//    var body: some View {
//        Button(action: {
//            // Toggle BLE connection using BLEManager
//            bleManager.toggleConnection()
//        }) {
//            HStack {
//                Image("BLE_BTN")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 26, height: 26)
//                    .padding(.leading, 10)
//
//                Text("BLE Connect")
//                    .font(.openSansBold(size: 14))
//                    .foregroundColor(.black)
//                    .lineLimit(nil)
//                    .multilineTextAlignment(.center)
//                    .lineSpacing(6)
//                    .offset(x: -4)
//
//                Spacer()
//
//                ConnectionIndicator(isConnected: bleManager.isConnected)
//            }
//            .padding(.leading, 0)
//            .frame(width: 147.5, height: 51)
//            .background(Color(red: 0.85, green: 0.75, blue: 0.6))
//            .overlay(
//                RoundedRectangle(cornerRadius: 0)
//                    .stroke(Color.black, lineWidth: 2)
//            )
//        }
//        .buttonStyle(PlainButtonStyle())// ✅ removes default rounded button style
//        .onAppear {
//            // Set initial status when view appears
//            controlState.displayText = bleManager.connectionStatus
//            controlState.isConnected = bleManager.isConnected
//        }
//        .onChange(of: bleManager.connectionStatus) { oldStatus, newStatus in
//            // Update display text whenever BLE connection status changes
//            controlState.displayText = newStatus
//        }
//        .onChange(of: bleManager.isConnected) { oldValue, isConnected in
//            // Sync control state with BLE manager
//            controlState.isConnected = isConnected
//        }
//    }
//}

struct BLEConnectButton: View {
    @ObservedObject var controlState: MainControlState
    @ObservedObject var bleManager: BLEManager
    
    var body: some View {
        Button(action: {
            handleButtonAction()
        }) {
            HStack {
                Image("BLE_BTN")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26, height: 26)
                    .padding(.leading, 10)

                Text("BLE Connect")
                    .font(.openSansBold(size: 14))
                    .foregroundColor(.black)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .offset(x: -4)

                Spacer()

                ConnectionIndicator(isConnected: bleManager.isConnected)
            }
            .padding(.leading, 0)
            .frame(width: 147.5, height: 51)
            .background(Color(red: 0.85, green: 0.75, blue: 0.6))
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color.black, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            controlState.displayText = bleManager.connectionStatus
            controlState.isConnected = bleManager.isConnected
        }
        .onChange(of: bleManager.connectionStatus) { oldStatus, newStatus in
            controlState.displayText = newStatus
        }
        .onChange(of: bleManager.isConnected) { oldValue, isConnected in
            controlState.isConnected = isConnected
        }
    }
    
//    private var buttonText: String {
//        if bleManager.isConnected {
//            return "Disconnect"
//        } else if bleManager.isScanning {
//            return "Scanning..."
//        } else if bleManager.sr900Device != nil {
//            return "Connect"
//        } else {
//            return "Scan for SR900"
//        }
//    }
    
    public func handleButtonAction() {
        if bleManager.isConnected {
            // Disconnect
            bleManager.disconnectDevice()
        } else if bleManager.isScanning {
            // Stop scanning
            bleManager.stopScan()
        } else if bleManager.sr900Device != nil {
            // Connect to found device
            bleManager.toggleConnection()
        } else {
            // No device found - start scanning
            bleManager.startAutoScan()
        }
    }
}




// MARK: - USB Connect Button
struct USBConnectButton: View {
    @ObservedObject var controlState: MainControlState
    
    var body: some View {
        Button(action: {
            controlState.displayText = "USB Not Implemented In SR900"
        }) {
            HStack {
                Image(systemName: "cable.connector")
                    .font(.openSans(size: 20))
                    .foregroundColor(.gray)
                    .padding(.leading, 10)
                
                Text("USB")
                    .font(.openSansBold(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .offset(x: 15)
                
                Spacer()
                
                ConnectionIndicator(isConnected: false, isEnabled: false)
            }
            .padding(.leading, 0)
            .frame(width: 100.5, height: 51)
            .background(Color(red: 0.85, green: 0.75, blue: 0.6))
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color.black, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())// ✅ removes default rounded button style
    }
}

// MARK: - Connection Activity Button
struct ConnectionActivityButton: View {
    @ObservedObject var controlState: MainControlState
    @EnvironmentObject var bleManager: BLEManager
    
    var body: some View {
        Button(action: {
            controlState.displayText = "Connection Activity"
        }) {
            HStack(spacing: 8) {
                Text("Connection Activity")
                    .font(.openSansBold(size: 14))
                    .foregroundColor(.black)
                    .offset(x: 10)
                
                Spacer()
                
                ActivityIndicator(label: "IN", isActive: bleManager.activityIN, activeColor: .red)
                ActivityIndicator(label: "OUT", isActive: bleManager.activityOUT, activeColor: .blue)
            }
            .padding(.horizontal, 10)
            .frame(width: 230, height: 51)
            .background(Color(red: 0.85, green: 0.75, blue: 0.6))
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color.black, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())// ✅ removes default rounded button style
    }
}

// MARK: - Reusable Components
struct ConnectionIndicator: View {
    let isConnected: Bool
    var isEnabled: Bool = true
    
    var body: some View {
        Circle()
            .strokeBorder(Color.gray, lineWidth: 2)
            .background(Circle().fill(isConnected && isEnabled ? Color.green : Color.white))
            .frame(width: 12, height: 12)
            .padding(.top, -20)
            .padding(.horizontal, -22)
    }
}

struct ActivityIndicator: View {
    let label: String
    let isActive: Bool
    var activeColor: Color = .green  // Default to green for backwards compatibility
    
    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.openSansBold(size: 9))
                .foregroundColor(.black)
                .offset(y: -2)
            
            Circle()
                .strokeBorder(Color.gray, lineWidth: 2)
                .background(Circle().fill(isActive ? activeColor : Color.white))
                .frame(width: 14, height: 14)
                .offset(y: -2)
        }
    }
}
*/
