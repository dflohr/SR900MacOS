# Graph Handling System - Setup Guide

## Overview
The `GraphHandling.swift` file provides a complete system for recording, managing, and plotting roast temperature data during active roasts. It automatically tracks temperature readings, calculates rate of rise, and overlays the data onto your background graph image.

## Key Components

### 1. **GraphDataManager**
The main observable class that manages all roast data recording:
- Automatically starts/stops recording based on `roastInProcess` state
- Records temperature data points every 1 second
- Calculates rate of rise (RoR) over a 30-second window
- Manages roast events (first crack, notes, etc.)
- Converts data points to graph coordinates for plotting

### 2. **GraphCalibration**
Defines how temperature/time values map to graph image coordinates:
```swift
GraphCalibration(
    graphOriginX: 70,      // Left edge of graph area (in pixels)
    graphOriginY: 520,     // Bottom edge of graph area
    graphWidth: 600,       // Width of plottable area
    graphHeight: 400,      // Height of plottable area
    minTemperature: 0,     // Bottom of temperature scale
    maxTemperature: 500,   // Top of temperature scale
    minTime: 0,            // Start time (seconds)
    maxTime: 900           // End time (15 minutes)
)
```

### 3. **GraphDataOverlay**
SwiftUI view that draws the roast curve and events on top of the background image.

## Calibration Instructions

To properly calibrate the graph for your background image:

### Step 1: Identify Your Graph Bounds
Open your background graph image in an image editor and note these coordinates:

1. **Origin Point (0,0)**: Where does time=0 and temperature=0 intersect?
   - Measure X pixels from left edge → `graphOriginX`
   - Measure Y pixels from top edge → `graphOriginY`

2. **Graph Dimensions**: What's the size of the plottable area?
   - Width in pixels → `graphWidth`
   - Height in pixels → `graphHeight`

### Step 2: Define Temperature Scale
Look at your graph's Y-axis labels:
- What's the minimum temperature shown? → `minTemperature`
- What's the maximum temperature shown? → `maxTemperature`

### Step 3: Define Time Scale
Look at your graph's X-axis labels:
- What's the starting time? (usually 0) → `minTime`
- What's the ending time in seconds? → `maxTime`
  - Example: 15 minutes = 900 seconds

### Step 4: Update GraphCalibration
Edit the default calibration in `GraphHandling.swift`:

```swift
static let `default` = GraphCalibration(
    graphOriginX: YOUR_X_VALUE,
    graphOriginY: YOUR_Y_VALUE,
    graphWidth: YOUR_WIDTH,
    graphHeight: YOUR_HEIGHT,
    minTemperature: YOUR_MIN_TEMP,
    maxTemperature: YOUR_MAX_TEMP,
    minTime: YOUR_MIN_TIME,
    maxTime: YOUR_MAX_TIME
)
```

### Step 5: Test and Adjust
1. Start a test roast
2. Watch the plotted curve
3. If the curve is:
   - **Too far left/right**: Adjust `graphOriginX` or `maxTime`
   - **Too high/low**: Adjust `graphOriginY` or `maxTemperature`
   - **Stretched/compressed horizontally**: Adjust `graphWidth` or `maxTime`
   - **Stretched/compressed vertically**: Adjust `graphHeight` or `maxTemperature`

## Integration with Your App

### In Your View That Contains RoastGraphView:

```swift
@StateObject private var graphManager: GraphDataManager
@ObservedObject var controlState: ControlState

init(controlState: ControlState) {
    self.controlState = controlState
    _graphManager = StateObject(wrappedValue: GraphDataManager(controlState: controlState))
}

var body: some View {
    RoastGraphView(
        graphManager: graphManager,
        controlState: controlState,
        width: 700,
        imageName: "your-graph-image"
    )
}
```

### Recording Behavior:
- **Automatic**: Recording starts when `controlState.roastInProcess = true`
- **Automatic**: Recording stops when `controlState.roastInProcess = false`
- Data points are recorded every 1 second
- Rate of rise calculated over 30-second window

## Features

### Automatic Data Recording
- ✅ Temperature tracking every 1 second
- ✅ Fan and heat level recording
- ✅ Rate of rise calculation
- ✅ Timestamp for each data point

### Event Marking
```swift
// First crack button (already integrated)
graphManager.markFirstCrack()

// Custom notes (already integrated)
graphManager.addNote("Your note here")

// Additional events you can add:
graphManager.markSecondCrack()
graphManager.addEvent(type: .coolingStart, note: "Cooling started")
```

### Data Export
```swift
// Export to JSON
if let data = graphManager.exportData() {
    // Save to file or share
    try? data.write(to: fileURL)
}

// Import from JSON
if let data = try? Data(contentsOf: fileURL) {
    try? graphManager.importData(data)
}
```

## Customization

### Change Recording Interval
Edit `recordingInterval` in GraphDataManager:
```swift
private let recordingInterval: TimeInterval = 1.0  // Change to 0.5 for twice per second
```

### Change RoR Window
Edit `rorWindowSize` in GraphDataManager:
```swift
private let rorWindowSize: Int = 30  // Change to 60 for 1-minute average
```

### Customize Graph Appearance
Edit the `GraphDataOverlay` view to change:
- Line color: `.stroke(Color.red, lineWidth: 2.5)`
- Point size: `.frame(width: 4, height: 4)`
- Point frequency: `if index % 10 == 0` (every 10 seconds)
- Event icons and colors

## Troubleshooting

### Issue: Graph isn't drawing
**Solution**: Check that:
1. `graphManager` is properly initialized with `controlState`
2. `roastInProcess` is true
3. Background image is loading correctly
4. Calibration values are within reasonable ranges

### Issue: Graph is offset or scaled wrong
**Solution**: 
1. Re-measure your graph image coordinates carefully
2. Remember Y coordinates increase **downward** in SwiftUI
3. Ensure your image frame size matches the calibration

### Issue: No temperature data
**Solution**: 
1. Verify `controlState.beanTempValue` is being updated
2. Check BLE connection is active
3. Look for console output: "📈 Recorded: ..."

### Issue: Rate of Rise shows "--"
**Solution**: 
- RoR requires at least 2 data points
- Wait a few seconds after roast starts
- Check that temperature is changing

## Advanced: Multiple Graph Profiles

You can create different calibrations for different graph images:

```swift
struct GraphCalibration {
    static let sr900Standard = GraphCalibration(...)
    static let sr900Detailed = GraphCalibration(...)
    static let customProfile = GraphCalibration(...)
}

// Then use:
graphManager.calibration = .sr900Detailed
```

## Data Structure

### RoastDataPoint
```swift
struct RoastDataPoint {
    let time: TimeInterval        // Seconds since start
    let temperature: Double       // °F
    let timestamp: Date          // Absolute time
    var fanLevel: Int?           // 0-9
    var heatLevel: Int?          // 0-9
    var rateOfRise: Double?      // °F per minute
}
```

### RoastEvent
```swift
struct RoastEvent {
    let time: TimeInterval
    let eventType: EventType     // .firstCrack, .secondCrack, etc.
    let note: String?
}
```

## Performance Notes

- Recording 1 point per second for 15 minutes = 900 points (negligible memory)
- Graph redraws automatically when data changes (SwiftUI handles optimization)
- Export file size: ~50-100KB per roast depending on events and notes

## Future Enhancements

Possible additions you might want:
- Target curve comparison (load reference roast)
- Temperature predictions based on RoR
- Automatic crack detection via temperature patterns
- Multiple curve overlays for comparison
- Zoom/pan controls for graph viewing
- Real-time graph during roast
