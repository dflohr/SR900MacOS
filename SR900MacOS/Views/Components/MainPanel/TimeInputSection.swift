//
//  TimeInputSection.swift
//  SR900MacOS
//
//  Created by Nisarg Mangukiya on 01/11/25.
//


import SwiftUI

struct TimeInputSection: View {
    @ObservedObject var controlState: ControlState
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.black)
                .frame(height: 140)
            
            HStack(spacing: 20) {
                TimeInputControls(controlState: controlState)
                    .padding(.leading, 20)
                
                RoastActionButtons(controlState: controlState)
                    .padding(.trailing, 20)
            }
        }
        .padding(.horizontal, 15)
        .offset(y: 14)
    }
}

// MARK: - Time Input Controls
struct TimeInputControls: View {
    @ObservedObject var controlState: ControlState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Time:")
                .font(.openSansBold(size: 16))
                .foregroundColor(.white)
                .offset(x: -8, y: -7)
            
            HStack(spacing: 0) {
                TimeDigitButton(value: $controlState.timeMinutes1, maxValue: 10, offset: CGPoint(x: -10, y: 0))
                TimeDigitButton(value: $controlState.timeMinutes2, maxValue: 10)
                    .padding(.trailing, 8)
                
                Text(":")
                    .font(.openSansBold(size: 32))
                    .foregroundColor(.white)
                    .padding(.horizontal, 5)
                    .offset(x: -6)
                
                TimeDigitButton(value: $controlState.timeSeconds1, maxValue: 6, offset: CGPoint(x: -12, y: 0))
                    .padding(.leading, 8)
                TimeDigitButton(value: $controlState.timeSeconds2, maxValue: 10, offset: CGPoint(x: -3, y: 0))
            }
        }
    }
}

// MARK: - Time Digit Button
struct TimeDigitButton: View {
    @Binding var value: String
    let maxValue: Int
    var offset: CGPoint = .zero
    
    var body: some View {
        Button(action: {
            if let current = Int(value == "-" ? "0" : value) {
                value = "\((current + 1) % maxValue)"
            } else {
                value = "0"
            }
        }) {
            Text(value)
                .font(.openSansBold(size: 32))
                .foregroundColor(.black)
                .frame(width: 50, height: 70)
                .background(Color.white)
                .offset(x: offset.x, y: offset.y)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Roast Action Buttons
struct RoastActionButtons: View {
    @ObservedObject var controlState: ControlState
    
    var body: some View {
        VStack(spacing: 10) {
            RoastButton(
                title: "Start Saved Profile",
                action: {
                    controlState.displayText = "Starting Saved Profile..."
                }
            )
            
            RoastButton(
                title: "Start Manual Roast",
                action: {
                    controlState.displayText = "Starting Manual Roast..."
                }
            )
        }
    }
}

struct RoastButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.openSansBold(size: 14))
                .foregroundColor(.black)
                .frame(width: 200, height: 40)
                .background(Color(red: 0.85, green: 0.75, blue: 0.6))
                .offset(x: 10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/*
//
//  TimeInputSection.swift
//  SR900MacOS
//
//  Created by Nisarg Mangukiya on 01/11/25.
//


import SwiftUI

struct TimeInputSection: View {
    @ObservedObject var controlState: MainControlState
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.black)
                .frame(height: 140)
            
            HStack(spacing: 20) {
                TimeInputControls(controlState: controlState)
                    .padding(.leading, 20)
                
                RoastActionButtons(controlState: controlState)
                    .padding(.trailing, 20)
            }
        }
        .padding(.horizontal, 15)
        .offset(y: 14)
    }
}

// MARK: - Time Input Controls
struct TimeInputControls: View {
    @ObservedObject var controlState: MainControlState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Time:")
                .font(.openSansBold(size: 16))
                .foregroundColor(.white)
                .offset(x: -8, y: -7)
            
            HStack(spacing: 0) {
                TimeDigitButton(value: $controlState.timeMinutes1, maxValue: 10, offset: CGPoint(x: -10, y: 0))
                TimeDigitButton(value: $controlState.timeMinutes2, maxValue: 10)
                    .padding(.trailing, 8)
                
                Text(":")
                    .font(.openSansBold(size: 32))
                    .foregroundColor(.white)
                    .padding(.horizontal, 5)
                    .offset(x: -6)
                
                TimeDigitButton(value: $controlState.timeSeconds1, maxValue: 6, offset: CGPoint(x: -12, y: 0))
                    .padding(.leading, 8)
                TimeDigitButton(value: $controlState.timeSeconds2, maxValue: 10, offset: CGPoint(x: -3, y: 0))
            }
        }
    }
}

// MARK: - Time Digit Button
struct TimeDigitButton: View {
    @Binding var value: String
    let maxValue: Int
    var offset: CGPoint = .zero
    
    var body: some View {
        Button(action: {
            if let current = Int(value == "-" ? "0" : value) {
                value = "\((current + 1) % maxValue)"
            } else {
                value = "0"
            }
        }) {
            Text(value)
                .font(.openSansBold(size: 32))
                .foregroundColor(.black)
                .frame(width: 50, height: 70)
                .background(Color.white)
                .offset(x: offset.x, y: offset.y)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Roast Action Buttons
struct RoastActionButtons: View {
    @ObservedObject var controlState: MainControlState
    
    var body: some View {
        VStack(spacing: 10) {
            RoastButton(
                title: "Start Saved Profile",
                action: {
                    controlState.displayText = "Starting Saved Profile..."
                }
            )
            
            RoastButton(
                title: "Start Manual Roast",
                action: {
                    controlState.displayText = "Starting Manual Roast..."
                }
            )
        }
    }
}

struct RoastButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.openSansBold(size: 14))
                .foregroundColor(.black)
                .frame(width: 200, height: 40)
                .background(Color(red: 0.85, green: 0.75, blue: 0.6))
                .offset(x: 10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
*/
