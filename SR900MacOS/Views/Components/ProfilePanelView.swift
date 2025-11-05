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
    let onGraphButtonPressed: (() -> Void)?
    let onProfilesButtonPressed: (() -> Void)?
    let onSettingsButtonPressed: (() -> Void)?
    
    
    @State private var autoStopRoast = false
    @State private var selectedRoast: Int? = nil
    @State private var altitudeBelow = true
    @State private var onRoaster = true
    @State private var profileName = "Factory_Default_Roast_Profile"
    
    var width: CGFloat

    
    let roastData = [
        (time: "Minute 1", motor: "9", heater: "2"),
        (time: "Minute 2", motor: "9", heater: "2"),
        (time: "Minute 3", motor: "9", heater: "3"),
        (time: "Minute 4", motor: "8", heater: "4"),
        (time: "Minute 5", motor: "6", heater: "6"),
        (time: "Minute 6", motor: "7", heater: "7"),
        (time: "Minute 7", motor: "6", heater: "8"),
        (time: "Minute 8", motor: "6", heater: "8"),
        (time: "Minute 9", motor: "5", heater: "8"),
        (time: "Minute 10", motor: "5", heater: "8"),
        (time: "Minute 11", motor: "5", heater: "7"),
        (time: "Minute 12", motor: "4", heater: "7"),
        (time: "Minute 13", motor: "4", heater: "-"),
        (time: "Minute 14", motor: "4", heater: "-"),
        (time: "Minute 15", motor: "4", heater: "-")
    ]
    let roastTypes = [
        "Light Roast (410F)",
        "City Roast (420F)",
        "Medium Roast (430F)",
        "Full City Roast (440F)",
        "Vienna Roast (450F)",
        "French Roast (470F)"
    ]
    
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
                                    .offset(x: 15)
                                    .background(Color.white.opacity(0.5))
                                    .border(Color.black, width: 1)
                                    
                                    // Table Rows
                                    ForEach(0..<15) { index in
                                        HStack(spacing: 0) {
                                            Text(roastData[index].time)
                                                .frame(width: 70, alignment: .leading)
                                                .font(.system(size: 11, weight: .semibold))
                                                .padding(.leading, 5)
                                            
                                            Text(roastData[index].motor)
                                                .frame(width: 45, height: 20)
                                                .font(.system(size: 11, weight: .bold))
                                                .background(Color.white)
                                                .border(Color.black, width: 1)
                                            
                                            Text(roastData[index].heater)
                                                .frame(width: 50, height: 20)
                                                .font(.system(size: 11, weight: .bold))
                                                .background(Color.white)
                                                .border(Color.black, width: 1)
                                        }
                                        .offset(x: 10)
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
                                    HStack {
                                        Toggle("", isOn: $autoStopRoast)
                                            .labelsHidden()
                                            .toggleStyle(CheckboxToggleStyle())
                                        Text("Auto Stop Roast")
                                            .font(.system(size: 13, weight: .bold))
                                    }
                                    .offset(x: 10)
                                    // Roast Types
                                    ForEach(0..<6) { index in
                                        HStack {
                                            RoundedRectangle(cornerRadius: 3)
                                                .stroke(Color.black, lineWidth: 2)
                                                .frame(width: 18, height: 18)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 2)
                                                        .fill(selectedRoast == index ? Color.blue : Color.clear)
                                                        .frame(width: 12, height: 12)
                                                )
                                            
                                            Text(roastTypes[index])
                                                .font(.system(size: 11))
                                                .foregroundColor(.gray)
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            selectedRoast = index
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
                                        Toggle("", isOn: $altitudeBelow)
                                            .labelsHidden()
                                            .toggleStyle(CheckboxToggleStyle())
                                        Text("BELOW 3000' ASL")
                                            .font(.system(size: 11, weight: .bold))
                                           // .offset(x: 10)
                                        
                                    }
                                   
                                    .offset(x: 10)
                                    HStack {
                                        Toggle("", isOn: Binding(
                                            get: { !altitudeBelow },
                                            set: { altitudeBelow = !$0 }
                                        ))
                                        .labelsHidden()
                                        .toggleStyle(CheckboxToggleStyle())
                                        Text("ABOVE 3000' ASL")
                                            .font(.system(size: 11, weight: .bold))
                                          // .offset(y: 10)
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
                                    Button("Send Profile") {}
                                        .buttonStyle(ProfileButtonStyle(height: 45))
                                    
                                    Button("Import Summary") {}
                                        .buttonStyle(ProfileButtonStyle(height: 45))
                                }
//                                .offset(y: -7)
                                // Medium Buttons
                                HStack(spacing: 10) {
                                    Button("Load") {}
                                        .buttonStyle(ProfileButtonStyle(height: 38))
                                    Button("Save") {}
                                        .buttonStyle(ProfileButtonStyle(height: 38))
                                    Button("Delete") {}
                                        .buttonStyle(ProfileButtonStyle(height: 38))
                                    Button("Clear") {}
                                        .buttonStyle(ProfileButtonStyle(height: 38))
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
                                    
                                    VStack {
                                        Toggle("", isOn: $onRoaster)
                                            .labelsHidden()
                                            .toggleStyle(CheckboxToggleStyle())
                                        Text("On Roaster")
                                            .font(.system(size: 9, weight: .bold))
                                            .multilineTextAlignment(.center)
                                    }
                                    .offset(y: 3)
                                    .frame(width: 70, height: 40)
                                    .background(Color.white)
                                    .border(Color.black, width: 2)
                                }
                            }
                            .padding(.horizontal, 30)
                            .padding(.bottom, 25)
                        }
//                        .padding(.horizontal, 100)
                        .padding(.top, 180)
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
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            RoundedRectangle(cornerRadius: 3)
                .stroke(Color.black, lineWidth: 2)
                .frame(width: 18, height: 18)
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .fill(configuration.isOn ? Color.blue : Color.clear)
                        .frame(width: 12, height: 12)
                )
                .onTapGesture {
                    configuration.isOn.toggle()
                }
            configuration.label
        }
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
