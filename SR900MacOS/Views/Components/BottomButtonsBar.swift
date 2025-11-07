//
//  BottomButtonsBar.swift
//  SR900MacOS
//
//  Created by Nisarg Mangukiya on 01/11/25.
//


import SwiftUI

struct BottomButtonsBar: View {
    let buttonLabels: [String]
    let width: CGFloat
    let onGraphButtonPressed: (() -> Void)?
    let onProfilesButtonPressed: (() -> Void)?
    let onSettingsButtonPressed: (() -> Void)?
    
    @Binding var rectangle2Extended: Bool
    @Binding var rectangle3Extended: Bool
    @Binding var rectangle4Extended: Bool
    
    @EnvironmentObject var bleManager: BLEManager
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(buttonLabels.enumerated()), id: \.offset) { index, label in
                NavigationButton(
                    label: label,
                    index: index,
                    isExtended: getExtensionState(for: label),
                    action: getAction(for: label)
                )
                
                if index < 3 {
                    Spacer()
                        .frame(width: 20)
                }
            }
        }
        .frame(width: width - 80)
        .offset(y: 294)
    }
    
    private func getExtensionState(for label: String) -> Bool {
        switch label {
        case "GRAPH": return rectangle2Extended
        case "PROFILES": return rectangle3Extended
        case "SETTINGS": return rectangle4Extended
        default: return false
        }
    }
    
    private func getAction(for label: String) -> () -> Void {
        switch label {
        case "GRAPH": return onGraphButtonPressed ?? { print("GRAPH button pressed") }
        case "PROFILES": return onProfilesButtonPressed ?? { print("PROFILES button pressed") }
        case "SETTINGS": return onSettingsButtonPressed ?? { print("SETTINGS button pressed") }
        case "READ-ME": return {
               print("READ-ME button pressed - sending Starting Message via DF02")
          // bleManager.sendData("Hello World")
         
            let bytesToSend: [UInt8] = [0x20,0x53,0x45,0x51,0x4F,0x0,0x26,0x2,0xDB,0x6B,0x27,0x0,0x0
                                        
                                       ,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0

                                       ,0x0,0x0,0x60,0x2D,0x30,0x3]
           
           bleManager.sendBytes(bytesToSend)

            
           }
        default: return { print("\(label) button pressed") }
        }
    }
}

// MARK: - Navigation Button
struct NavigationButton: View {
    let label: String
    let index: Int
    let isExtended: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(label)
                    .font(.custom("OpenSans-Bold", size: 17))
                    .foregroundColor(.black)
                
                if shouldShowArrow {
                    Image(systemName: isExtended ? "arrow.left" : "arrow.right")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundColor(.black)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(Color.white)
            .overlay(
                Rectangle()
                    .stroke(Color.black, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var shouldShowArrow: Bool {
        ["GRAPH", "PROFILES", "SETTINGS"].contains(label)
    }
}
