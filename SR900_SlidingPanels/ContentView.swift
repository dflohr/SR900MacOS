import SwiftUI

struct FramedRectangle: View {
    let number: String
    let width: CGFloat
    let height: CGFloat = 768
    let imageName: String? // Optional image to display
    let onGraphButtonPressed: (() -> Void)? // Optional callback for GRAPH button
    let onProfilesButtonPressed: (() -> Void)? // Optional callback for PROFILES button
    let onSettingsButtonPressed: (() -> Void)? // Optional callback for SETTINGS button
    
    // MARK: - Configuration
    // Set temperature unit at build time: "F" for Fahrenheit or "C" for Celsius
    private let temperatureUnit: String = " F"
    
    @State private var displayText: String = ""
    @State private var isConnected: Bool = false
    @State private var isUSBConnected: Bool = false
    @State private var connectionActivityIN: Bool = false
    @State private var connectionActivityOUT: Bool = false
    @State private var selectedButtons: Set<String> = []
    @State private var timeMinutes1: String = "-"
    @State private var timeMinutes2: String = "-"
    @State private var timeSeconds1: String = "-"
    @State private var timeSeconds2: String = "-"
    @State private var showGraphPanel: Bool = false
    @State private var showPanelText: Bool = false
    @State private var showSettingsPanel: Bool = false
    @State private var showSettingsPanelText: Bool = false
    @State private var showProfilesPanel: Bool = false
    @State private var showProfilesPanelText: Bool = false
    @State private var heatingCoolingMode: String = "Heating" // "Heating" or "Cooling"
    
    // Bean temperature - separated into value and unit
    @State private var beanTempValue: Int = 996  // Can be changed to any numeric value or "---"
   // @State private var beanTempValue: String = "999"  // Can be changed to any numeric value or "---"
   
    
    @State private var fanMotorLevel: Double = 0
    @State private var heatLevel: Double = 0
    @State private var roastingTime: Double = 0
    @State private var coolingTime: Double = 0
    
    private func updateBeanTemp() {
        beanTempValue -= 1
    }
    // State bindings to track which panels are extended
    @Binding var rectangle2Extended: Bool
    @Binding var rectangle3Extended: Bool
    @Binding var rectangle4Extended: Bool
    
    var body: some View {
        ZStack {
            // Light gray background
            Rectangle()
                .fill(Color(red: 0.93, green: 0.93, blue: 0.93))
                .frame(width: width, height: height)
            
            // Top border (40px)
            Rectangle()
                .fill(Color.black)
                .frame(width: width, height: 80)
                .offset(y: -364) // (768/2 - 40/2)
            
            // Bottom border (20px)
            Rectangle()
                .fill(Color.black)
                .frame(width: width, height: 20)
                .offset(y: 374) // (768/2 - 20/2)
            
            // Left border (20px)
            Rectangle()
                .fill(Color.black)
                .frame(width: 20, height: height)
                .offset(x: -(width/2 - 10)) // (width/2 - 20/2)
            
            // Right border (20px)
            Rectangle()
                .fill(Color.black)
                .frame(width: 20, height: height)
                .offset(x: (width/2 - 10)) // (width/2 - 20/2)
            
            // Display image if provided
            if let imageName = imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: width - 40, height: height - 60) // Account for borders
                    .offset(y: -10) // Center vertically between top and bottom borders
            }
            
            // Number label or custom text
            if number == "2" {
                Text("ROAST GRAPH")
                    .font(.custom("OpenSans-Bold", size: 24))
                    .foregroundColor(.black)
                    .background(Color(red: 0.93, green: 0.93, blue: 0.93).opacity(0.9)) // Semi-transparent background for visibility
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .offset(y: -244) // Position below top frame (at y: -324) and above image
            } else {
                Text(number)
                    .font(.custom("OpenSans-Bold", size: 48))
                    .foregroundColor(.black)
            }
            
            // Horizontal line for rectangle 1 only (40px above bottom frame)
//            if number == "1" {
//                HStack {
//                    Text("Ver. 0.06a")
//                        .font(.custom("OpenSans-Bold", size: 14))
//                        .foregroundColor(.black)
//                        .offset(x: 35)
//                        .offset(y: 350)
//                    Spacer()
//                    
//                    Text("© 2025-2026 Roast-Tech")
//                        .font(.custom("OpenSans-Bold", size: 14))
//                        .foregroundColor(.black)
//                        .offset(x: -140)
//                        .offset(y: 350)
//                    
//                    Spacer()
//                }
//                
//                
//                
//                Rectangle()
//                    .fill(Color.black)
//                    .frame(width: width - 40, height: 1) // 1px tall, spans from left to right frame
//                    .offset(y: 338) // 40px above bottom frame
//            }
            
                
            
