//
//  GraphHandling.swift
//  SR900MacOS
//
//  Graph data handling and rendering for roast profiles
//  Manages temperature data points during roastInProcess and plots them onto the background graph
//

import SwiftUI
import Combine

// MARK: - Data Models

/// Represents a single data point in the roast graph
struct RoastDataPoint: Identifiable, Codable {
    let id = UUID()
    let time: TimeInterval  // Seconds since roast start
    let temperature: Double  // Temperature in Fahrenheit
    let timestamp: Date
    
    // Optional metadata
    var fanLevel: Int?
    var heatLevel: Int?
    var rateOfRise: Double?  // Degrees per minute
    
    init(time: TimeInterval, temperature: Double, timestamp: Date = Date(), fanLevel: Int? = nil, heatLevel: Int? = nil) {
        self.time = time
        self.temperature = temperature
        self.timestamp = timestamp
        self.fanLevel = fanLevel
        self.heatLevel = heatLevel
    }
}

/// Represents a marked event during roasting (first crack, second crack, etc.)
struct RoastEvent: Identifiable, Codable {
    let id = UUID()
    let time: TimeInterval
    let eventType: EventType
    let note: String?
    
    enum EventType: String, Codable {
        case firstCrack = "First Crack"
        case secondCrack = "Second Crack"
        case customNote = "Note"
        case roastStart = "Start"
        case roastEnd = "End"
        case coolingStart = "Cooling"
    }
}

// MARK: - Graph Calibration

/// Calibration data for mapping temperature/time to graph coordinates
struct GraphCalibration: Codable {
    // Graph bounds in the image coordinate system
    var graphOriginX: CGFloat  // X coordinate of time = 0
    var graphOriginY: CGFloat  // Y coordinate of temperature = 0°F
    var graphWidth: CGFloat    // Total width of graph area
    var graphHeight: CGFloat   // Total height of graph area
    
    // Temperature scale
    var minTemperature: Double  // Minimum temperature (bottom of graph)
    var maxTemperature: Double  // Maximum temperature (top of graph)
    
    // Time scale
    var minTime: TimeInterval  // Minimum time (left of graph)
    var maxTime: TimeInterval  // Maximum time (right of graph)
    
    /// Default calibration for SR900 roast graph  
    /// Overlay size: 567×600 pixels
    /// X is good, adjusting Y upward
    static let `default` = GraphCalibration(
        graphOriginX: 47,      // Left edge at "0" time mark (good!)
        graphOriginY: 462,     // Bottom edge - moved UP from 540
        graphWidth: 473,       // Width from 0 to 15 minutes
        graphHeight: 325,      // Height from 0°F to 500°F
        minTemperature: 0,     // Bottom of graph (0°F)
        maxTemperature: 500,   // Top of graph (500°F)
        minTime: 0,            // Left edge (0 seconds)
        maxTime: 900           // Right edge (15 minutes = 900 seconds)
    )

    
    /// Convert temperature and time to graph coordinates
    func pointToGraphCoordinates(time: TimeInterval, temperature: Double) -> CGPoint {
        // Normalize time and temperature to 0-1 range
        let normalizedTime = (time - minTime) / (maxTime - minTime)
        let normalizedTemp = (temperature - minTemperature) / (maxTemperature - minTemperature)
        
        // Convert to graph coordinates
        let x = graphOriginX + (normalizedTime * graphWidth)
        // Y axis is inverted in SwiftUI (0 at top, increases downward)
        // So high temperature should have low Y value
        let y = graphOriginY - (normalizedTemp * graphHeight)
        
        return CGPoint(x: x, y: y)
    }
    
    /// Clamp values to graph bounds
    func clampToGraphBounds(_ point: CGPoint) -> CGPoint {
        let clampedX = max(graphOriginX, min(point.x, graphOriginX + graphWidth))
        let clampedY = max(graphOriginY - graphHeight, min(point.y, graphOriginY))
        return CGPoint(x: clampedX, y: clampedY)
    }
}

// MARK: - Graph Data Manager

/// Manages roast data collection and graph rendering
@MainActor
class GraphDataManager: ObservableObject {
    // MARK: - Published Properties
    
    @Published var dataPoints: [RoastDataPoint] = []
    @Published var events: [RoastEvent] = []
    @Published var isRecording: Bool = false
    @Published var currentRateOfRise: Double = 0  // °F per minute
    @Published var calibration: GraphCalibration = .default
    @Published var trendPoint: CGPoint? = nil  // 60-second prediction point
    
    // MARK: - Private Properties
    
    private var roastStartTime: Date?
    private var recordingTimer: Timer?
    private let recordingInterval: TimeInterval = 1.0  // Record every 1 second
    var controlState: ControlState? {  // Made settable for late initialization
        didSet {
            if controlState != nil && oldValue == nil {
                setupObservers()  // Setup observers when controlState is first set
            }
        }
    }
    private var cancellables = Set<AnyCancellable>()
    
