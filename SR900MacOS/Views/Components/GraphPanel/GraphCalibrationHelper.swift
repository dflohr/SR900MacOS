//
//  GraphCalibrationHelper.swift
//  SR900MacOS
//
//  Helper tool for calibrating graph coordinates
//  Use this view temporarily to find the correct calibration values for your graph image
//

import SwiftUI

/// Interactive calibration helper - overlay on your graph image to find coordinates
struct GraphCalibrationHelper: View {
    @State private var showingOverlay = true
    @State private var calibration = GraphCalibration.default
    
    // Test point for visualization
    @State private var testTime: TimeInterval = 450  // 7.5 minutes
    @State private var testTemp: Double = 350  // 350°F
    
    let imageName: String
    let imageWidth: CGFloat
    let imageHeight: CGFloat
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Graph Calibration Helper")
                .font(.title)
                .bold()
            
            Text("Use this tool to find the correct calibration values for your graph image")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Graph preview with overlay
            ZStack {
                // Background graph image
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: imageWidth, height: imageHeight)
                    .border(Color.blue, width: 2)
                
                if showingOverlay {
                    // Overlay calibration grid and test point
                    CalibrationOverlay(
                        calibration: calibration,
                        testTime: testTime,
                        testTemp: testTemp
                    )
                    .frame(width: imageWidth, height: imageHeight)
                }
            }
            
            Toggle("Show Calibration Overlay", isOn: $showingOverlay)
                .padding(.horizontal)
            
            // Calibration controls
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 15) {
                    Group {
                        Text("Graph Origin & Size")
                            .font(.headline)
                        
                        HStack {
                            Text("Origin X:")
                            TextField("X", value: $calibration.graphOriginX, format: FloatingPointFormatStyle<CGFloat>())
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)
                            Text("pixels from left edge")
                                .font(.caption)
                        }
                        
                        HStack {
                            Text("Origin Y:")
                            TextField("Y", value: $calibration.graphOriginY, format: FloatingPointFormatStyle<CGFloat>())
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)
                            Text("pixels from top edge (bottom of graph)")
                                .font(.caption)
                        }
                        
                        HStack {
                            Text("Width:")
                            TextField("Width", value: $calibration.graphWidth, format: FloatingPointFormatStyle<CGFloat>())
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)
                            Text("pixels")
                                .font(.caption)
                        }
                        
                        HStack {
                            Text("Height:")
                            TextField("Height", value: $calibration.graphHeight, format: FloatingPointFormatStyle<CGFloat>())
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)
                            Text("pixels")
                                .font(.caption)
                        }
                    }
                    
                    Divider()
                    
                    Group {
                        Text("Temperature Scale")
                            .font(.headline)
                        
                        HStack {
                            Text("Min Temp:")
                            TextField("Min", value: $calibration.minTemperature, format: FloatingPointFormatStyle<Double>())
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)
                            Text("°F (bottom of graph)")
                                .font(.caption)
                        }
                        
                        HStack {
                            Text("Max Temp:")
                            TextField("Max", value: $calibration.maxTemperature, format: FloatingPointFormatStyle<Double>())
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)
                            Text("°F (top of graph)")
                                .font(.caption)
                        }
                    }
                    
                    Divider()
                    
                    Group {
                        Text("Time Scale")
                            .font(.headline)
                        
                        HStack {
                            Text("Min Time:")
                            TextField("Min", value: $calibration.minTime, format: FloatingPointFormatStyle<Double>())
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)
                            Text("seconds (left edge)")
                                .font(.caption)
                        }
                        
                        HStack {
                            Text("Max Time:")
                            TextField("Max", value: $calibration.maxTime, format: FloatingPointFormatStyle<Double>())
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)
                            Text("seconds (right edge)")
                                .font(.caption)
                        }
                    }
                    
                    Divider()
                    
                    Group {
                        Text("Test Point")
                            .font(.headline)
                        
                        HStack {
                            Text("Time:")
                            Slider(value: $testTime, in: 0...calibration.maxTime, step: 30)
                            Text("\(Int(testTime / 60)):\(String(format: "%02d", Int(testTime) % 60))")
                                .frame(width: 60)
                        }
                        
                        HStack {
                            Text("Temp:")
                            Slider(value: $testTemp, in: calibration.minTemperature...calibration.maxTemperature, step: 10)
                            Text("\(Int(testTemp))°F")
                                .frame(width: 60)
                        }
                    }
                    
                    Divider()
                    
                    // Export calibration code
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Swift Code:")
                            .font(.headline)
                        
                        Text(generateCalibrationCode())
                            .font(.system(.caption, design: .monospaced))
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(4)
                        
                        Button("Copy to Clipboard") {
                            copyToClipboard(generateCalibrationCode())
                        }
                    }
                }
                .padding()
            }
        }
        .padding()
    }
    
    private func generateCalibrationCode() -> String {
        """
        GraphCalibration(
            graphOriginX: \(calibration.graphOriginX),
            graphOriginY: \(calibration.graphOriginY),
            graphWidth: \(calibration.graphWidth),
            graphHeight: \(calibration.graphHeight),
            minTemperature: \(calibration.minTemperature),
            maxTemperature: \(calibration.maxTemperature),
            minTime: \(calibration.minTime),
            maxTime: \(calibration.maxTime)
        )
        """
    }
    
    private func copyToClipboard(_ text: String) {
        #if os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        #endif
    }
}

