# Graph Plotting Strategy Update

## Overview
Updated the graph plotting strategy to start at the correct coordinates when either `0x15_StartManualRoast` or `0x1A_StartProfileRoast` commands are sent.

## Key Requirements
- **Start Position**: x=58, y≈440°F (the actual temperature displayed in BeanTemperatureDisplay)
- **Trigger**: Graph plotting begins when either roast command is sent
- **Data Capture**: The initial temperature is captured at the moment the command is sent, not when roastInProcess becomes true

## Changes Made

### 1. ControlState.swift
**Added Property:**
```swift
@Published var roastStartTemperature: Int = 0
```
- Captures the bean temperature at the exact moment a roast command (0x15 or 0x1A) is sent
- This ensures the first plot point uses the correct temperature value (~440°F)
- Will be used by GraphDataManager to plot the initial point at x=58

### 2. 0x15_StartManualRoast.swift
**Added Temperature Capture:**
```swift
// Capture the current bean temperature for graph plotting start point
if let controlState = controlState {
    controlState.roastStartTemperature = controlState.beanTempValue
    print("📊 Captured roast start temperature: \(controlState.roastStartTemperature)°F (will plot at x=58, y≈440)")
}
```
- Captures temperature BEFORE sending the 0x15 command
- This is critical because the temperature might change by the time the roaster responds

### 3. 0x1A_StartProfileRoast.swift (NEW FILE)
**Created New Handler:**
- Implements the Start Profile Roast command (0x1A)
- Captures the start temperature before sending the command
- Includes proper error checking and state validation
- Waits for 0x1C acknowledgment before starting roast

**Key Features:**
- Captures `roastStartTemperature` before sending command
- Sets `shouldIgnoreNextStatus` flag to prevent race conditions
- Validates BLE connection and roast state
- Provides detailed logging for debugging

### 4. GraphHandling.swift
**Updated startRecording():**
- Added documentation explaining the x=58 plot position
- Added logging to show the captured start temperature
- The first data point is recorded at time=0, which will map to x=58 on the graph
- Temperature from `controlState.roastStartTemperature` will map to the correct y coordinate

**Important Note:**
The graph coordinate system is already configured correctly in `GraphCalibration.default`:
```swift
graphOriginX: 58,      // Left edge of graph area ✅
graphOriginY: 500,     // Bottom edge of graph area
graphWidth: 585,       // Width of plottable area
graphHeight: 400,      // Height of plottable area
minTemperature: 0,     // Bottom of graph
maxTemperature: 500,   // Top of graph (so 440°F will plot correctly)
minTime: 0,            // Left edge (start)
maxTime: 900           // Right edge (15 minutes = 900 seconds)
```

### 5. BLEManager.swift
**Updated startSavedProfileRoast():**
```swift
startProfileRoast.startSavedProfileRoast(controlState: controlState)
```
- Now passes `controlState` to the profile roast handler
- Enables temperature capture when profile roasts start

## How It Works

### Manual Roast (0x15) Flow:
1. User presses "Start Manual Roast" button
2. **BEFORE** sending command: `roastStartTemperature` is captured (e.g., 440°F)
3. 0x15 command is sent to roaster
4. Roaster responds with 0x21 status message (may be ignored if flag is set)
5. Eventually, roaster sets roast status which triggers `roastInProcess = true`
6. `GraphDataManager` starts recording with first point at (time=0, temp=440°F)
7. This maps to graph coordinates (x=58, y=440 on graph scale)

### Profile Roast (0x1A) Flow:
1. User presses "Start Profile Roast" button
2. **BEFORE** sending command: `roastStartTemperature` is captured (e.g., 440°F)
3. 0x1A command is sent to roaster
4. Roaster responds with 0x1C acknowledgment (byte[5]=0x01 means roast started)
5. 0x1C handler sets `roastInProcess = true` and `isProfileRoast = true`
6. `GraphDataManager` starts recording with first point at (time=0, temp=440°F)
7. This maps to graph coordinates (x=58, y=440 on graph scale)

