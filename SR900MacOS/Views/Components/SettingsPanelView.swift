import SwiftUI

struct SettingsPanelView: View {
    @Binding var rectangle2Extended: Bool
    @Binding var rectangle3Extended: Bool
    @Binding var rectangle4Extended: Bool
    
    @State private var temperatureIsFahrenheit = true
    @State private var thermistorIsExternal = true
    @State private var voltageSupply = "AVERAGE"
    @State private var languageIsEnglish = true
    @State private var saveGraphs = true
    
    var width: CGFloat
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            
            // Left black frame
            Rectangle()
                .fill(Color.black)
                .frame(width: 350, height: 768)
            
            // Inner light panel
            Rectangle()
                .fill(Color(red: 0.93, green: 0.93, blue: 0.93))
                .frame(width: 310, height: 690)
                .overlay(
                    VStack(spacing: 18) {
                        
                        Text("SETTINGS")
                            .font(.openSansBold(size: 22))
                            .padding(.top, 15)
                        
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
                        SettingsButton(title: "Send Settings To Roaster", systemIcon: "arrow.right")
                        
                        // ✅ Language
                        LanguageSelector(languageIsEnglish: $languageIsEnglish)
                        
                        // ✅ Save Graphs
                        HStack {
                            CheckToggle(isOn: $saveGraphs)
                            Text("Save Completed Roast Graphs")
                                .font(.openSansSemiBold(size: 14))
                        }
                        
                        // ✅ Firmware box
                        FirmwareUpdateBox()

                        Spacer()
                    }
                    .padding(.horizontal, 14)
                )
                .offset(x: 22, y: 60)
        }
        .frame(width: width, height: 768)
    }
}
