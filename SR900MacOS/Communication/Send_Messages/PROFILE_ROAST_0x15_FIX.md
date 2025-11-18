# Fix: Prevent 0x15 Manual Roast During Profile Roast 0x1A

## Problem Summary
When a profile roast was started (0x1A), the roaster sent status updates (0x21) with fan and heat levels. These 0x21 messages updated the app's sliders, which triggered the slider's `didSet` observers, which then sent 0x15 manual roast commands back to the roaster. This created a conflict between profile roast mode and manual roast mode.

## Root Cause: Feedback Loop
```
0x1A Profile Start → Roaster
0x1C Ack ← Roaster (roastInProcess = true)
0x21 Status (fan=5, heat=3) ← Roaster
    ↓ Updates fanMotorLevel = 5
    ↓ Triggers didSet observer
    ↓ Calls handleSliderChange()
    ↓ Triggers onSliderUpdateDebounced
    ↓
0x15 Manual Roast (fan=5, heat=3) → Roaster ❌ WRONG!
    ↓ Conflicts with profile roast
0x21 Status ← Roaster
0x15 Manual Roast → Roaster ❌ INFINITE LOOP!
```

## Solution: Two-Layer Protection

### Layer 1: Distinguish Roaster Updates from User Input
**File: `ControlState.swift`**

Added `isUpdatingFromRoaster` flag that prevents 0x21 updates from triggering 0x15 messages:

```swift
var isUpdatingFromRoaster: Bool = false

@Published var fanMotorLevel: Double = 0 {
    didSet {
        if !isUpdatingFromRoaster {
            handleSliderChange(for: .fanMotor, oldValue: oldValue, newValue: fanMotorLevel)
        }
    }
}
```

### Layer 2: Block 0x15 During Profile Roasts
**File: `BLEManager.swift`**

Added check in slider callback:

```swift
if self.controlState.isProfileRoast {
    print("🚫 BLOCKED: Cannot send 0x15 manual roast command during profile roast")
    return
}
```

## Files Modified

### 1. ControlState.swift
- Added `isProfileRoast: Bool` - tracks profile vs manual roast
- Added `isUpdatingFromRoaster: Bool` - prevents feedback loop
- Modified `fanMotorLevel` didSet to check `isUpdatingFromRoaster`
- Modified `heatLevel` didSet to check `isUpdatingFromRoaster`

### 2. ProfileStartAck_0x1C.swift
- Sets `isProfileRoast = true` when profile roast acknowledged
- Resets `isProfileRoast = false` when roast ends

### 3. Roaster_Status_0x21.swift
- Wraps slider updates with `isUpdatingFromRoaster = true/false`:
```swift
controlState.isUpdatingFromRoaster = true
controlState.fanMotorLevel = Double(fanMotorLevel)
controlState.heatLevel = Double(heatLevel)
controlState.isUpdatingFromRoaster = false
```

### 4. BLEManager.swift
- Added profile roast check at start of `setupSliderDebounceCallback()`
- Blocks 0x15 if `isProfileRoast == true`

### 5. StartProfileRoast_0x1A.swift
- Added documentation about not sending 0x15 during profile roasts

## Testing Results

✅ **Profile Roast Flow (Fixed)**
```
App sends 0x1A
App receives 0x1C (isProfileRoast = true)
App receives 0x21 updates
  → Sliders update (isUpdatingFromRoaster = true)
  → didSet does NOT trigger handleSliderChange
  → No 0x15 sent ✓
Profile roast completes successfully
```

✅ **Manual Roast Flow (Still Works)**
```
User adjusts slider (isUpdatingFromRoaster = false)
  → didSet triggers handleSliderChange
  → Sends 0x15 with new values ✓
App receives 0x22 (isProfileRoast = false)
App receives 0x21 updates
  → Sliders update (isUpdatingFromRoaster = true)
  → No 0x15 sent ✓
User adjusts slider again
  → Sends new 0x15 ✓
```

## Key Insights

1. **Profile Roasts are Read-Only**: When a profile roast is active, the app cannot send control commands. It only displays what the roaster is doing according to its saved profile.

2. **The Flag Must Be Set Before Updating**: Always set `isUpdatingFromRoaster = true` BEFORE updating slider values, then reset it immediately after.

3. **Two Types of Slider Changes**:
   - **From Roaster (0x21)**: `isUpdatingFromRoaster = true` → DO NOT send 0x15
   - **From User**: `isUpdatingFromRoaster = false` → DO send 0x15 (if roast active)

4. **Profile vs Manual is Mutually Exclusive**: You cannot switch between profile and manual mode during an active roast.

## Debugging Tips

If 0x15 is still being sent during profile roasts, add these print statements:

```swift
// In ControlState didSet:
print("🔍 fanMotorLevel changed: \(oldValue) → \(newValue)")
print("   isUpdatingFromRoaster: \(isUpdatingFromRoaster)")
print("   Will trigger handleSliderChange: \(!isUpdatingFromRoaster)")

// In handleSliderChange:
print("🔍 handleSliderChange called for \(sliderType)")
print("   roastInProcess: \(roastInProcess)")
print("   isProfileRoast: \(isProfileRoast)")

// In BLEManager callback:
print("🔍 Slider callback triggered")
print("   isProfileRoast: \(controlState.isProfileRoast)")
print("   Will send 0x15: \(!controlState.isProfileRoast)")
```

## Conclusion

The fix prevents 0x15 manual roast commands from being sent in two situations:
1. When slider values are updated by incoming 0x21 status messages (feedback loop prevention)
2. When a profile roast is active (profile roast protection)

This ensures profile roasts run uninterrupted using the roaster's saved profile settings.
