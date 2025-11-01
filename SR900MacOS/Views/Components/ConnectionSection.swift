//
//  ConnectionSection.swift
//  SR900MacOS
//
//  Created by Nisarg Mangukiya on 01/11/25.
//


import SwiftUI

struct ConnectionSection: View {
    @ObservedObject var controlState: MainControlState
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                BLEConnectButton(controlState: controlState)
                    .offset(y: 4)
                
                USBConnectButton(controlState: controlState)
                    .offset(x: -6, y: 4)
                
                ConnectionActivityButton(controlState: controlState)
                    .offset(x: -4, y: 4)
                
                Spacer()
            }
            .padding(.top, 4)
            .padding(.horizontal, 6)
        }
    }
}

// MARK: - BLE Connect Button
struct BLEConnectButton: View {
    @ObservedObject var controlState: MainControlState
    
    var body: some View {
        Button(action: {
            controlState.isConnected.toggle()
            controlState.displayText = controlState.isConnected ? "BLE Connected" : "BLE Disconnected"
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
                
                ConnectionIndicator(isConnected: controlState.isConnected)
            }
            .padding(.leading, 0)
            .frame(width: 147.5, height: 51)
            .background(Color(red: 0.85, green: 0.75, blue: 0.6))
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color.black, lineWidth: 2)
            )
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
    }
}

// MARK: - Connection Activity Button
struct ConnectionActivityButton: View {
    @ObservedObject var controlState: MainControlState
    
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
                
                ActivityIndicator(label: "IN", isActive: controlState.connectionActivityIN)
                ActivityIndicator(label: "OUT", isActive: controlState.connectionActivityOUT)
            }
            .padding(.horizontal, 10)
            .frame(width: 230, height: 51)
            .background(Color(red: 0.85, green: 0.75, blue: 0.6))
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color.black, lineWidth: 2)
            )
        }
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
    
    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.openSansBold(size: 9))
                .foregroundColor(.black)
                .offset(y: -2)
            
            Circle()
                .strokeBorder(Color.gray, lineWidth: 2)
                .background(Circle().fill(isActive ? Color.green : Color.white))
                .frame(width: 14, height: 14)
                .offset(y: -2)
        }
    }
}