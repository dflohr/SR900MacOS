//
//  TimeInputSection.swift
//  SR900MacOS
//
//  Created by Nisarg Mangukiya on 01/11/25.
//

import SwiftUI
import Combine

struct TimeInputSection: View {
    @ObservedObject var controlState: ControlState
    @EnvironmentObject var bleManager: BLEManager
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.black)
                .frame(height: 140)
            
            HStack(spacing: 20) {
                TimeInputControls(controlState: controlState)
                    .padding(.leading, 20)
                
                RoastActionButtons(controlState: controlState)
                    .environmentObject(bleManager)
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
    @State private var timerStartTime: Date?
    @State private var displayTimer: Timer?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Time:")
                .font(.openSansBold(size: 16))
                .foregroundColor(.white)
                .offset(x: -8, y: -7)
            
            HStack(spacing: 0) {
                TimeDigitButton(value: $controlState.timeMinutes1, maxValue: 10, offset: CGPoint(x: -10, y: 0), isTimerRunning: controlState.roastInProcess)
                TimeDigitButton(value: $controlState.timeMinutes2, maxValue: 10, isTimerRunning: controlState.roastInProcess)
                    .padding(.trailing, 8)
                
                Text(":")
                    .font(.openSansBold(size: 32))
                    .foregroundColor(.white)
                    .padding(.horizontal, 5)
                    .offset(x: -6)
                
                TimeDigitButton(value: $controlState.timeSeconds1, maxValue: 6, offset: CGPoint(x: -12, y: 0), isTimerRunning: controlState.roastInProcess)
                    .padding(.leading, 8)
                TimeDigitButton(value: $controlState.timeSeconds2, maxValue: 10, offset: CGPoint(x: -3, y: 0), isTimerRunning: controlState.roastInProcess)
            }
        }
        .onChange(of: controlState.roastInProcess) { newValue in
            if newValue {
                // Roast started - begin count-up timer from 00:00
                startTimer()
            } else {
                // Roast stopped - stop timer
                stopTimer()
            }
        }
        .onAppear {
            // If roast is already in process when view appears, start timer
            if controlState.roastInProcess {
                startTimer()
            }
        }
        .onDisappear {
            // Clean up timer when view disappears
            displayTimer?.invalidate()
            displayTimer = nil
        }
    }
    
    private func startTimer() {
        // Invalidate any existing timer
        displayTimer?.invalidate()
        
        // Set start time
        timerStartTime = Date()
        
        // Update display immediately to show 00:00
        updateTimeDisplay()
        
        // Create a repeating timer on the main run loop
        displayTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [self] _ in
            updateTimeDisplay()
        }
        
        // Ensure timer fires even during UI interactions
        if let timer = displayTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
        
        print("⏱️ Count-up timer started from 00:00")
    }
    
    private func stopTimer() {
        // Invalidate and clear the timer
        displayTimer?.invalidate()
        displayTimer = nil
        timerStartTime = nil
        
        // Reset to dashes
        controlState.timeMinutes1 = "-"
        controlState.timeMinutes2 = "-"
        controlState.timeSeconds1 = "-"
        controlState.timeSeconds2 = "-"
        
        print("⏹️ Count-up timer stopped and reset")
    }
    
    private func updateTimeDisplay() {
        guard let startTime = timerStartTime else { return }
        
        let elapsedSeconds = Int(Date().timeIntervalSince(startTime))
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        
        controlState.timeMinutes1 = "\(minutes / 10)"
        controlState.timeMinutes2 = "\(minutes % 10)"
        controlState.timeSeconds1 = "\(seconds / 10)"
        controlState.timeSeconds2 = "\(seconds % 10)"
    }
}

// MARK: - Time Digit Button
struct TimeDigitButton: View {
    @Binding var value: String
    let maxValue: Int
    var offset: CGPoint = .zero
    var isTimerRunning: Bool = false
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.white)
                .frame(width: 50, height: 70)
            
            Text(value)
                .font(.openSansBold(size: 32))
                .foregroundColor(.black)
        }
        .offset(x: offset.x, y: offset.y)
        .contentShape(Rectangle())
        .onTapGesture {
            // Only allow interaction when timer is not running
            guard !isTimerRunning else { return }
            
            if let current = Int(value == "-" ? "0" : value) {
                value = "\((current + 1) % maxValue)"
            } else {
                value = "0"
            }
        }
    }
}

// MARK: - Roast Action Buttons
struct RoastActionButtons: View {
    @ObservedObject var controlState: ControlState
    @EnvironmentObject var bleManager: BLEManager
    
    var body: some View {
        VStack(spacing: 10) {
            RoastButton(
                title: {
                    if controlState.roastInProcess && controlState.coolInProcess {
                        return "Cool Down Running"
                    } else if controlState.roastInProcess && !controlState.coolInProcess {
                        return "Saved Profile Running"
                    } else {
                        return "Start Saved Profile"
                    }
                }(),
                textColor: controlState.roastInProcess ? .red : .black,
                action: {
                    if controlState.roastInProcess && controlState.coolInProcess {//both true
                       //nothing
                    } else if controlState.roastInProcess && !controlState.coolInProcess {
                        //nothing
                    } else {
                        bleManager.startSavedProfileRoast()
                    }

                    
                }
            )
            
            RoastButton(
                title: {
                    if controlState.roastInProcess && controlState.coolInProcess {
                        return "End Roast"
                    } else if controlState.roastInProcess && !controlState.coolInProcess {
                        return "Start Cool Down"
                    } else {
                        return "Start Manual Roast"
                    }
                }(),
                textColor: controlState.roastInProcess ? .blue : .black,
                action: {
                    if controlState.roastInProcess && controlState.coolInProcess {//both true
                        bleManager.startEndRoast()
                    } else if controlState.roastInProcess && !controlState.coolInProcess {
                        bleManager.startCoolDown()
                    } else {
                        bleManager.startManualRoast()
                    }

                    
                }
                
                
             /*
                title: controlState.roastInProcess ? "Start Cool Down" : "Start Manual Roast",
                textColor: controlState.roastInProcess ? .blue : .black,
                action: {
                    if controlState.roastInProcess {
                        bleManager.startCoolDown()
                    } else {
                       // bleManager.startSavedProfileRoast()
                    }
                }
            */
            
            
            
            
            /*
            RoastButton(
                title: "Start Manual Roast",
                action: {
                    controlState.displayText = "Starting Manual Roast..."
                    // TODO: Add manual roast command here
                }
                */
            )
        }
    }
}

struct RoastButton: View {
    let title: String
    var textColor: Color = .black  // Default to black
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.openSansBold(size: 14))
                .foregroundColor(textColor)
                .frame(width: 200, height: 40)
                .background(Color(red: 0.85, green: 0.75, blue: 0.6))
                .offset(x: 10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