## Graph Coordinate Mapping

The `GraphCalibration.pointToGraphCoordinates()` function handles the mapping:

**Time Mapping (X-axis):**
- time=0 seconds → x=58 (graph origin) ✅
- time=900 seconds (15 min) → x=643 (58 + 585)

**Temperature Mapping (Y-axis):**
- temp=0°F → y=500 (bottom of graph)
- temp=440°F → y≈148 (approximate position on graph) ✅
- temp=500°F → y=100 (top of graph)

The formula is:
```swift
let x = graphOriginX + (normalizedTime * graphWidth)
let y = graphOriginY - (normalizedTemp * graphHeight)
```

Where:
- `normalizedTime = (time - 0) / (900 - 0)` = time / 900
- `normalizedTemp = (temp - 0) / (500 - 0)` = temp / 500

## Testing Checklist

### Manual Roast Testing:
- [ ] Verify temperature displayed in BeanTemperatureDisplay before starting roast
- [ ] Start manual roast (0x15)
- [ ] Check console log for "Captured roast start temperature" message
- [ ] Verify graph starts plotting at x=58 with the captured temperature
- [ ] Verify subsequent points follow the roast curve

### Profile Roast Testing:
- [ ] Upload a profile to roaster (0x1B)
- [ ] Verify temperature displayed in BeanTemperatureDisplay
- [ ] Start profile roast (0x1A)
- [ ] Check console log for "Captured roast start temperature" message
- [ ] Wait for 0x1C acknowledgment
- [ ] Verify graph starts plotting at x=58 with the captured temperature
- [ ] Verify subsequent points follow the profile curve

### Edge Cases:
- [ ] Roast already in progress (should prevent new roast start)
- [ ] BLE disconnected during roast start
- [ ] Temperature reading unavailable (should use 0 or default)
- [ ] Multiple rapid start attempts

## Additional Notes

### Why Capture Temperature Before Sending Command?
The temperature reading might change between when the command is sent and when the roaster responds. By capturing it immediately before sending, we ensure the graph accurately reflects the starting conditions.

### Why Not Use First Status Message Temperature?
Status messages (0x21) come in asynchronously and might be delayed. The first status after command might have a different temperature than what was displayed when the user pressed start.

### Graph Manager Auto-Start
The `GraphDataManager` automatically starts recording when `roastInProcess` becomes `true`. No additional trigger is needed - the existing observers handle this correctly.

### ProfileStartAck (0x1C) Handler
The existing `Profile_Messages_0x1C.swift` already sets `roastInProcess = true` when byte[5] == 0x01, which will trigger graph recording automatically.

## Future Enhancements

1. **Pre-heat Phase Plotting**: Could add option to plot temperature before roast starts (negative time values)
2. **Multiple Roast Comparison**: Overlay multiple roast curves on the same graph
3. **Real-time RoR Display**: Show rate of rise indicator on the graph
4. **Temperature Prediction**: Use ML to predict final temperature based on current curve
5. **Export with Metadata**: Include roast start temperature in exported JSON

## Related Files
- `ControlState.swift` - State management
- `0x15_StartManualRoast.swift` - Manual roast command handler
- `0x1A_StartProfileRoast.swift` - Profile roast command handler (NEW)
- `GraphHandling.swift` - Graph data management and plotting
- `BLEManager.swift` - BLE communication and roast command dispatcher
- `Profile_Messages_0x1C.swift` - Profile roast acknowledgment handler
- `ControlButtonsSection.swift` - UI displaying bean temperature

## Contact & Support
If you encounter issues with the graph plotting:
1. Check console logs for temperature capture messages
2. Verify GraphCalibration values match your graph image
3. Test with both manual and profile roasts
4. Compare captured temperature with BeanTemperatureDisplay value
