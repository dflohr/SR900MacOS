//
//  GraphHandling+Examples.swift
//  SR900MacOS
//
//  Example usage patterns for the graph handling system
//

import SwiftUI

// MARK: - Example 1: Basic Integration in Parent View

/*
struct RoastControlView: View {
    @ObservedObject var controlState: ControlState
    @StateObject private var graphManager: GraphDataManager
    
    init(controlState: ControlState) {
        self.controlState = controlState
        // Initialize graph manager with control state for automatic recording
        _graphManager = StateObject(wrappedValue: GraphDataManager(controlState: controlState))
    }
    
    var body: some View {
        VStack {
            // Your roast controls here
            
            // Graph view with automatic data plotting
            RoastGraphView(
                graphManager: graphManager,
                controlState: controlState,
                width: 700,
                imageName: "roast-graph-background"
            )
            
            // Additional controls
            exportButton
        }
    }
    
    var exportButton: some View {
        Button("Export Roast Data") {
            if let data = graphManager.exportData() {
                saveToFile(data)
            }
        }
    }
    
    func saveToFile(_ data: Data) {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "roast-\(Date().formatted()).json"
        panel.allowedContentTypes = [.json]
        
        if panel.runModal() == .OK, let url = panel.url {
            try? data.write(to: url)
        }
    }
}
*/

// MARK: - Example 2: Manual Control of Recording

/*
struct ManualRecordingExample: View {
    @StateObject private var graphManager = GraphDataManager()
    @State private var currentTemp: Double = 200
    
    var body: some View {
        VStack {
            Text("Temperature: \(Int(currentTemp))°F")
            
            Button("Start Recording") {
                graphManager.startRecording()
            }
            
            Button("Stop Recording") {
                graphManager.stopRecording()
            }
            
            Button("Mark First Crack") {
                graphManager.markFirstCrack()
            }
            
            // Display recorded data
            List(graphManager.dataPoints) { point in
                HStack {
                    Text("\(graphManager.formatDuration(point.time))")
                    Text("\(Int(point.temperature))°F")
                }
            }
        }
    }
}
*/

// MARK: - Example 3: Custom Calibration Profiles

extension GraphCalibration {
    /// Standard SR900 graph with 15-minute timeline
    static let sr900Standard = GraphCalibration(
        graphOriginX: 70,
        graphOriginY: 520,
        graphWidth: 600,
        graphHeight: 400,
        minTemperature: 0,
        maxTemperature: 500,
        minTime: 0,
        maxTime: 900  // 15 minutes
    )
    
    /// Extended timeline for longer roasts (20 minutes)
    static let sr900Extended = GraphCalibration(
        graphOriginX: 70,
        graphOriginY: 520,
        graphWidth: 600,
        graphHeight: 400,
        minTemperature: 0,
        maxTemperature: 500,
        minTime: 0,
        maxTime: 1200  // 20 minutes
    )
    
    /// High-resolution graph with finer detail
    static let sr900HighRes = GraphCalibration(
        graphOriginX: 100,
        graphOriginY: 700,
        graphWidth: 900,
        graphHeight: 600,
        minTemperature: 0,
        maxTemperature: 500,
        minTime: 0,
        maxTime: 900
    )
}

/*
// Usage:
graphManager.calibration = .sr900Extended
*/

// MARK: - Example 4: Saving and Loading Roast Profiles

/*
extension GraphDataManager {
    /// Save roast profile to a specific location
    func saveRoastProfile(name: String, beansInfo: String? = nil) {
        guard let data = exportData() else { return }
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let roastsFolder = documentsURL.appendingPathComponent("Roasts", isDirectory: true)
        
        // Create folder if needed
        try? fileManager.createDirectory(at: roastsFolder, withIntermediateDirectories: true)
        
        // Save file
        let fileName = "\(name)-\(Date().formatted()).json"
        let fileURL = roastsFolder.appendingPathComponent(fileName)
        
        try? data.write(to: fileURL)
        print("✅ Saved roast profile to: \(fileURL.path)")
    }
    
    /// Load a roast profile from file
    func loadRoastProfile(from url: URL) throws {
        let data = try Data(contentsOf: url)
        try importData(data)
        print("✅ Loaded roast profile from: \(url.path)")
    }
}
*/

