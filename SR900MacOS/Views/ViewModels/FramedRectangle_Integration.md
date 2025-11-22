# Integrating Graph System with FramedRectangle

## Problem Solved
The `RoastGraphView` now requires `graphManager` and `controlState` parameters, but `FramedRectangle` wasn't passing them through.

## Changes Made to FramedRectangle.swift

### 1. Added Optional Parameters
```swift
struct FramedRectangle: View {
    // ... existing parameters ...
    
    // NEW: Graph handling system (optional - only needed for number == "2")
    var graphManager: GraphDataManager?
    var controlState: ControlState?
}
```

### 2. Updated FramedRectangleContent
```swift
struct FramedRectangleContent: View {
    // ... existing parameters ...
    
    // NEW: Graph handling system
    var graphManager: GraphDataManager?
    var controlState: ControlState?
}
```

### 3. Updated RoastGraphView Call
Now properly passes the required parameters with safety check:
```swift
if let graphManager = graphManager, let controlState = controlState {
    RoastGraphView(
        graphManager: graphManager,
        controlState: controlState,
        width: width,
        imageName: imageName
    )
}
```

## How to Use in Your Parent View

### Option 1: If you have a parent view that creates FramedRectangle

Find where you create `FramedRectangle` with `number: "2"` and update it:

```swift
// In your parent view (e.g., SlidingPanelsContainer or main view)

struct YourParentView: View {
    @ObservedObject var controlState: ControlState
    @StateObject private var graphManager: GraphDataManager
    
    init(controlState: ControlState) {
        self.controlState = controlState
        _graphManager = StateObject(
            wrappedValue: GraphDataManager(controlState: controlState)
        )
    }
    
    var body: some View {
        // When creating the graph rectangle (number "2"):
        FramedRectangle(
            number: "2",
            width: 607,
            imageName: "your-graph-background-image",
            onGraphButtonPressed: { /* ... */ },
            onProfilesButtonPressed: { /* ... */ },
            onSettingsButtonPressed: { /* ... */ },
            rectangle2Extended: $rectangle2Extended,
            rectangle3Extended: $rectangle3Extended,
            rectangle4Extended: $rectangle4Extended,
            voltageSupply: nil,
            graphManager: graphManager,    // ✅ Pass graphManager
            controlState: controlState      // ✅ Pass controlState
        )
        
        // Other rectangles don't need these parameters:
        FramedRectangle(
            number: "1",
            width: 600,
            // ... other parameters ...
            graphManager: nil,  // Not needed for rectangle "1"
            controlState: nil   // Not needed for rectangle "1"
        )
    }
}
```

### Option 2: Quick Fix - Let me find your parent view

Let me search for where FramedRectangle is being used:

```swift
// Search for files that create FramedRectangle instances
// Look for: FramedRectangle(number: "2"
```

## Steps to Complete Integration

### Step 1: Find Your Parent View
Look for the file that creates `FramedRectangle` instances. It might be:
- `SlidingPanelsContainer.swift`
- `ContentView.swift`
- `MainView.swift`
- Or similar main view file

### Step 2: Add GraphDataManager
In that parent view, add:

```swift
@StateObject private var graphManager: GraphDataManager

init(controlState: ControlState) {
    self.controlState = controlState
    _graphManager = StateObject(
        wrappedValue: GraphDataManager(controlState: controlState)
    )
}
```

### Step 3: Pass Parameters
When creating the rectangle with `number: "2"`, add:
```swift
graphManager: graphManager,
controlState: controlState
```

### Step 4: For Other Rectangles
For rectangles 1, 3, and 4, you can pass `nil`:
```swift
graphManager: nil,
controlState: nil
```

