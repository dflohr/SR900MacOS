//
//  SettingsPanelView.swift
//  SR900MacOS
//
//  Created by Nisarg Mangukiya on 01/11/25.
//


import SwiftUI
internal import UniformTypeIdentifiers

struct SettingsPanelView: View {
    @Binding var rectangle2Extended: Bool
    @Binding var rectangle3Extended: Bool
    @Binding var rectangle4Extended: Bool
    @Binding var voltageSupply: String
    let onGraphButtonPressed: (() -> Void)?
    let onProfilesButtonPressed: (() -> Void)?
    let onSettingsButtonPressed: (() -> Void)?
    
    // Access to BLEManager to send settings
    @EnvironmentObject var bleManager: BLEManager
    
    @State private var temperatureIsFahrenheit = true
    @State private var thermistorIsExternal = true
    @State private var languageIsEnglish = true
    @State private var saveGraphs = true
    @State private var isImporterPresented = false
    @State private var selectedGraphBackgroundFile: String = "Select Graph Background"
    
    var width: CGFloat
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            
            // Left black frame
            //            Rectangle()
            //                .fill(Color.black)
            //                .frame(width: 350, height: 768)
            
            // Inner light panel
            //            Rectangle()
            //                .fill(Color(red: 0.93, green: 0.93, blue: 0.93))
            //                .frame(width: 310, height: 690)
            //                .overlay(
            VStack(spacing:20) {
                
                //                        Text("SETTINGS")
                //                            .font(.openSansBold(size: 22))
                //                            .padding(.top, 15)
                
                // ✅ Temperature Section
                ToggleButtonRow(
                    title: "Temperatures",
                    leftLabel: "F",
                    rightLabel: "C",
                    leftSelected: temperatureIsFahrenheit,
                    actionLeft: { temperatureIsFahrenheit = true },
                    actionRight: { temperatureIsFahrenheit = false }
                )
                
                // ✅ Thermistor
                ToggleButtonRow(
                    title: "Thermistor",
                    leftLabel: "INTERNAL",
                    rightLabel: "EXTERNAL",
                    leftSelected: !thermistorIsExternal,
                    actionLeft: { thermistorIsExternal = false },
                    actionRight: { thermistorIsExternal = true }
                )
                
                // ✅ Voltage Supply
                VoltageSelector(voltageSupply: $voltageSupply)
                
                // ✅ Send settings button
                Button(action: sendSettingsToRoaster) {
                    HStack {
                        Text("Send Settings To Roaster")
                            .font(.openSansBold(size: 16))
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        bleManager.isConnected ? Color.blue : Color.gray
                    )
                    .cornerRadius(8)
                }
                .disabled(!bleManager.isConnected)
                .buttonStyle(.plain)
                .focusable(false)
                
                // ✅ Language
                LanguageSelector(languageIsEnglish: $languageIsEnglish)
                
                //            .offset(y:-14)
                //            .padding(.top, 8)
                // ✅ Save Graphs
                
                // Graph Background
                VStack(spacing: 10) {
                    Text("Graph Background")
                        .font(.openSansBold(size: 18))
                    
                    // Pull-down file selector box
                    Button(action: { isImporterPresented = true }) {
                        HStack {
                            Text(selectedGraphBackgroundFile)
                                .foregroundColor(.black)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        .frame(height: 40)
                        .background(
                            Rectangle()
                                .stroke(Color.black, lineWidth: 1)
                                .background(Color.white)
                        )
                    }
                    .buttonStyle(.plain)
                    .focusable(false)
                    .fileImporter(
                        isPresented: $isImporterPresented,
                        allowedContentTypes: [.image, .item, .pdf],
                        allowsMultipleSelection: false
                    ) { result in
                        do {
                            if let selectedFile = try result.get().first {
                                selectedGraphBackgroundFile = selectedFile.lastPathComponent
                            }
                        } catch {
                            print("File selection failed: \(error.localizedDescription)")
                        }
                    }
                }
//                .offset(y:-14)
//                .padding(.top, 8)
                
                // Save Graphs
//                Button(action: { saveGraphs.toggle() }) {
//                    HStack(spacing: 6) {
//                        Image(systemName: saveGraphs ? "checkmark.square.fill" : "square")
//                            .font(.openSans(size: 18))
//                            .foregroundColor(.blue)
//                        Text("Save Completed Roast Graphs")
//                            .font(.openSans(size: 14))
//                            .foregroundColor(.black)
//                    }
//                }
//                .buttonStyle(PlainButtonStyle())
//                .offset(y:-22)
//                .padding(.top, 8)
                
                HStack {
                    CheckToggle(isOn: $saveGraphs)
                    Text("Save Completed Roast Graphs")
                        .font(.openSansSemiBold(size: 14))
                }
                
                // ✅ Firmware box
                FirmwareUpdateBox()
                
                Spacer()
            }
            //                    .padding(50)
            .padding(.horizontal, 50)
            .padding(.top, 120)
            
            //                )
            //                .offset(x: 22, y: 60)
        }
        //        .frame(width: width, height: 768)
    }
    
    // MARK: - Actions
    
    /// Send current settings to the roaster via BLE
    private func sendSettingsToRoaster() {
        print("📤 Sending settings to roaster...")
        bleManager.updateSettings.sendUpdateSettings(
            temperatureIsFahrenheit: temperatureIsFahrenheit,
            thermistorIsExternal: thermistorIsExternal,
            voltageSupply: voltageSupply
        )
    }
}
