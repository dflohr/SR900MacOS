# Quick Start Checklist

## Setup Steps (Do Once)

### ☐ Step 1: Understand Your Graph Image
- [ ] Open your background graph image in Preview/Photoshop
- [ ] Note the image dimensions (width × height)
- [ ] Identify where the graph area starts and ends
- [ ] Find the X-axis scale (time in minutes/seconds)
- [ ] Find the Y-axis scale (temperature range)

### ☐ Step 2: Measure Graph Coordinates
Use the `GraphCalibrationHelper` view:

```swift
// Add temporarily to your app
GraphCalibrationHelper(
    imageName: "your-graph-image-name",
    imageWidth: 700,
    imageHeight: 600
)
```

- [ ] Adjust `graphOriginX` until origin marker aligns with time=0
- [ ] Adjust `graphOriginY` until origin marker aligns with temp=0
- [ ] Adjust `graphWidth` until green rectangle spans full graph width
- [ ] Adjust `graphHeight` until green rectangle spans full graph height
- [ ] Set `minTemperature` to match lowest Y-axis value
- [ ] Set `maxTemperature` to match highest Y-axis value
- [ ] Set `minTime` to 0 (or graph's start time)
- [ ] Set `maxTime` to graph's end time in seconds (e.g., 900 for 15 min)
- [ ] Use test point slider to verify points land correctly
- [ ] Copy generated Swift code to clipboard

### ☐ Step 3: Update GraphCalibration
In `GraphHandling.swift`, replace the default calibration:

```swift
static let `default` = GraphCalibration(
    graphOriginX: YOUR_VALUE,    // From calibration helper
    graphOriginY: YOUR_VALUE,    // From calibration helper
    graphWidth: YOUR_VALUE,      // From calibration helper
    graphHeight: YOUR_VALUE,     // From calibration helper
    minTemperature: YOUR_VALUE,  // From calibration helper
    maxTemperature: YOUR_VALUE,  // From calibration helper
    minTime: YOUR_VALUE,         // From calibration helper
    maxTime: YOUR_VALUE          // From calibration helper
)
```

### ☐ Step 4: Integrate in Your Parent View
Update the view that contains `RoastGraphView`:

```swift
@ObservedObject var controlState: ControlState
@StateObject private var graphManager: GraphDataManager

init(controlState: ControlState) {
    self.controlState = controlState
    _graphManager = StateObject(
        wrappedValue: GraphDataManager(controlState: controlState)
    )
}

var body: some View {
    RoastGraphView(
        graphManager: graphManager,
        controlState: controlState,
        width: 700,
        imageName: "your-graph-background"
    )
}
```

## Testing Steps (Do Before First Real Roast)

### ☐ Test 1: Visual Alignment
- [ ] Start a test roast
- [ ] Wait 10-20 seconds
- [ ] Verify curve appears on graph
- [ ] Check curve starts at correct position
- [ ] Check curve follows graph grid lines
- [ ] Stop roast

### ☐ Test 2: Data Recording
- [ ] Start another test roast
- [ ] Let it run for 1 minute
- [ ] Verify temperature updates in real-time
- [ ] Verify elapsed time updates (00:00, 00:01, 00:02...)
- [ ] Verify RoR shows value after 30 seconds
- [ ] Stop roast
- [ ] Check console for "📈 Recorded:" messages

### ☐ Test 3: Event Marking
- [ ] Start test roast
- [ ] Click "FIRST CRACK" button
- [ ] Verify event marker appears on graph
- [ ] Type a note in text field
- [ ] Click "SAVE NOTE" button
- [ ] Verify note event appears on graph
- [ ] Stop roast

### ☐ Test 4: Data Export
- [ ] After test roast, call `graphManager.exportData()`
- [ ] Verify JSON is generated
- [ ] Save to file
- [ ] Open file and verify structure
- [ ] Check data points array has entries
- [ ] Check events array has your test events

## Daily Use Checklist

### Before Each Roast:
- [ ] Verify BLE connection is active
- [ ] Verify `controlState.beanTempValue` is updating
- [ ] Graph panel is visible

### During Roast:
- [ ] Watch curve being drawn in real-time
- [ ] Monitor RoR display
- [ ] Mark first crack when heard
- [ ] Add notes as needed (bean color, aroma, etc.)

### After Roast:
- [ ] Verify curve completed properly
- [ ] Export roast data if you want to keep it
- [ ] Save with descriptive filename

## Troubleshooting Checklist

### ☐ Issue: No curve appearing
- [ ] Check `controlState.roastInProcess` is true
- [ ] Check `controlState.beanTempValue` is updating
- [ ] Check `graphManager.isRecording` is true
- [ ] Check console for "📊 Starting graph data recording" message
- [ ] Verify background image is loading

### ☐ Issue: Curve is in wrong position
- [ ] Verify calibration values are correct
- [ ] Use GraphCalibrationHelper to re-measure
- [ ] Check that image dimensions match calibration
- [ ] Verify minTime/maxTime are in seconds
- [ ] Verify minTemp/maxTemp match graph scale

### ☐ Issue: Curve is stretched/compressed
- [ ] Check `maxTime` value (should be in seconds, not minutes)
- [ ] Check `maxTemperature` matches graph's highest temp
- [ ] Verify `graphWidth` matches actual graph width in pixels
- [ ] Verify `graphHeight` matches actual graph height in pixels

### ☐ Issue: RoR shows "--"
- [ ] Wait at least 2 seconds after roast starts
- [ ] Verify temperature is changing
- [ ] Check that at least 2 data points exist
- [ ] Wait 30 seconds for stable RoR calculation

### ☐ Issue: Buttons not working
- [ ] Verify roast is in process (buttons disabled when not roasting)
- [ ] Check note text field has text (save button disabled when empty)
- [ ] Verify `graphManager` is properly initialized

### ☐ Issue: Events not showing
- [ ] Check events array is populated: `graphManager.events`
- [ ] Verify temperature data exists at event time
- [ ] Check event position is within graph bounds
- [ ] Look for debug message: "📍 Event added:"

## Quick Reference: Console Messages

During operation, watch for these debug messages:

| Message | Means |
|---------|-------|
| `📊 Starting graph data recording` | Recording has started |
| `📈 Recorded: 00:10 - 250°F - RoR: 15.3°F/min` | Data point recorded (every 10 sec) |
| `📍 Event added: First Crack at 07:30` | Event marked successfully |
| `📊 Stopping graph data recording - captured X points` | Recording stopped |

## Performance Expectations

| Metric | Expected Value |
|--------|----------------|
| Recording interval | 1 point per second |
| RoR stabilization time | 30 seconds |
| Data points (15 min roast) | ~900 points |
| Memory usage (15 min roast) | ~90 KB |
| Export file size | 50-100 KB |
| UI lag/freezing | None (if any, reduce recording interval) |

## File Locations Reference

| File | Purpose |
|------|---------|
| `GraphHandling.swift` | Core implementation - edit for customization |
| `GraphHandling_README.md` | Full documentation - read for details |
| `GraphHandling_SUMMARY.md` | Technical overview - reference architecture |
| `GraphHandling+Examples.swift` | Code examples - copy patterns |
| `GraphCalibrationHelper.swift` | Calibration tool - use during setup |
| `RoastGraphView.swift` | Updated UI - already integrated |
| `GraphHandling_QUICKSTART.md` | This file - follow checklist |

## Support Resources

1. **Calibration issues**: Use `GraphCalibrationHelper.swift`
2. **Integration help**: See examples in `GraphHandling+Examples.swift`
3. **Feature questions**: Read `GraphHandling_README.md`
4. **Architecture info**: See `GraphHandling_SUMMARY.md`
5. **Debug info**: Check Xcode console for emoji messages (📊📈📍)

## Completion Checklist

- [ ] Calibration complete and tested
- [ ] Integration in parent view complete
- [ ] Test roast completed successfully
- [ ] Curve appears in correct position
- [ ] Events can be marked
- [ ] Data export works
- [ ] Ready for production use

---

## Common Values Reference

### Time Conversions:
- 5 minutes = 300 seconds
- 10 minutes = 600 seconds
- 15 minutes = 900 seconds
- 20 minutes = 1200 seconds
- 25 minutes = 1500 seconds
- 30 minutes = 1800 seconds

### Typical Graph Scales:
- Temperature: 0-500°F or 50-500°F
- Time: 0-15 minutes (900 seconds)
- RoR: -10 to +40 °F/minute

### Typical Image Sizes:
- Standard: 700×600 pixels
- High-res: 1400×1200 pixels
- Graph area: Usually 80-90% of image

---

**🎉 Once all setup steps are complete, you're ready to record your first roast!**