            // Buttons for rectangle 1 only
            if number == "1" {
                let buttonLabels = ["GRAPH", "PROFILES", "SETTINGS", "READ-ME"]
                HStack(alignment: .top, spacing: 0){  // Align to top, no spacing
                    // Main Content Area - ALWAYS stays in place
                    ZStack {
                        Color.white.edgesIgnoringSafeArea(.all)
                        
                        ZStack {
                            Color.black
                                .frame(width: 607, height: 768)
                            
                            VStack(spacing: 0) {
                                // Header
                                HStack {
                                    HStack(spacing: 8) {
                                        // Red circle - Close
                                        Button(action: {
                                            NSApplication.shared.keyWindow?.close()
                                        }) {
                                            Circle()
                                                .fill(Color.red)
                                                .frame(width: 15, height: 15)
                                                .overlay(
                                                    Image(systemName: "xmark")
                                                        .font(.openSansBold(size: 10))
                                                        .foregroundColor(.black.opacity(0.6))
                                                )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .help("Close")
                                        
                                        // Yellow circle - Minimize
                                        Button(action: {
                                            NSApplication.shared.keyWindow?.miniaturize(nil)
                                        }) {
                                            Circle()
                                                .fill(Color.yellow)
                                                .frame(width: 15, height: 15)
                                                .overlay(
                                                    Image(systemName: "minus")
                                                        .font(.openSansBold(size: 10))
                                                        .foregroundColor(.black.opacity(0.6))
                                                )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .help("Minimize")
                                        
                                        // Green circle - Full Screen
                                        Button(action: {
                                            NSApplication.shared.keyWindow?.toggleFullScreen(nil)
                                        }) {
                                            Circle()
                                                .fill(Color.green)
                                                .frame(width: 15, height: 15)
                                                .overlay(
                                                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                                                        .font(.openSansBold(size: 10))
                                                        .foregroundColor(.black.opacity(0.6))
                                                )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .help("Full Screen")
                                    }
                                    .offset(x: -16)
                                    .offset(y: -6)
                                    
                                    Spacer()
                                    
                                    Image("RT_Logo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 240, height: 34)
                                        .offset(x: -135)
                                        .offset(y: -6)
                                    Spacer()
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.black)
                                
                                VStack(spacing: 0) {
                                    // BLE Connect Button
                                    HStack {
                                        Button(action: {
                                            isConnected.toggle()
                                            displayText = isConnected ? "BLE Connected" : "BLE Disconnected"
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
                                                
                                                Circle()
                                                    .strokeBorder(Color.gray, lineWidth: 2)
                                                    .background(Circle().fill(isConnected ? Color.green : Color.white))
                                                    .frame(width: 12, height: 12)
                                                    .padding(.top, -20)
                                                    .padding(.horizontal, -22)
                                            }
                                            .padding(.leading, 0)
                                            .frame(width: 147.5, height:51)
                                            .background(Color(red: 0.85, green: 0.75, blue: 0.6))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 0)
                                                    .stroke(Color.black, lineWidth: 2)
                                            )
                                        }
                                       // .offset(x: 2)
                                        .offset(y: 4)
                                        
                                        // USB Connect Button
                                        Button(action: {
                                           // isUSBConnected.toggle()
                                            displayText = "USB Not Implemented In SR900"
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
                                                
                                                Circle()
                                                    .strokeBorder(Color.gray, lineWidth: 2)
                                                    .background(Circle().fill(Color.white))
                                                    .frame(width: 12, height: 12)
                                                    .padding(.top, -20)
                                                    .padding(.horizontal, -22)
                                            }
                                            .padding(.leading, 0)
                                            .frame(width: 100.5, height:51)
                                            .background(Color(red: 0.85, green: 0.75, blue: 0.6))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 0)
                                                    .stroke(Color.black, lineWidth: 2)
                                            )
                                        }
                                        .offset(x: -6)
                                        .offset(y: 4)
                                        
                                        // Connection Activity Button
                                        Button(action: {
                                            displayText = "Connection Activity"
                                        }) {
                                            HStack(spacing: 8) {
                                                Text("Connection Activity")
                                                    .font(.openSansBold(size: 14))
                                                    .foregroundColor(.black)
                                                    .offset(x: 10)
                                                Spacer()
                                                
                                                // IN indicator
                                                VStack(spacing: 2) {
                                                    Text("IN")
                                                        .font(.openSansBold(size: 9))
                                                        .foregroundColor(.black)
                                                        .offset(y: -2)
                                                    Circle()
                                                        .strokeBorder(Color.gray, lineWidth: 2)
                                                        .background(Circle().fill(connectionActivityIN ? Color.green : Color.white))
                                                        .frame(width: 14, height: 14)
                                                        .offset(y: -2)
                                                }
                                                
                                                // OUT indicator
                                                VStack(spacing: 2) {
                                                    Text("OUT")
                                                        .font(.openSansBold(size: 9))
                                                        .foregroundColor(.black)
                                                        .offset(y: -2)
                                                    Circle()
                                                        .strokeBorder(Color.gray, lineWidth: 2)
                                                        .background(Circle().fill(connectionActivityOUT ? Color.green : Color.white))
                                                        .frame(width: 14, height: 14)
                                                        .offset(y: -2)
                                                }
                                            }
                                            .padding(.horizontal, 10)
                                            .frame(width: 230, height: 51)
                                            .background(Color(red: 0.85, green: 0.75, blue: 0.6))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 0)
                                                    .stroke(Color.black, lineWidth: 2)
                                            )
                                        }
                                        .offset(x: -4)
                                        .offset(y: 4)
                                        
                                        Spacer()
                                    }
                                    .padding(.top, 4)
                                    .padding(.horizontal, 6)
                                    
                                    // Time Input Section
                                    ZStack {
                                        Rectangle()
                                            .fill(Color.black)
                                            .frame(height: 140)
                                        
                                        HStack(spacing: 20) {
                                            // Left side - Time input
                                            VStack(alignment: .leading, spacing: 5) {
                                                // Time Label
                                                Text("Time:")
                                                    .font(.openSansBold(size: 16))
                                                    .foregroundColor(.white)
                                                    .offset(y: -7)
                                                    .offset(x: -8)
                                                HStack(spacing: 0) {
                                                    // Minutes - First digit
                                                    Button(action: {
                                                        if let current = Int(timeMinutes1 == "-" ? "0" : timeMinutes1) {
                                                            timeMinutes1 = "\((current + 1) % 10)"
                                                        } else {
                                                            timeMinutes1 = "0"
                                                        }
                                                    }) {
                                                        Text(timeMinutes1)
                                                            .font(.openSansBold(size: 32))
                                                            .foregroundColor(.black)
                                                            .frame(width: 50, height: 70)
                                                            .background(Color.white)
                                                        .offset(x: -10)
                                                    }
                                                    .buttonStyle(PlainButtonStyle())
                                                    
                                                    // Minutes - Second digit
                                                    Button(action: {
                                                        if let current = Int(timeMinutes2 == "-" ? "0" : timeMinutes2) {
                                                            timeMinutes2 = "\((current + 1) % 10)"
                                                        } else {
                                                            timeMinutes2 = "0"
                                                        }
                                                    }) {
                                                        Text(timeMinutes2)
                                                            .font(.openSansBold(size: 32))
                                                            .foregroundColor(.black)
                                                            .frame(width: 50, height: 70)
                                                            .background(Color.white)
                                                    }
                                                    .buttonStyle(PlainButtonStyle())
                                                    .padding(.trailing, 8)
                                                    
                                                    // Colon separator
                                                    Text(":")
                                                        .font(.openSansBold(size: 32))
                                                        .foregroundColor(.white)
                                                        .padding(.horizontal, 5)
                                                        .offset(x: -6)
                                                    
                                                    // Seconds - First digit
                                                    Button(action: {
                                                        if let current = Int(timeSeconds1 == "-" ? "0" : timeSeconds1) {
                                                            timeSeconds1 = "\((current + 1) % 6)"
                                                        } else {
                                                            timeSeconds1 = "0"
                                                        }
                                                    }) {
                                                        Text(timeSeconds1)
                                                            .font(.openSansBold(size: 32))
                                                            .foregroundColor(.black)
                                                            .frame(width: 50, height: 70)
                                                            .background(Color.white)
                                                            .offset(x: -12)
                                                            //.offset(y: -4)
                                                    }
                                                    .buttonStyle(PlainButtonStyle())
                                                    .padding(.leading, 8)
                                                    
                                                    // Seconds - Second digit
                                                    Button(action: {
                                                        if let current = Int(timeSeconds2 == "-" ? "0" : timeSeconds2) {
                                                            timeSeconds2 = "\((current + 1) % 10)"
                                                        } else {
                                                            timeSeconds2 = "0"
                                                        }
                                                    }) {
                                                        Text(timeSeconds2)
                                                            .font(.openSansBold(size: 32))
                                                            .foregroundColor(.black)
                                                            .frame(width: 50, height: 70)
                                                            .background(Color.white)
                                                            .offset(x: -3)
                                                           // .offset(y: -4)
                                                    }
                                                    .buttonStyle(PlainButtonStyle())
                                                }
                                            }
                                            .padding(.leading, 20)
                                            
                                            // Right side - Action buttons
                                            VStack(spacing: 10) {
                                                // Start Saved Profile Button
                                                Button(action: {
                                                    displayText = "Starting Saved Profile..."
                                                }) {
                                                    Text("Start Saved Profile")
                                                        .font(.openSansBold(size: 14))
                                                        .foregroundColor(.black)
                                                        .frame(width: 200, height: 40)
                                                        .background(Color(red: 0.85, green: 0.75, blue: 0.6))
                                                        .offset(x: 10)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                                
                                                // Start Manual Roast Button
                                                Button(action: {
                                                    displayText = "Starting Manual Roast..."
                                                }) {
                                                    Text("Start Manual Roast")
                                                        .font(.openSansBold(size: 14))
                                                        .foregroundColor(.black)
                                                        .frame(width: 200, height: 40)
                                                        .background(Color(red: 0.85, green: 0.75, blue: 0.6))
                                                        .offset(x: 10)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                            .padding(.trailing, 20)
                                        }
                                    }
                                    .padding(.horizontal, 15)
                                    .offset(y: 14)
                                    
                                    // Control Buttons and Sliders Section
                                    VStack(spacing: 15) {
                                        // Top row: Heating, Bean Temp, Cooling buttons
                                        HStack(spacing: 10) {
                                            // Heating button
                                            Button(action: {
                                                heatingCoolingMode = "Heating"
                                            }) {
                                                HStack {
                                                    Image(systemName: heatingCoolingMode == "Heating" ? "circle.fill" : "circle")
                                                        .font(.openSans(size: 14))
                                                        .offset(x: -20)
                                                    Text("Heating")
                                                        .font(.openSansBold(size: 14))
                                                }
                                                .foregroundColor(.black)
                                                .frame(width: 170, height: 40)
                                                .background(Color.white)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 0)
                                                        .stroke(Color.black, lineWidth: 2)
                                                )
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .offset(x: -2)
                                            
                                           
                                            // Bean Temp display
                                            VStack(spacing: 2) {
                                                
                                                Image(systemName: "thermometer")
                                                    .font(.openSans(size: 24))
                                                    .offset(x: -68)
                                                    .offset(y:  29)
                                                Text("\(beanTempValue)\(temperatureUnit)")
                                                    .font(.openSansBold(size: 20))
                                                    .offset(x: -22)
                                                    .offset(y:  -1)
                                                VStack(spacing: 2) {
                                                    Text("Bean")
                                                        .font(.openSansBold(size: 10))
                                                        .offset(x: -3)
                                                        .offset(y:  -2)
                                                    
                                                    Text("Temperature")
                                                        .font(.openSansBold(size: 10))
                                                        .offset(x: -3)
                                                        .offset(y:  -2)
                                                    
                                                }
                                                .offset(x: 46)
                                                .offset(y: -30)
                                                
                                            }
                                            .foregroundColor(.black)
                                            .frame(width: 170, height: 40)
                                            .background(Color.white)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 0)
                                                    .stroke(Color.black, lineWidth: 2)
                                            )
                                            
                                            // Cooling button
                                            Button(action: {
                                                heatingCoolingMode = "Cooling"
                                            }) {
                                                HStack {
                                                    Image(systemName: heatingCoolingMode == "Cooling" ? "circle.fill" : "circle")
                                                        .font(.openSans(size: 14))
                                                        .offset(x: -20)
                                                    Text("Cooling")
                                                        .font(.openSansBold(size: 14))
                                                }
                                                .foregroundColor(.black)
                                                .frame(width: 170, height: 40)
                                                .background(Color.white)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 0)
                                                        .stroke(Color.black, lineWidth: 2)
                                                )
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                           // .offset(x: 3)
                                            
                                        }
                                        .padding(.horizontal, 20)
                                        //.offset(y: 0)
                                        
                                        // Sliders Section - WITH SMOOTH MOUSE DRAGGING
                                        VStack(spacing: 10) {
                                            // Fan Motor Level
                                            DraggableSlider(
                                                value: $fanMotorLevel,
                                                range: 0...9,
                                                step: 1,
                                                label: "Fan Motor Level",
                                                icon: "fan",
                                                trackColor: .blue,
                                                thumbColor: .white,
                                                textColor: .black
          
                                            )
                                            
                                            // Heat Level
                                            DraggableSlider(
                                                value: $heatLevel,
                                                range: 0...9,
                                                step: 1,
                                                label: "Heat Level",
                                                icon: "flame",
                                                trackColor: .red,
                                                thumbColor: .white,
                                                textColor: .black
                                            )
                                            
                                            // Roasting Time
                                            DraggableSlider(
                                                value: $roastingTime,
                                                range: 0...15,
                                                step: 1,
                                                label: "Roasting Time",
                                                icon: "clock",
                                                trackColor: .red,
                                                thumbColor: .white,
                                                textColor: .black
                                              //  iconOffset: 20  // Add this parameter
                                                
                                            )
                                            
                                            // Cooling Time
                                            DraggableSlider(
                                                value: $coolingTime,
                                                range: 0...4,
                                                step: 1,
                                                label: "Cooling Time",
                                                icon: "clock",
                                                trackColor: .blue,
                                                thumbColor: .white,
                                                textColor: .black
                                            )
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                    .padding(.top, 10)
                                    .offset(y: 20)
                                    
                                    Spacer()
                                    
                                    // Text display area
                                    ScrollView {
                                        Text(displayText)
                                            .font(.openSansBold(size: 14))
                                            .foregroundColor(.green)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding()
                                    }
                                    .frame(width:540,height: 60)
                                    .background(Color.black)
                                    .padding(.bottom, 60)
                                    
                                    // Bottom buttons
//                                    HStack {
//                                        HStack(spacing: -1) {
//                                            ForEach(["GRAPH", " PROFILES", " SETTINGS", "READ-ME"], id: \.self) { label in
//                                                Button(action: {
//                                                    // Helper function to close all panels
//                                                    func closeAllPanels() {
//                                                        showGraphPanel = false
//                                                        showPanelText = false
//                                                        showSettingsPanel = false
//                                                        showSettingsPanelText = false
//                                                        showProfilesPanel = false
//                                                        showProfilesPanelText = false
//                                                    }
//                                                    
//                                                    if label == "GRAPH" {
//                                                        if showGraphPanel {
//                                                            // Close Graph panel
//                                                            withAnimation(.easeInOut(duration: 0.3)) {
//                                                                showGraphPanel = false
//                                                            }
//                                                            showPanelText = false
//                                                            displayText = "Graph Panel Retracted"
//                                                            updateBeanTemp()  // Decrement bean temp on panel retract
//           
//                                                        } else {
//                                                            // Close other panels first if open
//                                                            if showSettingsPanel || showProfilesPanel {
//                                                                withAnimation(.easeInOut(duration: 0.3)) {
//                                                                    closeAllPanels()
//                                                                }
//                                                                // Wait for close animation, then open Graph
//                                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                                                                    withAnimation(.easeInOut(duration: 0.3)) {
//                                                                        showGraphPanel = true
//                                                                    }
//                                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                                                                        showPanelText = true
//                                                                    }
//                                                                }
//                                                            } else {
//                                                                // Open Graph panel directly
//                                                                withAnimation(.easeInOut(duration: 0.3)) {
//                                                                    showGraphPanel = true
//                                                                }
//                                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                                                                    showPanelText = true
//                                                                }
//                                                            }
//                                                            displayText = "Graph Panel Extended"
//                                                            updateBeanTemp()  // Decrement bean temp on panel extend
//                                                        }
//                                                    } else if label == " PROFILES" {
//                                                        if showProfilesPanel {
//                                                            // Close Profiles panel
//                                                            withAnimation(.easeInOut(duration: 0.3)) {
//                                                                showProfilesPanel = false
//                                                            }
//                                                            showProfilesPanelText = false
//                                                            displayText = "Profiles Panel Retracted"
//                                                            updateBeanTemp()  // Decrement bean temp on panel retract
//                                                        } else {
//                                                            // Close other panels first if open
//                                                            if showGraphPanel || showSettingsPanel {
//                                                                withAnimation(.easeInOut(duration: 0.3)) {
//                                                                    closeAllPanels()
//                                                                }
//                                                                // Wait for close animation, then open Profiles
//                                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                                                                    withAnimation(.easeInOut(duration: 0.3)) {
//                                                                        showProfilesPanel = true
//                                                                    }
//                                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                                                                        showProfilesPanelText = true
//                                                                    }
//                                                                }
//                                                            } else {
//                                                                // Open Profiles panel directly
//                                                                withAnimation(.easeInOut(duration: 0.3)) {
//                                                                    showProfilesPanel = true
//                                                                }
//                                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                                                                    showProfilesPanelText = true
//                                                                }
//                                                            }
//                                                            displayText = "Profiles Panel Extended"
//                                                            updateBeanTemp()  // Decrement bean temp on panel extend
//                                                           // beanTempValue = String(Int(beanTempValue) - 1)
//                                                        }
//                                                    } else if label == " SETTINGS" {
//                                                        if showSettingsPanel {
//                                                            // Close Settings panel
//                                                            withAnimation(.easeInOut(duration: 0.3)) {
//                                                                showSettingsPanel = false
//                                                            }
//                                                            showSettingsPanelText = false
//                                                            displayText = "Settings Panel Retracted"
//                                                            updateBeanTemp()  // Decrement bean temp on panel retract
//                                                        } else {
//                                                            // Close other panels first if open
//                                                            if showGraphPanel || showProfilesPanel {
//                                                                withAnimation(.easeInOut(duration: 0.3)) {
//                                                                    closeAllPanels()
//                                                                }
//                                                                // Wait for close animation, then open Settings
//                                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                                                                    withAnimation(.easeInOut(duration: 0.3)) {
//                                                                        showSettingsPanel = true
//                                                                    }
//                                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                                                                        showSettingsPanelText = true
//                                                                    }
//                                                                }
//                                                            } else {
//                                                                // Open Settings panel directly
//                                                                withAnimation(.easeInOut(duration: 0.3)) {
//                                                                    showSettingsPanel = true
//                                                                }
//                                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                                                                    showSettingsPanelText = true
//                                                                }
//                                                            }
//                                                            displayText = "Settings Panel Extended"
//                                                            updateBeanTemp()  // Decrement bean temp on panel extend
//                                                        }
//                                                    } else {
//                                                        // READ-ME button
//                                                        displayText = "Read-Me clicked"
//                                                    }
//                                                }) {
//                                                    HStack {
//                                                        Text(label)
//                                                            .font(.openSansBold(size: 14))
//                                                            .foregroundColor(.black)
//                                                        
//                                                        // Show left arrow for GRAPH when panel is open, otherwise right arrow
//                                                        if label == "GRAPH" {
//                                                            Image(systemName: showGraphPanel ? "arrow.left" : "arrow.right")
//                                                                .font(.openSansBold(size: 24))
//                                                                .foregroundColor(.black)
//                                                        } else {
//                                                            Image(systemName: selectedButtons.contains(label) ? "arrow.left" : "arrow.right")
//                                                                .font(.openSansBold(size: 24))
//                                                                .foregroundColor(.black)
//                                                        }
//                                                    }
//                                                    .frame(width: 127, height: 40)
//                                                    .padding(.vertical, 2)
//                                                    .background(Color.white)
//                                                    .overlay(
//                                                        RoundedRectangle(cornerRadius: 0)
//                                                            .stroke(Color.black, lineWidth: 2)
//                                                    )
//                                                }
//                                            }
//                                        }
//                                        
//                                        Spacer()
//                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.bottom, 13)
                                    .offset(x: 4)
                                    .offset(y: -4)
                                    
                                    Rectangle()
                                        .fill(Color.black)
                                        .frame(height: 1)
                                        .padding(.horizontal, -10)
                                        .offset(y: -5)
                                    
                                    // Version footer
                                    HStack {
                                        Text("Ver. 0.06")
                                            .font(.openSansBold(size: 14))
                                            .foregroundColor(.black)
                                            .offset(y: 3)
                                        Spacer()
                                        
                                        Text("© 2025-2026 Roast-Tech")
                                            .font(.openSansBold(size: 14))
                                            .foregroundColor(.black)
                                            .offset(x: -135)
                                            .offset(y: 3)
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 10)
                                }
                                .background(Color(red: 0.93, green: 0.93, blue: 0.93))
                            }
                            .frame(width: 567, height: 736)
                        }
                    }
                    .frame(width: 607)  // Fixed width for main UI
                    
                    // Vertical separator line - 6px wide, positioned at content area
                   
                    /*
                    VStack(spacing: 0) {
                        // Spacer to align with content area (skip header area)
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: 6, height: 50)  // Skip header + top frame
                        */
                        // Actual separator line (6px wide, covers content area height)
                       /*
                        if showGraphPanel {
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: 2, height: 628)  // Content area height
                        }
                        */
                   // }
                    
                    // Panel Container - shows whichever panel is active
//                    ZStack {
//                        Color.white.edgesIgnoringSafeArea(.all)
//
//                        // Graph Panel
//                        if showGraphPanel {
//                            GraphPanelView(showGraphPanel: $showGraphPanel, showPanelText: $showPanelText)
//                        }
//
//                        // Settings Panel
//                        if showSettingsPanel {
//                            SettingsPanelView(showSettingsPanel: $showSettingsPanel, showSettingsPanelText: $showSettingsPanelText)
//                        }
//
//                        // Profiles Panel
//                        if showProfilesPanel {
//                            ProfilesPanelView(showProfilesPanel: $showProfilesPanel, showProfilesPanelText: $showProfilesPanelText)
//                        }
//                    }
//                    .frame(width: (showGraphPanel || showSettingsPanel || showProfilesPanel) ? 620 : 0)
//                    .clipped()
                }
                HStack(spacing: 0) {
                    ForEach(Array(buttonLabels.enumerated()), id: \.offset) { index, label in
                        Button(action: {
                            if label == "GRAPH", let callback = onGraphButtonPressed {
                                callback()
                            } else if label == "PROFILES", let callback = onProfilesButtonPressed {
                                callback()
                            } else if label == "SETTINGS", let callback = onSettingsButtonPressed {
                                callback()
                            } else {
                                print("\(label) button pressed")
                            }
                        }) {
                            HStack(spacing: 6) {
                                Text(label)
                                    .font(.custom("OpenSans-Bold", size: 17))
                                    .foregroundColor(.black)
                                
                                // Show arrow based on panel state
                                if label == "GRAPH" {
                                    Image(systemName: rectangle2Extended ? "arrow.left" : "arrow.right")
                                        .font(.system(size: 14, weight: .heavy))
                                        .foregroundColor(.black)
                                } else if label == "PROFILES" {
                                    Image(systemName: rectangle3Extended ? "arrow.left" : "arrow.right")
                                        .font(.system(size: 14, weight: .heavy))
                                        .foregroundColor(.black)
                                } else if label == "SETTINGS" {
                                    Image(systemName: rectangle4Extended ? "arrow.left" : "arrow.right")
                                        .font(.system(size: 14, weight: .heavy))
                                        .foregroundColor(.black)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.black, lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if index < 3 {
                            Spacer()
                                .frame(width: 20)
                        }
                    }
                }
                .frame(width: width - 80) // 40px from each side
                .offset(y: 294) // 274Position 60px above bottom frame (raised by 40px)
            }
        }
        .frame(width: width, height: height)
    }
}

