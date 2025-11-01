//
//  LanguageSelector.swift
//  SR900MacOS
//
//  Created by Nisarg Mangukiya on 01/11/25.
//

import SwiftUI


struct LanguageSelector: View {
    @Binding var languageIsEnglish: Bool
    
    var body: some View {
        VStack {
            Text("Language")
                .font(.openSansBold(size: 18))
            
            HStack(spacing: 40) {
                LanguageOption(label: "English", selected: languageIsEnglish) { languageIsEnglish = true }
                LanguageOption(label: "Español", selected: !languageIsEnglish) { languageIsEnglish = false }
            }
        }
    }
}
struct LanguageOption: View {
    let label: String
    let selected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: selected ? "checkmark.square.fill" : "square")
                Text(label)
            }
            .font(.openSans(size: 14))
        }
        .buttonStyle(.plain)
    }
}
struct CheckToggle: View {
    @Binding var isOn: Bool
    
    var body: some View {
        Button(action: { isOn.toggle() }) {
            Image(systemName: isOn ? "checkmark.square.fill" : "square")
        }.buttonStyle(.plain)
    }
}
struct FirmwareUpdateBox: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Firmware Update")
                .font(.openSansBold(size: 18))
            
            HStack {
                SettingsButton(title: "Load")
                SettingsButton(title: "Update")
            }
            
            Rectangle()
                .stroke(Color.black, lineWidth: 1)
                .frame(height: 35)
        }
    }
}
struct SettingsButton: View {
    var title: String
    var systemIcon: String? = nil
    
    var body: some View {
        Button(action: {}) {
            HStack {
                Text(title)
                    .font(.openSansSemiBold(size: 14))
                if let icon = systemIcon {
                    Spacer()
                    Image(systemName: icon)
                }
            }
            .foregroundColor(.black)
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .background(Color.white)
            .border(Color.black, width: 1)
        }
        .buttonStyle(.plain)
    }
}