// MARK: - Example 5: Custom Event Types

/*
// Extend RoastEvent.EventType with custom events
extension RoastEvent.EventType {
    static let developmentStart = EventType(rawValue: "Development Start")
    static let firstSnap = EventType(rawValue: "First Snap")
    static let rollingCrack = EventType(rawValue: "Rolling Crack")
    static let endOfCrack = EventType(rawValue: "End of Crack")
}

// Usage:
graphManager.addEvent(type: .developmentStart, note: "Beans changing color")
*/

// MARK: - Example 6: Real-Time Statistics View

/*
struct RoastStatisticsView: View {
    @ObservedObject var graphManager: GraphDataManager
    @ObservedObject var controlState: ControlState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Roast Statistics")
                .font(.headline)
            
            HStack {
                StatItem(title: "Elapsed", value: graphManager.getCurrentElapsedTime())
                StatItem(title: "Temp", value: "\(controlState.beanTempValue)°F")
                StatItem(title: "RoR", value: graphManager.getFormattedRateOfRise())
            }
            
            HStack {
                StatItem(title: "Data Points", value: "\(graphManager.dataPoints.count)")
                StatItem(title: "Events", value: "\(graphManager.events.count)")
                StatItem(title: "Fan", value: "\(Int(controlState.fanMotorLevel))")
                StatItem(title: "Heat", value: "\(Int(controlState.heatLevel))")
            }
            
            // Show recent events
            if !graphManager.events.isEmpty {
                Text("Recent Events:")
                    .font(.subheadline)
                    .padding(.top, 5)
                
                ForEach(graphManager.events.suffix(3)) { event in
                    HStack {
                        Text(graphManager.formatDuration(event.time))
                            .font(.caption.monospaced())
                        Text(event.eventType.rawValue)
                            .font(.caption)
                        if let note = event.note {
                            Text("-")
                            Text(note)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(.body, design: .monospaced))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
*/

// MARK: - Example 7: Comparing Multiple Roasts

/*
struct RoastComparisonView: View {
    let roast1: GraphDataManager
    let roast2: GraphDataManager
    let calibration: GraphCalibration
    
    var body: some View {
        ZStack {
            // Background graph
            Image("graph-background")
                .resizable()
                .scaledToFit()
            
            // First roast curve (red)
            RoastCurveShape(points: roast1.getGraphPoints())
                .stroke(Color.red, lineWidth: 2)
            
            // Second roast curve (blue)
            RoastCurveShape(points: roast2.getGraphPoints())
                .stroke(Color.blue, lineWidth: 2)
            
            // Legend
            VStack(alignment: .leading) {
                HStack {
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 20, height: 3)
                    Text("Roast 1")
                }
                HStack {
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: 20, height: 3)
                    Text("Roast 2")
                }
            }
            .padding()
            .background(Color.white.opacity(0.8))
            .cornerRadius(8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding()
        }
    }
}
*/

// MARK: - Example 8: Animated Real-Time Drawing

/*
struct AnimatedGraphView: View {
    @ObservedObject var graphManager: GraphDataManager
    @State private var animationProgress: CGFloat = 0
    
    var body: some View {
        ZStack {
            Image("graph-background")
                .resizable()
                .scaledToFit()
            
            // Animated curve that draws from left to right
            RoastCurveShape(points: graphManager.getGraphPoints())
                .trim(from: 0, to: animationProgress)
                .stroke(Color.red, lineWidth: 2.5)
        }
        .onChange(of: graphManager.dataPoints.count) { _ in
            withAnimation(.linear(duration: 0.5)) {
                animationProgress = 1.0
            }
        }
        .onAppear {
            animationProgress = 1.0
        }
    }
}
*/

// MARK: - Example 9: Temperature Zones Overlay

