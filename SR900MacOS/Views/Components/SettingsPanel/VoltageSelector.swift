//
//  VoltageSelector.swift
//  SR900MacOS
//
//  Created by Nisarg Mangukiya on 01/11/25.
//

import SwiftUI


struct VoltageSelector: View {
    @Binding var voltageSupply: String
    
    var body: some View {
        VStack(spacing: 6) {
            Text("Voltage Supply")
                .font(.openSansBold(size: 18))
            
            HStack(spacing: 20) {
                VoltageItem(label: "LOW", value: "<113V", isOn: voltageSupply == "LOW") { voltageSupply = "LOW" }
                VoltageItem(label: "AVERAGE", value: "113-118V", isOn: voltageSupply == "AVERAGE") { voltageSupply = "AVERAGE" }
                VoltageItem(label: "HIGH", value: ">118V", isOn: voltageSupply == "HIGH") { voltageSupply = "HIGH" }
            }
        }
    }
}

struct VoltageItem: View {
    let label: String
    let value: String
    let isOn: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 2) {
            Text(label).font(.openSansSemiBold(size: 12))
            Button(action: action) {
                Image(systemName: isOn ? "checkmark.square.fill" : "square")
            }.buttonStyle(.plain)
            Text(value).font(.openSans(size: 10))
        }
    }
}
