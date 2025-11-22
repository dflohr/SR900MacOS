# Graph Handling System - Implementation Summary

## Files Created

### 1. **GraphHandling.swift** (Main Implementation)
The core system that manages all roast data recording and plotting.

**Key Classes:**
- `GraphDataManager`: Main observable class that handles recording
- `RoastDataPoint`: Data model for each temperature reading
- `RoastEvent`: Data model for marked events (first crack, notes)
- `GraphCalibration`: Converts temperature/time to graph coordinates
- `GraphDataOverlay`: SwiftUI view that draws the curve
- `RoastCurveShape`: Shape for drawing the roast line

**Key Features:**
- ✅ Automatic recording when `roastInProcess = true`
- ✅ Temperature data captured every 1 second
- ✅ Rate of Rise (RoR) calculation over 30-second window
- ✅ Event marking (first crack, custom notes)
- ✅ Coordinate conversion for plotting on graph image
- ✅ JSON export/import for saving roast profiles
- ✅ Thread-safe with `@MainActor`

### 2. **GraphHandling_README.md** (Documentation)
Complete guide covering:
- Overview of all components
- Step-by-step calibration instructions
- Integration examples
- Customization options
- Troubleshooting guide
- Advanced features

### 3. **GraphCalibrationHelper.swift** (Calibration Tool)
Interactive SwiftUI view for finding calibration values:
- Visual overlay on your graph image
- Real-time preview of calibration
- Adjustable origin, size, and scale values
- Test point visualization
- Automatic Swift code generation
- Copy to clipboard functionality

### 4. **GraphHandling+Examples.swift** (Usage Examples)
10 comprehensive examples including:
1. Basic integration in parent view
2. Manual recording control
3. Custom calibration profiles
4. Saving/loading roast profiles
5. Custom event types
6. Real-time statistics view
7. Comparing multiple roasts
8. Animated real-time drawing
9. Temperature zones overlay
10. Export with metadata

### 5. **RoastGraphView.swift** (Updated)
Modified to integrate with the graph system:
- Added `GraphDataManager` and `ControlState` parameters
- Replaced static values with live data
- Integrated `GraphDataOverlay` for plotting
- Connected buttons to graph manager methods
- Buttons disabled when roast not active

## How It Works

### Automatic Recording Flow

```
1. User starts roast → controlState.roastInProcess = true
2. GraphDataManager observes state change
3. GraphDataManager.startRecording() is called automatically
4. Timer starts recording every 1 second:
   - Reads controlState.beanTempValue
   - Reads controlState.fanMotorLevel
   - Reads controlState.heatLevel
   - Creates RoastDataPoint with current data
   - Calculates Rate of Rise
5. Data points are stored in array
6. SwiftUI automatically redraws GraphDataOverlay
7. User stops roast → controlState.roastInProcess = false
8. GraphDataManager.stopRecording() called automatically
9. Final roast data is available for export
```

### Coordinate Conversion

```
Temperature/Time → Graph Coordinates:

1. Normalize to 0-1 range:
   normalizedTime = (time - minTime) / (maxTime - minTime)
   normalizedTemp = (temp - minTemp) / (maxTemp - minTemp)

2. Convert to pixel coordinates:
   x = graphOriginX + (normalizedTime × graphWidth)
   y = graphOriginY - (normalizedTemp × graphHeight)
   
   Note: Y is inverted (0 at top in SwiftUI)

3. Clamp to graph bounds to prevent overflow
```

## Integration Steps

### Step 1: Add GraphDataManager to Your Parent View

```swift
@ObservedObject var controlState: ControlState
@StateObject private var graphManager: GraphDataManager

init(controlState: ControlState) {
    self.controlState = controlState
    _graphManager = StateObject(
        wrappedValue: GraphDataManager(controlState: controlState)
    )
}
```

### Step 2: Update RoastGraphView Usage

```swift
RoastGraphView(
    graphManager: graphManager,
    controlState: controlState,
    width: 700,
    imageName: "your-graph-background-image"
)
```

### Step 3: Calibrate Graph Coordinates

Option A - Use the calibration helper:
```swift
GraphCalibrationHelper(
    imageName: "your-graph-background-image",
    imageWidth: 700,
    imageHeight: 600
)
```

