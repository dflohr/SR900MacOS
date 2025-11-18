# Profile Roast vs Manual Roast - Message Flow Fix

## Issue
After sending **0x1A Start Profile Roast** message and receiving **0x1C Profile Start Acknowledged**, a **0x15 Start Manual Roast** message was being sent, which interferes with the profile roast process.

## Root Cause
The roaster has two different roasting modes:
1. **Profile Roast** (0x1A → 0x1C) - Uses a saved profile from the roaster
2. **Manual Roast** (0x15 → 0x22) - Uses manual control settings

When a profile roast is acknowledged (0x1C), the system should NOT send 0x15 because the roast is already started via the profile.

## Solution Implemented

### 1. Added Profile Roast Tracking
**File: `ControlState.swift`**
- Added `@Published var isProfileRoast: Bool = false` to track if the current roast is a profile roast

### 2. Updated Profile Start Acknowledgment Handler
**File: `ProfileStartAck_0x1C.swift`**
- When 0x1C is received with `bytes[5] == 0x01`, set both:
  - `roastInProcess = true`
  - `isProfileRoast = true`
- Added console warning: "DO NOT send 0x15 Start Manual Roast - profile roast is already started"

### 3. Prevention Guard Needed
**Action Required:** Find where the 0x15 message is being sent and add this guard:

```swift
// Before sending 0x15 Start Manual Roast message
guard !controlState.isProfileRoast else {
    print("⚠️ Cannot start manual roast - profile roast is already in progress")
    print("⚠️ Profile roasts use 0x1A, not 0x15")
    return
}

guard controlState.roastInProcess == false else {
    print("⚠️ Cannot start manual roast - roast already in progress")
    return
}
```

### 4. Updated Documentation
**File: `StartProfileRoast_0x1A.swift`**
- Added documentation explaining that 0x15 should NOT be sent after receiving 0x1C

## Message Flow Diagrams

### Correct Profile Roast Flow:
```
App → 0x1A Start Profile Roast → Roaster
App ← 0x1C Profile Start Acknowledged ← Roaster
        ↓ (sets isProfileRoast = true, roastInProcess = true)
        ↓
    [DO NOT send 0x15 here!]
        ↓
    Profile roast continues...
```

### Correct Manual Roast Flow:
```
App → 0x15 Start Manual Roast → Roaster
App ← 0x22 Roast Start Acknowledged ← Roaster
        ↓ (sets isProfileRoast = false, roastInProcess = true)
        ↓
    Manual roast continues...
```

## Files Modified
1. `ControlState.swift` - Added `isProfileRoast` flag
2. `ProfileStartAck_0x1C.swift` - Set flag and added warnings
3. `StartProfileRoast_0x1A.swift` - Added documentation
4. `PROFILE_ROAST_FIX_README.md` - This documentation file

## Next Steps
1. **Find the 0x15 sender:** Search your codebase for where `0x15` or "Start Manual Roast" message is constructed and sent
2. **Add guard clause:** Add the prevention guard shown above before sending 0x15
3. **Test:** Verify that:
   - Profile roasts work without sending 0x15
   - Manual roasts still work correctly
   - Cannot start manual roast during profile roast
   - Cannot start profile roast during manual roast

## Search Commands to Find 0x15 Sender
Look for files containing:
- `0x15`
- `TX_B[messageProtocol.d_byte] = 0x15`
- Files that inherit from or use `MessageProtocol`
- Button actions that start roasts
- Any file with "StartManualRoast" or similar naming

Common locations to check:
- UI button action handlers
- Roast control classes
- Message protocol handlers
- Timer callbacks that might auto-start roasts