    // Rate of Rise calculation
    private let rorWindowSize: Int = 15  // Calculate RoR over 15 seconds
    
    // MARK: - Initialization
    
    init(controlState: ControlState? = nil) {
        self.controlState = controlState
        if controlState != nil {
            setupObservers()
        }
    }
    
    // MARK: - Setup
    
    private func setupObservers() {
        guard let controlState = controlState else { return }
        
        // Observe roast state changes
        controlState.$roastInProcess
            .sink { [weak self] roastInProcess in
                if roastInProcess {
                    self?.startRecording()
                } else {
                    self?.stopRecording()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Recording Control
    
    /// Start recording roast data
    func startRecording() {
        guard !isRecording else { return }
        
        print("📊 Starting graph data recording")
        
        // Clear previous data
        dataPoints.removeAll()
        events.removeAll()
        currentRateOfRise = 0
        
        // Set start time
        roastStartTime = Date()
        isRecording = true
        
        // Record initial data point immediately at time=0
        // Use the captured start temperature from controlState (should be around 440°F)
        // This will plot at x=58 (graphOriginX) on the graph
        recordDataPoint()
        
        print("📊 First data point recorded at x=58 (graph origin)")
        if let temp = controlState?.roastStartTemperature {
            print("📊 Initial temperature: \(temp)°F (captured when 0x15/0x1A command was sent)")
        }
        
        // Start recording timer for subsequent points
        recordingTimer = Timer.scheduledTimer(withTimeInterval: recordingInterval, repeats: true) { [weak self] _ in
            self?.recordDataPoint()
        }
    }
    
    /// Stop recording roast data
    func stopRecording() {
        guard isRecording else { return }
        
        print("📊 Stopping graph data recording - captured \(dataPoints.count) points")
        
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
    }
    
    /// Record a single data point
    private func recordDataPoint() {
        guard let controlState = controlState,
              let startTime = roastStartTime,
              isRecording else { 
            print("⚠️ recordDataPoint() called but not ready - skipping")
            return 
        }
        
        let elapsedTime = Date().timeIntervalSince(startTime)
        let temperature = Double(controlState.beanTempValue)
        
        // Print what we're reading from controlState
        print("🔍 Reading beanTempValue: \(controlState.beanTempValue)°F from controlState")
        
        let dataPoint = RoastDataPoint(
            time: elapsedTime,
            temperature: temperature,
            timestamp: Date(),
            fanLevel: Int(controlState.fanMotorLevel),
            heatLevel: Int(controlState.heatLevel)
        )
        
        dataPoints.append(dataPoint)
        
        // Calculate graph coordinates for this point
        let graphPoint = calibration.pointToGraphCoordinates(time: elapsedTime, temperature: temperature)
        let clampedPoint = calibration.clampToGraphBounds(graphPoint)
        
        // Print coordinates for every point
        print("📍 Point \(dataPoints.count): time=\(String(format: "%.1f", elapsedTime))s, temp=\(Int(temperature))°F → graph coords: x=\(String(format: "%.1f", clampedPoint.x)), y=\(String(format: "%.1f", clampedPoint.y))")
        
        // Calculate rate of rise
        calculateRateOfRise()
        
        // Calculate 8-second slope
        calculate8SecondSlope()
        
        // Debug output every 10 seconds
        if Int(elapsedTime) % 10 == 0 {
            print("📈 10-sec summary: \(formatDuration(elapsedTime)) - \(Int(temperature))°F - RoR: \(String(format: "%.1f", currentRateOfRise))°F/min")
        }
    }
    
    // MARK: - Rate of Rise Calculation
    
    /// Calculate the rate of rise (temperature change per minute)
    private func calculateRateOfRise() {
        guard dataPoints.count >= 2 else {
            currentRateOfRise = 0
            return
        }
        
        // Get points from the RoR window
        let recentPoints = Array(dataPoints.suffix(min(rorWindowSize, dataPoints.count)))
        
        guard recentPoints.count >= 2,
              let firstPoint = recentPoints.first,
              let lastPoint = recentPoints.last else {
            currentRateOfRise = 0
            return
        }
        
        let timeDelta = lastPoint.time - firstPoint.time
        let tempDelta = lastPoint.temperature - firstPoint.temperature
        
        // Convert to degrees per minute
        if timeDelta > 0 {
            currentRateOfRise = (tempDelta / timeDelta) * 60.0
        } else {
            currentRateOfRise = 0
        }
    }
    
    /// Calculate slope (m) for y = mx + b equation using 8-second interval
    private func calculate8SecondSlope() {
        guard dataPoints.count >= 2, let mostRecentPoint = dataPoints.last else {
            trendPoint = nil
            return
        }
        
        // Don't show trend point during cooling phase (after Cool_Start_0x23 received)
        if let controlState = controlState, controlState.coolInProcess {
            trendPoint = nil
            print("❄️ Cooling in progress - trend point hidden")
            return
        }
        
        // Find point closest to 8 seconds ago
        let targetTime = mostRecentPoint.time - 8.0
        var closestPoint: RoastDataPoint?
        var smallestDiff = Double.infinity
        
        for point in dataPoints {
            let diff = abs(point.time - targetTime)
            if diff < smallestDiff {
                smallestDiff = diff
                closestPoint = point
            }
        }
        
        guard let oldPoint = closestPoint else {
            trendPoint = nil
            return
        }
        
        // Calculate slope: m = Δy / Δx = ΔTemp / ΔTime
        let timeDelta = mostRecentPoint.time - oldPoint.time
        guard timeDelta > 0 else {
            trendPoint = nil
            return
        }
        
        let slope = (mostRecentPoint.temperature - oldPoint.temperature) / timeDelta
        
        print("📐 Slope (m): \(String(format: "%.4f", slope))")
        
        // Calculate predicted temperature 60 seconds from now using y = mx + b
        // Current point: (mostRecentPoint.time, mostRecentPoint.temperature)
        // Predicted point: (mostRecentPoint.time + 60, predictedTemp)
        let predictedTime = mostRecentPoint.time + 60.0
        let predictedTemp = mostRecentPoint.temperature + (slope * 60.0)
        
        // Convert to graph coordinates
        let graphPoint = calibration.pointToGraphCoordinates(time: predictedTime, temperature: predictedTemp)
        trendPoint = calibration.clampToGraphBounds(graphPoint)
        
        print("🔮 Trend prediction: In 60s → \(String(format: "%.1f", predictedTemp))°F at time \(String(format: "%.1f", predictedTime))s")
    }
    
    // MARK: - Event Management
    
    /// Add a roast event (first crack, note, etc.)
    func addEvent(type: RoastEvent.EventType, note: String? = nil) {
        guard let startTime = roastStartTime else { return }
        
        let elapsedTime = Date().timeIntervalSince(startTime)
        let event = RoastEvent(time: elapsedTime, eventType: type, note: note)
        events.append(event)
        
        print("📍 Event added: \(type.rawValue) at \(formatDuration(elapsedTime))")
    }
    
    /// Mark first crack at current time
    func markFirstCrack() {
        addEvent(type: .firstCrack, note: "First crack")
    }
    
    /// Mark second crack at current time
    func markSecondCrack() {
        addEvent(type: .secondCrack, note: "Second crack")
    }
    
    /// Add custom note at current time
    func addNote(_ note: String) {
        addEvent(type: .customNote, note: note)
    }
    
    // MARK: - Graph Coordinate Conversion
    
    /// Convert data points to graph coordinates for drawing
    func getGraphPoints() -> [CGPoint] {
        return dataPoints.map { point in
            let graphPoint = calibration.pointToGraphCoordinates(
                time: point.time,
                temperature: point.temperature
            )
            return calibration.clampToGraphBounds(graphPoint)
        }
    }
    
    /// Get event positions on the graph
    func getEventPositions() -> [(event: RoastEvent, position: CGPoint)] {
        return events.compactMap { event in
            // Get temperature at event time (interpolate if needed)
            guard let temperature = getTemperatureAt(time: event.time) else { return nil }
            
            let graphPoint = calibration.pointToGraphCoordinates(
                time: event.time,
                temperature: temperature
            )
            let clampedPoint = calibration.clampToGraphBounds(graphPoint)
            
            return (event: event, position: clampedPoint)
        }
    }
    
    /// Get temperature at a specific time (with interpolation)
    private func getTemperatureAt(time: TimeInterval) -> Double? {
        // Find closest data points
        let sortedPoints = dataPoints.sorted { $0.time < $1.time }
        
        // Find exact match
        if let exactMatch = sortedPoints.first(where: { abs($0.time - time) < 0.5 }) {
            return exactMatch.temperature
        }
        
        // Find surrounding points for interpolation
        guard let beforeIndex = sortedPoints.lastIndex(where: { $0.time <= time }),
              beforeIndex + 1 < sortedPoints.count else {
            return sortedPoints.last?.temperature
        }
        
        let before = sortedPoints[beforeIndex]
        let after = sortedPoints[beforeIndex + 1]
        
        // Linear interpolation
        let timeFraction = (time - before.time) / (after.time - before.time)
        return before.temperature + (after.temperature - before.temperature) * timeFraction
    }
    
    // MARK: - Data Export/Import
    
    /// Export roast data to JSON
    func exportData() -> Data? {
        let exportData = RoastExportData(
            dataPoints: dataPoints,
            events: events,
            calibration: calibration,
            roastStartTime: roastStartTime
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        return try? encoder.encode(exportData)
    }
    
    /// Import roast data from JSON
    func importData(_ data: Data) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let importData = try decoder.decode(RoastExportData.self, from: data)
        
        dataPoints = importData.dataPoints
        events = importData.events
        calibration = importData.calibration
        roastStartTime = importData.roastStartTime
    }
    
    // MARK: - Utility Functions
    
    /// Format duration as MM:SS
    func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    /// Get current elapsed time
    func getCurrentElapsedTime() -> String {
        guard let startTime = roastStartTime, isRecording else {
            return "00:00"
        }
        let elapsed = Date().timeIntervalSince(startTime)
        return formatDuration(elapsed)
    }
    
    /// Get formatted rate of rise
    func getFormattedRateOfRise() -> String {
        if abs(currentRateOfRise) < 0.1 {
            return "-- °F / MINUTE"
        }
        return String(format: "%.1f °F / MINUTE", currentRateOfRise)
    }
}

// MARK: - Export Data Structure

struct RoastExportData: Codable {
    let dataPoints: [RoastDataPoint]
    let events: [RoastEvent]
    let calibration: GraphCalibration
    let roastStartTime: Date?
}

// MARK: - SwiftUI Shape for Drawing Graph Line

/// Shape that draws the roast curve on the graph
struct RoastCurveShape: Shape {
    let points: [CGPoint]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        guard let firstPoint = points.first else { return path }
        
        path.move(to: firstPoint)
        
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        
        return path
    }
}

// MARK: - Graph Overlay View

/// Overlay view that draws the roast data on top of the background graph image
struct GraphDataOverlay: View {
    @ObservedObject var graphManager: GraphDataManager
    
    var body: some View {
        GeometryReader { geometry in
            let _ = print("📐 GraphDataOverlay actual size: width=\(geometry.size.width), height=\(geometry.size.height)")
            let _ = print("📐 Calibration expects: graphOriginX=\(graphManager.calibration.graphOriginX), graphOriginY=\(graphManager.calibration.graphOriginY)")
            
            ZStack {
                // DEBUG: Draw calibration boundaries (COMMENTED OUT - calibration complete)
//                Rectangle()
//                    .stroke(Color.green, lineWidth: 2)
//                    .frame(
//                        width: graphManager.calibration.graphWidth,
//                        height: graphManager.calibration.graphHeight
//                    )
//                    .position(
//                        x: graphManager.calibration.graphOriginX + graphManager.calibration.graphWidth / 2,
//                        y: graphManager.calibration.graphOriginY - graphManager.calibration.graphHeight / 2
//                    )
                
                // DEBUG: Mark the origin point (COMMENTED OUT - calibration complete)
//                Circle()
//                    .fill(Color.blue)
//                    .frame(width: 10, height: 10)
//                    .position(x: graphManager.calibration.graphOriginX, y: graphManager.calibration.graphOriginY)
                
                // Draw the main roast curve
                RoastCurveShape(points: graphManager.getGraphPoints())
                    .stroke(Color.red, lineWidth: 2.5)
                
                // Draw trend prediction point (60 seconds ahead)
                if let trendPoint = graphManager.trendPoint {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                        .position(trendPoint)
                        .opacity(0.7)
                }
                
                // Draw data points
                ForEach(Array(graphManager.getGraphPoints().enumerated()), id: \.offset) { index, point in
                    if index % 10 == 0 {  // Draw a point every 10 seconds
                        Circle()
                            .fill(Color.red)
                            .frame(width: 4, height: 4)
                            .position(point)
                    }
                }
                
                // Draw event markers
                ForEach(graphManager.getEventPositions(), id: \.event.id) { eventData in
                    VStack(spacing: 2) {
                        Image(systemName: eventIconName(for: eventData.event.eventType))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(eventColor(for: eventData.event.eventType))
                        
                        Text(eventData.event.eventType.rawValue)
                            .font(.system(size: 8, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(3)
                    }
                    .position(x: eventData.position.x, y: eventData.position.y - 20)
                }
            }
        }
    }
    
    /// Get icon name for event type
    private func eventIconName(for type: RoastEvent.EventType) -> String {
        switch type {
        case .firstCrack: return "bolt.fill"
        case .secondCrack: return "bolt.circle.fill"
        case .customNote: return "note.text"
        case .roastStart: return "play.circle.fill"
        case .roastEnd: return "stop.circle.fill"
        case .coolingStart: return "wind"
        }
    }
    
    /// Get color for event type
    private func eventColor(for type: RoastEvent.EventType) -> Color {
        switch type {
        case .firstCrack, .secondCrack: return .orange
        case .customNote: return .blue
        case .roastStart: return .green
        case .roastEnd: return .red
        case .coolingStart: return .cyan
        }
    }
}