/*
struct TemperatureZonesView: View {
    let calibration: GraphCalibration
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Development zone (above 350°F)
                ZoneLayer(color: Color.red.opacity(0.1), label: "DEVELOPMENT")
                    .frame(height: zoneHeight(for: 350...500))
                
                // Maillard zone (300-350°F)
                ZoneLayer(color: Color.orange.opacity(0.1), label: "MAILLARD")
                    .frame(height: zoneHeight(for: 300...350))
                
                // Drying zone (150-300°F)
                ZoneLayer(color: Color.yellow.opacity(0.1), label: "DRYING")
                    .frame(height: zoneHeight(for: 150...300))
                
                // Pre-heat zone (below 150°F)
                ZoneLayer(color: Color.blue.opacity(0.1), label: "PRE-HEAT")
                    .frame(height: zoneHeight(for: 0...150))
            }
        }
    }
    
    func zoneHeight(for range: ClosedRange<Double>) -> CGFloat {
        let totalRange = calibration.maxTemperature - calibration.minTemperature
        let zoneRange = range.upperBound - range.lowerBound
        return calibration.graphHeight * (zoneRange / totalRange)
    }
}

struct ZoneLayer: View {
    let color: Color
    let label: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(color)
            
            Text(label)
                .font(.caption.bold())
                .foregroundColor(.gray.opacity(0.5))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 10)
        }
    }
}
*/

// MARK: - Example 10: Export Dialog with Metadata

/*
struct RoastExportView: View {
    @ObservedObject var graphManager: GraphDataManager
    @State private var roastName: String = ""
    @State private var beanType: String = ""
    @State private var beanWeight: String = ""
    @State private var notes: String = ""
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Export Roast Profile")
                .font(.headline)
            
            Form {
                TextField("Roast Name", text: $roastName)
                TextField("Bean Type", text: $beanType)
                TextField("Bean Weight (g)", text: $beanWeight)
                TextField("Notes", text: $notes, axis: .vertical)
                    .lineLimit(3...5)
            }
            
            HStack {
                Button("Cancel") {
                    // Dismiss
                }
                
                Button("Export") {
                    exportRoast()
                }
                .disabled(roastName.isEmpty)
            }
        }
        .padding()
        .frame(width: 400)
    }
    
    func exportRoast() {
        guard var data = graphManager.exportData(),
              var json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return
        }
        
        // Add metadata
        json["roastName"] = roastName
        json["beanType"] = beanType
        json["beanWeight"] = beanWeight
        json["notes"] = notes
        json["exportDate"] = ISO8601DateFormatter().string(from: Date())
        
        // Convert back to data
        guard let enhancedData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) else {
            return
        }
        
        // Save file
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "\(roastName.isEmpty ? "roast" : roastName)-\(Date().formatted()).json"
        panel.allowedContentTypes = [.json]
        
        if panel.runModal() == .OK, let url = panel.url {
            try? enhancedData.write(to: url)
        }
    }
}
*/

// MARK: - Tips and Best Practices

/*
 TIPS FOR USING THE GRAPH SYSTEM:
 
 1. CALIBRATION:
    - Use GraphCalibrationHelper view to find exact coordinates
    - Test with known temperature points (e.g., room temp, boiling point)
    - Save multiple calibrations for different graph images
 
 2. PERFORMANCE:
    - Recording at 1 second intervals is ideal for most roasts
    - For very long roasts (>20 min), consider 2-second intervals
    - Data points are lightweight (~100 bytes each)
 
 3. DATA MANAGEMENT:
    - Export important roasts immediately after completion
    - Store in organized folders (by date, bean type, etc.)
    - Include metadata (bean info, weather, etc.) in file name or notes
 
 4. ACCURACY:
    - Ensure BLE connection is stable during roasting
    - Verify temperature readings match display
    - Cross-check RoR calculations with manual observations
 
 5. EVENTS:
    - Mark first crack immediately when heard
    - Add notes about bean color, aroma, development
    - Use events for post-roast analysis and replication
 
 6. TROUBLESHOOTING:
    - If graph is offset: Check calibration origin points
    - If curve is stretched: Verify min/max time and temp values
    - If data isn't recording: Ensure controlState is connected
    - If RoR is erratic: Increase rorWindowSize for smoother average
 */