/// Visual overlay showing calibration grid and test point
struct CalibrationOverlay: View {
    let calibration: GraphCalibration
    let testTime: TimeInterval
    let testTemp: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Draw graph boundary rectangle
                Rectangle()
                    .stroke(Color.green, lineWidth: 3)
                    .frame(width: calibration.graphWidth, height: calibration.graphHeight)
                    .position(
                        x: calibration.graphOriginX + calibration.graphWidth / 2,
                        y: calibration.graphOriginY - calibration.graphHeight / 2
                    )
                
                // Draw origin marker
                Circle()
                    .fill(Color.blue)
                    .frame(width: 12, height: 12)
                    .position(x: calibration.graphOriginX, y: calibration.graphOriginY)
                
                Text("(0,0)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.blue)
                    .background(Color.white.opacity(0.8))
                    .position(x: calibration.graphOriginX + 20, y: calibration.graphOriginY + 15)
                
                // Draw corner markers
                // Top-left
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                    .position(x: calibration.graphOriginX, y: calibration.graphOriginY - calibration.graphHeight)
                
                // Top-right
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                    .position(
                        x: calibration.graphOriginX + calibration.graphWidth,
                        y: calibration.graphOriginY - calibration.graphHeight
                    )
                
                // Bottom-right
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                    .position(
                        x: calibration.graphOriginX + calibration.graphWidth,
                        y: calibration.graphOriginY
                    )
                
                // Draw grid lines (every 100 seconds and 50°F)
                Path { path in
                    // Vertical time lines
                    for time in stride(from: 0, through: calibration.maxTime, by: 100) {
                        let point = calibration.pointToGraphCoordinates(time: time, temperature: calibration.minTemperature)
                        let topPoint = calibration.pointToGraphCoordinates(time: time, temperature: calibration.maxTemperature)
                        path.move(to: point)
                        path.addLine(to: topPoint)
                    }
                    
                    // Horizontal temperature lines
                    for temp in stride(from: calibration.minTemperature, through: calibration.maxTemperature, by: 50) {
                        let point = calibration.pointToGraphCoordinates(time: calibration.minTime, temperature: temp)
                        let rightPoint = calibration.pointToGraphCoordinates(time: calibration.maxTime, temperature: temp)
                        path.move(to: point)
                        path.addLine(to: rightPoint)
                    }
                }
                .stroke(Color.yellow.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                
                // Draw test point
                let testPoint = calibration.pointToGraphCoordinates(time: testTime, temperature: testTemp)
                let clampedTestPoint = calibration.clampToGraphBounds(testPoint)
                
                Circle()
                    .fill(Color.red)
                    .frame(width: 16, height: 16)
                    .position(clampedTestPoint)
                
                VStack(spacing: 2) {
                    Text("Test Point")
                        .font(.system(size: 10, weight: .bold))
                    Text("\(Int(testTime / 60)):\(String(format: "%02d", Int(testTime) % 60))")
                        .font(.system(size: 9))
                    Text("\(Int(testTemp))°F")
                        .font(.system(size: 9))
                }
                .foregroundColor(.red)
                .padding(4)
                .background(Color.white.opacity(0.9))
                .cornerRadius(4)
                .position(x: clampedTestPoint.x, y: clampedTestPoint.y - 40)
            }
        }
    }
}

// MARK: - Preview for Testing

#if DEBUG
struct GraphCalibrationHelper_Previews: PreviewProvider {
    static var previews: some View {
        GraphCalibrationHelper(
            imageName: "your-graph-image-name",
            imageWidth: 700,
            imageHeight: 600
        )
        .frame(width: 900, height: 900)
    }
}
#endif