Or omit them entirely (they're optional parameters).

## Example: Complete Integration

Here's a complete example of what your parent view should look like:

```swift
import SwiftUI

struct MainRoasterView: View {
    @ObservedObject var controlState: ControlState
    @StateObject private var graphManager: GraphDataManager
    
    @State private var rectangle2Extended = false
    @State private var rectangle3Extended = false
    @State private var rectangle4Extended = false
    @State private var voltageSupply = "AVERAGE"
    
    init(controlState: ControlState) {
        self.controlState = controlState
        _graphManager = StateObject(
            wrappedValue: GraphDataManager(controlState: controlState)
        )
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Rectangle 1 - Main Controls
            FramedRectangle(
                number: "1",
                width: 600,
                imageName: nil,
                onGraphButtonPressed: { toggleGraphPanel() },
                onProfilesButtonPressed: { toggleProfilesPanel() },
                onSettingsButtonPressed: { toggleSettingsPanel() },
                rectangle2Extended: $rectangle2Extended,
                rectangle3Extended: $rectangle3Extended,
                rectangle4Extended: $rectangle4Extended,
                voltageSupply: nil
            )
            
            // Rectangle 2 - Graph (NEEDS graphManager & controlState)
            if rectangle2Extended {
                FramedRectangle(
                    number: "2",
                    width: 607,
                    imageName: "graph-background",
                    onGraphButtonPressed: nil,
                    onProfilesButtonPressed: nil,
                    onSettingsButtonPressed: nil,
                    rectangle2Extended: $rectangle2Extended,
                    rectangle3Extended: $rectangle3Extended,
                    rectangle4Extended: $rectangle4Extended,
                    voltageSupply: nil,
                    graphManager: graphManager,     // ✅ Required
                    controlState: controlState      // ✅ Required
                )
            }
            
            // Rectangle 3 - Profiles
            if rectangle3Extended {
                FramedRectangle(
                    number: "3",
                    width: 410,
                    imageName: nil,
                    onGraphButtonPressed: { toggleGraphPanel() },
                    onProfilesButtonPressed: { toggleProfilesPanel() },
                    onSettingsButtonPressed: { toggleSettingsPanel() },
                    rectangle2Extended: $rectangle2Extended,
                    rectangle3Extended: $rectangle3Extended,
                    rectangle4Extended: $rectangle4Extended,
                    voltageSupply: $voltageSupply
                )
            }
            
            // Rectangle 4 - Settings
            if rectangle4Extended {
                FramedRectangle(
                    number: "4",
                    width: 410,
                    imageName: nil,
                    onGraphButtonPressed: { toggleGraphPanel() },
                    onProfilesButtonPressed: { toggleProfilesPanel() },
                    onSettingsButtonPressed: { toggleSettingsPanel() },
                    rectangle2Extended: $rectangle2Extended,
                    rectangle3Extended: $rectangle3Extended,
                    rectangle4Extended: $rectangle4Extended,
                    voltageSupply: $voltageSupply
                )
            }
        }
    }
    
    private func toggleGraphPanel() {
        rectangle2Extended.toggle()
    }
    
    private func toggleProfilesPanel() {
        rectangle3Extended.toggle()
    }
    
    private func toggleSettingsPanel() {
        rectangle4Extended.toggle()
    }
}
```

## Troubleshooting

### Error: "Missing arguments for parameters"
**Solution**: Make sure you're passing both `graphManager` and `controlState` when creating a `FramedRectangle` with `number: "2"`

### Error: "Cannot find 'GraphDataManager' in scope"
**Solution**: Make sure `GraphHandling.swift` is included in your Xcode project target

### Error: "Cannot find 'ControlState' in scope"
**Solution**: Make sure `ControlState.swift` is included in your project and imported

### Graph shows "Graph system not initialized"
**Solution**: This means `graphManager` or `controlState` is `nil`. Check that you're passing them correctly.

### Preview error in FramedRectangle
**Solution**: The preview for Rectangle 2 now includes sample `controlState` and `graphManager`. Other previews can pass `nil` for these parameters.

## Next Steps

1. ✅ Find the parent view that creates `FramedRectangle` instances
2. ✅ Add `@StateObject private var graphManager: GraphDataManager`
3. ✅ Initialize it in `init(controlState:)`
4. ✅ Pass it to `FramedRectangle` with `number: "2"`
5. ✅ Test that the graph view loads without errors
6. ✅ Follow the calibration steps in `GraphHandling_QUICKSTART.md`

## Summary

The changes make `FramedRectangle` more flexible:
- **Rectangles 1, 3, 4**: Don't need graph system (pass `nil` or omit)
- **Rectangle 2**: Needs graph system to display live roast data
- **Backward compatible**: Won't break existing code that doesn't pass these parameters
- **Type-safe**: Uses optionals to prevent crashes if parameters are missing
