//
//  DraggableSlider.swift
//  SR900_SlidingPanels
//
//  Created by Nisarg Mangukiya on 31/10/25.
//


//
//  Created by Nisarg Mangukiya on 28/10/25.
//

//
//  DraggableSlider.swift
//  UI Test
//
//  Created by Daniel Flohr on 10/26/25.
//


//
//  DraggableSlider.swift
//  UI Test
//
//  Custom draggable slider component
//

import SwiftUI

// CUSTOM DRAGGABLE SLIDER WITH SMOOTH MOUSE MOVEMENT
struct DraggableSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let label: String
    let icon: String
    var trackColor: Color = .black  // Default to black, can be customized
    var thumbColor: Color = .black  // Default to black, can be customized
    var textColor: Color = .white   // Default to white, can be customized
   // var iconOffset: CGFloat = 0
    
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 0) {
                Image(systemName: icon)
                    .font(.openSans(size: 16))
                    .frame(width: 24, alignment: .center)
                    .padding(.leading, 0)
                Text(label)
                    .font(.openSansBold(size: 14))
                    .padding(.leading, 4)
            }
            
            GeometryReader { geometry in
                let trackWidth = geometry.size.width - 24 // Subtract thumb width to keep it in bounds
                
                ZStack(alignment: .leading) {
                    // Background track
                    Capsule()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: trackWidth, height: 4)
                        .offset(x: 12) // Center track with thumb padding
                    
                    // Active track (filled portion)
                    Capsule()
                        .fill(trackColor)
                        .frame(width: max(0, thumbPosition(in: trackWidth)), height: 4)
                        .offset(x: 12) // Center track with thumb padding
                    
                    // Draggable thumb with number inside
                    ZStack {
                        Circle()
                            .fill(thumbColor)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Circle()
                                    .stroke(Color.black, lineWidth: 1.5)
                                    .frame(width: 24, height: 24)
                            )
                        
                        Text("\(Int(value))")
                            .font(.openSansBold(size: 12))
                            .foregroundColor(textColor)
                    }
                    .position(x: thumbPosition(in: trackWidth) + 12, y: 12) // Position thumb center properly
                    .allowsHitTesting(false) // Let parent handle all gestures
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            // Adjust for the 12pt padding on the left
                            updateValue(at: gesture.location.x - 12, in: trackWidth)
                        }
                )
                .onTapGesture { location in
                    // Adjust for the 12pt padding on the left
                    updateValue(at: location.x - 12, in: trackWidth)
                }
            }
            .frame(height: 24)
        }
    }
    
    private func thumbPosition(in width: CGFloat) -> CGFloat {
        let normalizedValue = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
        return normalizedValue * width
    }
    
    private func updateValue(at x: CGFloat, in width: CGFloat) {
        let normalizedX = max(0, min(x, width))
        let normalizedValue = normalizedX / width
        let newValue = normalizedValue * (range.upperBound - range.lowerBound) + range.lowerBound
        
        // Round to nearest step
        let steppedValue = round(newValue / step) * step
        value = min(max(steppedValue, range.lowerBound), range.upperBound)
    }
}