Option B - Measure manually and update GraphCalibration.default

### Step 4: Test and Verify

1. Start a test roast
2. Watch the curve being drawn
3. Verify alignment with graph axes
4. Adjust calibration if needed
5. Mark first crack to test events
6. Export data to verify JSON structure

## Calibration Quick Reference

**You need to find these 8 values:**

1. `graphOriginX` - X coordinate of time=0 (pixels from left edge)
2. `graphOriginY` - Y coordinate of temp=0 (pixels from top edge)
3. `graphWidth` - Width of plottable area (pixels)
4. `graphHeight` - Height of plottable area (pixels)
5. `minTemperature` - Bottom of Y-axis (°F)
6. `maxTemperature` - Top of Y-axis (°F)
7. `minTime` - Left of X-axis (seconds, usually 0)
8. `maxTime` - Right of X-axis (seconds, e.g., 900 for 15 min)

**Default values provided (adjust for your graph):**
```swift
static let `default` = GraphCalibration(
    graphOriginX: 70,
    graphOriginY: 520,
    graphWidth: 600,
    graphHeight: 400,
    minTemperature: 0,
    maxTemperature: 500,
    minTime: 0,
    maxTime: 900
)
```

## Features Summary

### Recording Features
- [x] Automatic start/stop based on roast state
- [x] 1-second recording interval (configurable)
- [x] Temperature tracking
- [x] Fan level tracking
- [x] Heat level tracking
- [x] Timestamp for each point
- [x] Rate of Rise calculation (30-second window)

### Visualization Features
- [x] Real-time curve drawing
- [x] Data point markers (every 10 seconds)
- [x] Event markers with icons
- [x] Color-coded events
- [x] Smooth line rendering
- [x] Automatic redraw on data change

### Event Features
- [x] First crack marking
- [x] Second crack marking
- [x] Custom note events
- [x] Roast start/end events
- [x] Cooling start events
- [x] Timestamp for each event

### Data Management Features
- [x] Export to JSON
- [x] Import from JSON
- [x] Structured data format
- [x] ISO8601 timestamps
- [x] Pretty-printed JSON

### UI Integration Features
- [x] Live temperature display
- [x] Live elapsed time display
- [x] Live RoR display
- [x] First crack button (enabled during roast)
- [x] Note saving button (enabled during roast)
- [x] Automatic button state management

## Performance Characteristics

- **Memory usage**: ~100 bytes per data point
- **Typical roast** (15 min): ~900 points = ~90 KB
- **Extended roast** (30 min): ~1800 points = ~180 KB
- **Recording overhead**: Negligible (1 read per second)
- **Drawing performance**: Optimized by SwiftUI
- **Export file size**: 50-100 KB per roast (with events)

## Thread Safety

All operations are `@MainActor` to ensure UI updates happen on main thread:
- `GraphDataManager` is `@MainActor`
- State changes trigger SwiftUI updates automatically
- No manual thread switching required
- Combine publishers automatically deliver on main thread

## Error Handling

The system is defensive against:
- Missing control state (graceful degradation)
- Out-of-bounds coordinates (clamping)
- Empty data arrays (early returns)
- Invalid JSON (do-catch with optional returns)
- Missing temperature data (continues recording)

## Next Steps

1. **Immediate**:
   - Calibrate for your specific graph image
   - Test with a short roast
   - Verify curve alignment

2. **Short Term**:
   - Add export functionality to your UI
   - Create folder structure for saved roasts
   - Test different roast profiles

3. **Future Enhancements**:
   - Target curve overlay (load reference roast)
   - Automatic crack detection
   - Temperature prediction
   - Multi-roast comparison view
   - Statistical analysis (average RoR, total time, etc.)

## Support

For issues or questions:
1. Check the README documentation
2. Review the examples file
3. Use the calibration helper tool
4. Verify your graph image dimensions
5. Check console output for debug messages (look for 📊 📈 📍 emojis)

## Version Info

- **Created**: November 2025
- **Platform**: macOS (SR900MacOS)
- **Swift Version**: Swift 5.9+
- **Framework**: SwiftUI
- **Concurrency**: Swift Concurrency (async/await, actors)
