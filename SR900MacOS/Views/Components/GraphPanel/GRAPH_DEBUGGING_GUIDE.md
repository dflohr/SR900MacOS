# Graph Plotting Debugging Guide

## Issue Summary

### Problem 1: Wrong Temperature (~18°F instead of ~76°F)
**Symptom**: First plotted point shows temperature around 18°F when actual temperature is around 76°F

**Cause**: Temperature byte parsing in `Roaster_Status_0x21.swift` may be:
- Using wrong byte positions (currently bytes[15-16])
- Wrong endianness (Big-Endian vs Little-Endian)
- Wrong scaling (might need to divide by 10)
- In Celsius (might need conversion to Fahrenheit)

**Solution Applied**: Added comprehensive debug logging to show all parsing options.

### Problem 2: Time Offset (~30 seconds instead of 0)
**Symptom**: First plotted point appears at time ≈ 30 seconds instead of time = 0

**Cause**: Recording starts when 0x22 message is received, which happens 30+ seconds after user clicks START:
1. User clicks START button
2. App sends 0x15 command to roaster
3. Roaster begins heating (~30 second delay)
4. **Roaster sends 0x22 acknowledgment** ← Recording starts here
5. Graph starts plotting

**Solution Applied**: Added immediate `recordDataPoint()` call when recording starts to capture the first point at time=0 (relative to when recording begins).

---

## Debugging Steps

### Step 1: Identify Correct Temperature Parsing

1. **Run the app** and start a roast
2. **Watch the Xcode console** for temperature debug output:
   ```
   🌡️ Temperature Debug - Bytes[15]=XX Bytes[16]=YY:
      Option 1 (Big-Endian): 18°F        ← Currently used
      Option 2 (Little-Endian): 4864°F
      Option 3 (Celsius→F): 64°F
      Option 4 (÷10): 1°F
   ```
3. **Compare** the displayed options with your actual roaster temperature
4. **Identify** which option matches reality

### Step 2: Update Temperature Parsing

Once you know which option is correct, update `Roaster_Status_0x21.swift`:

#### If Option 1 is correct (Big-Endian):
```swift
rawTemp = temp_option1  // Already set, no change needed
```

#### If Option 2 is correct (Little-Endian):
```swift
rawTemp = temp_option2
```

#### If Option 3 is correct (Celsius conversion):
```swift
rawTemp = temp_option3_fahrenheit
```

#### If Option 4 is correct (Scaled value):
```swift
rawTemp = temp_option4_div10
```

### Step 3: Address Time Offset

The current fix records a point immediately when recording starts, but there's still a **~30 second delay** between clicking START and receiving the 0x22 acknowledgment.

#### Option A: Accept the delay
- The graph will show "Roast time" starting from when 0x22 is received
- This is simpler but means the graph doesn't show the first 30 seconds of heating

#### Option B: Backdate the start time
- Estimate the delay (e.g., 30 seconds) and subtract it from the start time
- More complex but gives a complete picture

**To implement Option B**, modify `GraphHandling.swift`:

```swift
func startRecording() {
    // ... existing code ...
    
    // Backdate start time by estimated delay
    let estimatedDelay: TimeInterval = 30  // Adjust based on observation
    roastStartTime = Date().addingTimeInterval(-estimatedDelay)
    
    // ... rest of function ...
}
```

---

## Expected Results After Fixes

### Temperature Fix:
✅ First plotted point should show actual temperature (e.g., 76°F)
✅ Temperature curve should track with roaster display

### Time Fix:
✅ First data point recorded immediately (at relative time=0)
✅ If backdated: Graph starts from actual roast start
✅ If not backdated: Graph starts from 0x22 acknowledgment

---

## Testing Checklist

### Temperature Test:
- [ ] Start a roast
- [ ] Note the actual roaster temperature (e.g., 76°F)
- [ ] Check Xcode console for temperature debug output
- [ ] Identify which parsing option matches reality
- [ ] Update code to use correct option
- [ ] Restart and verify temperature is correct

### Time Test:
- [ ] Start a roast
- [ ] Note when you click START button (check system clock)
- [ ] Note when graph starts plotting (check elapsed time display)
- [ ] Calculate delay between START and first plot
- [ ] Decide: Accept delay or backdate start time?
- [ ] If backdating: Update `startRecording()` with measured delay

### Graph Calibration Test:
- [ ] First point should appear at (x=58, y=calculated-from-temp)
- [ ] For 76°F: y = 500 - (76/500) * 400 = 439.2 ≈ 440 ✅
- [ ] Subsequent points should follow correct path
- [ ] Temperature axis should align with graph background

---

## Console Messages to Watch

```
📊 Starting graph data recording
📊 First data point recorded immediately at start

🌡️ Temperature Debug - Bytes[15]=XX Bytes[16]=YY:
   Option 1 (Big-Endian): 18°F
   Option 2 (Little-Endian): 4864°F
   Option 3 (Celsius→F): 64°F
   Option 4 (÷10): 1°F

📈 Recorded: 00:00 - 76°F - RoR: -- °F/min
📈 Recorded: 00:10 - 82°F - RoR: -- °F/min
```

---

## Quick Reference: Temperature Parsing Formula

Given bytes[15] and bytes[16], the temperature is calculated as:

| Method | Formula | Use Case |
|--------|---------|----------|
| Big-Endian | `(bytes[15] << 8) \| bytes[16]` | Most common for network data |
| Little-Endian | `(bytes[16] << 8) \| bytes[15]` | Used by some devices |
| Celsius | `((value * 9) / 5) + 32` | If roaster reports in Celsius |
| Scaled | `value / 10` | If value is in tenths (e.g., 760 = 76.0°F) |

---

## Files Modified

1. **GraphHandling.swift**
   - Added immediate `recordDataPoint()` call in `startRecording()`
   - First point now recorded at time ≈ 0

2. **Roaster_Status_0x21.swift**
   - Added comprehensive temperature debug logging
   - Shows all 4 parsing options in console

---

## Next Steps

1. Run a test roast
2. Check console output for temperature options
3. Update temperature parsing to use correct option
4. Decide on time offset handling (accept delay vs backdate)
5. Test again and verify both temperature and time are correct
