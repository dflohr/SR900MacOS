# Quick Reference: Graph Plotting Implementation

## 🎯 Goal
Start plotting graph when either **0x1A_StartProfileRoast** or **0x15_StartManualRoast** is sent, with initial point at **x=58** and temperature value from **BeanTemperatureDisplay** (approximately **y=440°F**).

## ✅ Implementation Status

### 1. ControlState - Temperature Capture ✅
```swift
@Published var roastStartTemperature: Int = 0
```
**Purpose:** Captures the exact temperature displayed in `BeanTemperatureDisplay` when roast command is sent.

### 2. StartManualRoast (0x15) - Capture on Send ✅
**Location:** `0x15_StartManualRoast.swift` → `startManualRoast()` function

**What it does:**
- Captures `controlState.beanTempValue` BEFORE sending 0x15 command
- Stores in `controlState.roastStartTemperature`
- Logs the captured temperature for verification

### 3. StartProfileRoast (0x1A) - Capture on Send ✅
**Location:** `0x1A_StartProfileRoast.swift` → `startSavedProfileRoast()` function (NEW FILE)

**What it does:**
- Captures `controlState.beanTempValue` BEFORE sending 0x1A command  
- Stores in `controlState.roastStartTemperature`
- Logs the captured temperature for verification
- Waits for 0x1C acknowledgment to confirm roast started

### 4. GraphDataManager - Use Captured Temperature ✅
**Location:** `GraphHandling.swift` → `startRecording()` function

**What it does:**
- Automatically starts when `roastInProcess` becomes `true`
- First data point is recorded at time=0
- Uses `controlState.beanTempValue` (which should match captured start temp)
- Maps to graph coordinates: x=58, y=calculated from temperature

### 5. BLEManager - Pass ControlState ✅
**Location:** `BLEManager.swift` → `startSavedProfileRoast()` function

**What it does:**
- Passes `controlState` to profile roast handler
- Enables temperature capture for profile roasts

## 📊 Graph Coordinate System

### Current Configuration (GraphCalibration.default)
```swift
graphOriginX: 58        // ✅ Matches requirement (x=58)
graphOriginY: 500       // Bottom of graph in image coordinates
graphWidth: 585         // Total width of plotting area
graphHeight: 400        // Total height of plotting area
minTemperature: 0       // Bottom of Y-axis
maxTemperature: 500     // Top of Y-axis (440°F fits here)
minTime: 0              // Start time (left edge)
maxTime: 900            // End time (15 minutes in seconds)
```

### Mapping Formula
```swift
// Time → X coordinate
x = 58 + (time_seconds / 900) * 585

// Temperature → Y coordinate  
y = 500 - (temperature / 500) * 400

// Examples:
// time=0, temp=440°F → x=58, y≈148
// time=450, temp=450°F → x=351, y≈140  
// time=900, temp=420°F → x=643, y≈164
```

## 🔄 Flow Diagrams

### Manual Roast Flow
```
User clicks "Start Manual Roast"
    ↓
Capture controlState.beanTempValue → roastStartTemperature
    ↓
Send 0x15 command to roaster
    ↓
Roaster responds with 0x21 status (maybe ignored)
    ↓
roastInProcess = true (from status messages)
    ↓
GraphDataManager.startRecording() triggered
    ↓
First point: (time=0, temp=roastStartTemperature)
    ↓
Maps to: (x=58, y≈440 on graph)
    ↓
Continue recording every 1 second
```

### Profile Roast Flow
```
User clicks "Start Profile Roast"
    ↓
Capture controlState.beanTempValue → roastStartTemperature
    ↓
Send 0x1A command to roaster
    ↓
Roaster responds with 0x1C acknowledgment
    ↓
Check byte[5] in 0x1C message:
    - 0x01: Roast started → roastInProcess = true
    - 0x03: Profile uploaded only
    - 0x04: Error
    - 0x05: No saved profile
    ↓
If byte[5]=0x01: GraphDataManager.startRecording() triggered
    ↓
First point: (time=0, temp=roastStartTemperature)
    ↓
Maps to: (x=58, y≈440 on graph)
    ↓
Continue recording every 1 second
```

## 🧪 Verification Steps

### Console Logs to Watch For

1. **When 0x15 is sent:**
```
📊 Captured roast start temperature: 440°F (will plot at x=58, y≈440)
✅ StartManualRoast: Sent manual roast command (Fan: X, Heat: X, ...)
```

2. **When 0x1A is sent:**
```
📊 Captured roast start temperature: 440°F (will plot at x=58, y≈440)
✅ StartProfileRoast: Sent 0x1A command - waiting for 0x1C acknowledgment
```

3. **When graph recording starts:**
```
📊 Starting graph data recording
📊 First data point recorded at x=58 (graph origin)
📊 Initial temperature: 440°F (captured when 0x15/0x1A command was sent)
```

### Visual Verification
1. Check `BeanTemperatureDisplay` value before starting roast (should be ~440°F)
2. Start roast (either manual or profile)
3. Check console logs confirm temperature was captured
4. Verify graph's first point appears at x=58 (left edge of graph area)
5. Verify first point's Y position corresponds to ~440°F on the scale

## 📝 Key Implementation Details

### Why Capture Temperature BEFORE Sending Command?
- Temperature might change during command transmission and response
- User expects graph to start with the value they saw on screen
- Prevents race conditions between command and status updates

### Why Not Just Use First Status Message?
- Status messages are asynchronous
- Might be delayed or arrive out of order
- Could have different temperature than displayed when user clicked start

### Automatic Recording Start
- No manual trigger needed
- GraphDataManager observes `roastInProcess` property
- Automatically starts recording when it becomes `true`
- Works for both manual (0x15) and profile (0x1A) roasts

## 🐛 Troubleshooting

### Issue: Graph doesn't start at x=58
**Check:** `GraphCalibration.default.graphOriginX` should be 58

### Issue: First temperature is wrong
**Check:** `roastStartTemperature` is being captured before command is sent
**Verify:** Console logs show correct temperature value

### Issue: Graph doesn't start plotting
**Check:** `roastInProcess` is becoming `true` after command is sent
**Verify:** 0x1C handler (for profile) or 0x21 handler (for manual) sets roast state

### Issue: Y-coordinate doesn't match 440°F
**Check:** `GraphCalibration` min/max temperature values
**Verify:** Formula: `y = 500 - (440/500) * 400` should give correct coordinate

## 🎨 BeanTemperatureDisplay Reference

**File:** `ControlButtonsSection.swift`

The temperature displayed here is what gets captured:
```swift
struct BeanTemperatureDisplay: View {
    @ObservedObject var controlState: ControlState
    
    var body: some View {
        Text("\(controlState.beanTempValue)\(controlState.temperatureUnit)")
        // This value is captured in roastStartTemperature
    }
}
```

## 📚 Related Documentation
- `GRAPH_PLOTTING_STRATEGY.md` - Comprehensive implementation guide
- `GraphHandling_README.md` - Graph system overview
- `GraphHandling_SUMMARY.md` - Quick reference for graph features

---

**Last Updated:** Implementation complete for x=58, y≈440°F plotting strategy
**Status:** ✅ Ready for testing with both 0x15 and 0x1A commands