struct ContentView: View {
    @State private var rectangle2Offset: CGFloat = -570 // Start hidden under rectangle 1
    @State private var rectangle3Offset: CGFloat = -570 // Start hidden under rectangle 1
    @State private var rectangle4Offset: CGFloat = -570 // Start hidden under rectangle 1
    @State private var animationsComplete: Bool = false // Track if animations are done
    @State private var rectangle2Extended: Bool = false // Track toggle state for rectangle 2
    @State private var rectangle3Extended: Bool = false // Track toggle state for rectangle 3
    @State private var rectangle4Extended: Bool = false // Track toggle state for rectangle 4
    
    // Enable or disable animations at program start
    let animationEnabled: Bool = false  // Set to false to disable animations
    
    var body: some View {
        HStack(spacing: 20) {
            FramedRectangle(
                number: "1",
                width: 607,
                imageName: nil,
                onGraphButtonPressed: {
                    guard animationsComplete else { return }
                    
                    // If PROFILES panel is extended, retract it first
                    if rectangle3Extended {
                        withAnimation(.linear(duration: 0.5)) {
                            rectangle3Offset = -570
                        }
                        // Wait for retraction to complete, then update state and extend GRAPH panel
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            rectangle3Extended = false
                            withAnimation(.linear(duration: 0.5)) {
                                rectangle2Offset = -40
                            }
                            // Update GRAPH state after its animation completes
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                rectangle2Extended = true
                            }
                        }
                    } else if rectangle4Extended {
                        // If SETTINGS panel is extended, retract it first
                        withAnimation(.linear(duration: 0.5)) {
                            rectangle4Offset = -570
                        }
                        // Wait for retraction to complete, then update state and extend GRAPH panel
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            rectangle4Extended = false
                            withAnimation(.linear(duration: 0.5)) {
                                rectangle2Offset = -40
                            }
                            // Update GRAPH state after its animation completes
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                rectangle2Extended = true
                            }
                        }
                    } else {
                        // Toggle rectangle 2 normally - animate first, then update state
                        let targetOffset: CGFloat = rectangle2Extended ? -570 : -40
                        withAnimation(.linear(duration: 0.5)) {
                            rectangle2Offset = targetOffset
                        }
                        // Update state after animation completes
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            rectangle2Extended.toggle()
                        }
                    }
                },
                onProfilesButtonPressed: {
                    guard animationsComplete else { return }
                    
                    // If GRAPH panel is extended, retract it first
                    if rectangle2Extended {
                        withAnimation(.linear(duration: 0.5)) {
                            rectangle2Offset = -570
                        }
                        // Wait for retraction to complete, then update state and extend PROFILES panel
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            rectangle2Extended = false
                            withAnimation(.linear(duration: 0.5)) {
                                rectangle3Offset = -90
                            }
                            // Update PROFILES state after its animation completes
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                rectangle3Extended = true
                            }
                        }
                    } else if rectangle4Extended {
                        // If SETTINGS panel is extended, retract it first
                        withAnimation(.linear(duration: 0.5)) {
                            rectangle4Offset = -570
                        }
                        // Wait for retraction to complete, then update state and extend PROFILES panel
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            rectangle4Extended = false
                            withAnimation(.linear(duration: 0.5)) {
                                rectangle3Offset = -90
                            }
                            // Update PROFILES state after its animation completes
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                rectangle3Extended = true
                            }
                        }
                    } else {
                        // Toggle rectangle 3 normally - animate first, then update state
                        let targetOffset: CGFloat = rectangle3Extended ? -570 : -90
                        withAnimation(.linear(duration: 0.5)) {
                            rectangle3Offset = targetOffset
                        }
                        // Update state after animation completes
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            rectangle3Extended.toggle()
                        }
                    }
                },
                onSettingsButtonPressed: {
                    guard animationsComplete else { return }
                    
                    // If GRAPH panel is extended, retract it first
                    if rectangle2Extended {
                        withAnimation(.linear(duration: 0.5)) {
                            rectangle2Offset = -570
                        }
                        // Wait for retraction to complete, then update state and extend SETTINGS panel
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            rectangle2Extended = false
                            withAnimation(.linear(duration: 0.5)) {
                                rectangle4Offset = -140
                            }
                            // Update SETTINGS state after its animation completes
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                rectangle4Extended = true
                            }
                        }
                    } else if rectangle3Extended {
                        // If PROFILES panel is extended, retract it first
                        withAnimation(.linear(duration: 0.5)) {
                            rectangle3Offset = -570
                        }
                        // Wait for retraction to complete, then update state and extend SETTINGS panel
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            rectangle3Extended = false
                            withAnimation(.linear(duration: 0.5)) {
                                rectangle4Offset = -140
                            }
                            // Update SETTINGS state after its animation completes
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                rectangle4Extended = true
                            }
                        }
                    } else {
                        // Toggle rectangle 4 normally - animate first, then update state
                        let targetOffset: CGFloat = rectangle4Extended ? -570 : -140
                        withAnimation(.linear(duration: 0.5)) {
                            rectangle4Offset = targetOffset
                        }
                        // Update state after animation completes
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            rectangle4Extended.toggle()
                        }
                    }
                },
                rectangle2Extended: $rectangle2Extended,
                rectangle3Extended: $rectangle3Extended,
                rectangle4Extended: $rectangle4Extended
            )
                .zIndex(2) // Rectangle 1 on top
            ZStack {
                FramedRectangle(number: "4", width: 410, imageName: nil, onGraphButtonPressed: nil, onProfilesButtonPressed: nil, onSettingsButtonPressed: nil, rectangle2Extended: $rectangle2Extended, rectangle3Extended: $rectangle3Extended, rectangle4Extended: $rectangle4Extended) // Same size as rectangle 3
                    .zIndex(0) // Rectangle 4 behind rectangle 3
                    .offset(x: rectangle4Offset + 610) // 570Offset relative
                FramedRectangle(number: "3", width: 410, imageName: nil, onGraphButtonPressed: nil, onProfilesButtonPressed: nil, onSettingsButtonPressed: nil, rectangle2Extended: $rectangle2Extended, rectangle3Extended: $rectangle3Extended, rectangle4Extended: $rectangle4Extended) // 100px smaller than rectangle 2
                    .zIndex(1) // Rectangle 3 behind rectangle 1
                    .offset(x: rectangle3Offset + 570) // Offset relative to base position
                FramedRectangle(number: "2", width: 510, imageName: "GraphNew D5-M4", onGraphButtonPressed: nil, onProfilesButtonPressed: nil, onSettingsButtonPressed: nil, rectangle2Extended: $rectangle2Extended, rectangle3Extended: $rectangle3Extended, rectangle4Extended: $rectangle4Extended) // Rectangle 2 with image
                    .zIndex(-1) // Rectangle 2 underneath all
                    .offset(x: rectangle2Offset + 570) // Offset relative to base position
            }
            .offset(x: -570) // Base position under rectangle 1
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(white: 0.95))
        .onAppear {
            if !animationEnabled {
                animationsComplete = true // Enable button immediately if animations disabled
                return
            }
            
            // Wait 1 second before starting animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // Slide rectangle 2 right to reveal it in 0.5 second
                withAnimation(.linear(duration: 0.5)) {
                    rectangle2Offset = -40 // Slide right to 40px left position
                }
            }
            
            // Wait 1 second initial + 0.5 second animation + 1 second pause, then slide back
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.linear(duration: 0.5)) {
                    rectangle2Offset = -570 // Slide back under rectangle 1
                }
            }
            
            // After rectangle 2 finishes (3s) + wait 1 second (4s), animate rectangle 3
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                // Slide rectangle 3 right to reveal it in 0.5 second
                withAnimation(.linear(duration: 0.5)) {
                    rectangle3Offset = -90 // Slide right to 90px left position
                }
            }
            
            // Wait and slide rectangle 3 back
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
                withAnimation(.linear(duration: 0.5)) {
                    rectangle3Offset = -570 // Slide back under rectangle 1
                }
            }
            
            // Mark animations as complete after all animations finish
            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                animationsComplete = true
            }
        }
    }
}

#Preview {
    ContentView()
}
