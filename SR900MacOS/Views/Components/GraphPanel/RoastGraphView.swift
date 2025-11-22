//
//  RoastGraphView.swift
//  SR900MacOS
//
//  Created by Nisarg Mangukiya on 06/11/25.
//


//
//  RoastGraphView.swift
//  SR900MacOS
//
//  Roast Profile Graph View
//

import SwiftUI

struct RoastGraphView: View {
    @ObservedObject var graphManager: GraphDataManager
    @ObservedObject var controlState: ControlState
    
    @State private var roastNotes: String = ""
    
    let width: CGFloat
    let imageName: String?
    
    // Computed properties from graph manager and control state
    private var currentTemperature: Int {
        controlState.beanTempValue
    }
    
    private var elapsedTime: String {
        graphManager.getCurrentElapsedTime()
    }
    
    private var rateOfRise: String {
        graphManager.getFormattedRateOfRise()
    }
    
    private var fanLevel: Int {
        Int(controlState.fanMotorLevel)
    }
    
    private var heaterLevel: Int {
        Int(controlState.heatLevel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Graph Area with Image and Overlays
            ZStack(alignment: .top) {
                // Background Graph Image with Data Overlay
                if let imageName = imageName {
                    // Container to ensure perfect alignment
                    GeometryReader { geometry in
                        ZStack(alignment: .topLeading) {
                            // Background graph image - NO scaling, use actual size
                            Image(imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: width - 40, height: 600)
                            
                            // Overlay MUST match exact dimensions
                            GraphDataOverlay(graphManager: graphManager)
                                .frame(width: width - 40, height: 600)
                        }
                        // Debug border removed - calibration complete
                        // .border(Color.red, width: 1)
                    }
                    .frame(width: width - 40, height: 600)
                }
                
                // Header Section Overlaid on Image
                HStack(spacing: 15) {
                    Text("TEMPERATURE:")
                        .font(.openSansBold(size: 10))
                        .foregroundColor(.black)
                    
                    Text("\(currentTemperature)°F")
                        .font(.openSansBold(size: 10))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Text("ELAPSED TIME:")
                        .font(.openSansBold(size: 10))
                        .foregroundColor(.black)
                    
                    Text(elapsedTime)
                        .font(.openSansBold(size: 10))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Text("RoR:")
                        .font(.openSansBold(size: 10))
                        .foregroundColor(.black)
                    
                    Text(rateOfRise)
                        .font(.openSansBold(size: 10))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 70)
                .padding(.vertical, 110)
//                .background(Color.white.opacity(0.85))
//                .frame(maxWidth: .infinity)
//                .offset(y: 10)
                
                // Fan and Heater Level Indicators (Bottom Right)
//                VStack(alignment: .trailing, spacing: 5) {
//                    HStack(spacing: 8) {
//                        Text("FAN LEVEL")
//                            .font(.openSansBold(size: 10))
//                            .foregroundColor(.red)
//                        
//                        Text("\(fanLevel)")
//                            .font(.openSansBold(size: 10))
//                            .foregroundColor(.red)
//                            .frame(width: 15)
//                    }
//                    .padding(.horizontal, 8)
//                    .padding(.vertical, 4)
////                    .background(Color.white.opacity(0.9))
//                    
//                    HStack(spacing: 8) {
//                        Text("HEATER LEVEL")
//                            .font(.openSansBold(size: 10))
//                            .foregroundColor(.red)
//                        
//                        Text("\(heaterLevel)")
//                            .font(.openSansBold(size: 10))
//                            .foregroundColor(.red)
//                            .frame(width: 15)
//                    }
//                    .padding(.horizontal, 8)
//                    .padding(.vertical, 4)
//                    .background(Color.white.opacity(0.9))
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
//                .padding(.trailing, 50)
//                .padding(.bottom, 80)
            }
//            .frame(height: 450)
//            .padding(.top, 10)
            
            // Notes Section
            VStack(alignment: .leading, spacing: 8) {
                Text("NOTES ON THIS ROAST:")
                    .font(.openSansBold(size: 14))
                    .foregroundColor(.black)
                
                HStack(spacing: 10) {
                    // Notes Text Field
                    TextField("", text: $roastNotes)
                        .textFieldStyle(.plain)
                        .font(.openSans(size: 12))
                        .padding(8)
                        .background(Color.white)
                        .overlay(
                            Rectangle()
                                .stroke(Color.black, lineWidth: 2)
                        )
                    
                    // First Crack Button
                    Button(action: {
                        graphManager.markFirstCrack()
                    }) {
                        Text("FIRST\nCRACK")
                            .font(.openSansBold(size: 12))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .frame(width: 80, height: 35)
                            .background(Color(red: 0.85, green: 0.75, blue: 0.6))
                            .overlay(
                                Rectangle()
                                    .stroke(Color.black, lineWidth: 2)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(!controlState.roastInProcess)
                    
                    // Save Note Button
                    Button(action: {
                        if !roastNotes.isEmpty {
                            graphManager.addNote(roastNotes)
                            roastNotes = ""  // Clear after saving
                        }
                    }) {
                        Text("SAVE\nNOTE")
                            .font(.openSansBold(size: 12))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .frame(width: 80, height: 35)
                            .background(.white)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.black, lineWidth: 2)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(!controlState.roastInProcess || roastNotes.isEmpty)
                }
            }
            .padding(.horizontal, 40)
            .padding(.top, 15)
            .padding(.bottom, 20)
            
//            Spacer()
        }
//        .frame(width: width)
    }
}

// MARK: - Roast Graph Chart Component
//struct RoastGraphChart: View {
//    let fanLevel: Int
//    let heaterLevel: Int
//    
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack(alignment: .topLeading) {
                // Background colored zones
//                VStack(spacing: 0) {
                    // Development zone (beige)
//                    Rectangle()
//                        .fill(Color(red: 0.96, green: 0.94, blue: 0.88))
//                        .frame(height: geometry.size.height * 0.25)
                    
                    // Maillard zone (tan)
//                    Rectangle()
//                        .fill(Color(red: 0.93, green: 0.89, blue: 0.82))
//                        .frame(height: geometry.size.height * 0.25)
                    
                    // Drying zone (light green)
//                    Rectangle()
//                        .fill(Color(red: 0.88, green: 0.93, blue: 0.88))
//                        .frame(height: geometry.size.height * 0.35)
                    
                    // Pre-heat zone (light gray)
//                    Rectangle()
//                        .fill(Color(red: 0.95, green: 0.95, blue: 0.95))
//                        .frame(height: geometry.size.height * 0.15)
//                }
                
                // Zone labels
//                VStack(alignment: .leading, spacing: 0) {
//                    Text("DEVELOPMENT")
//                        .font(.openSansBold(size: 11))
//                        .foregroundColor(.gray)
//                        .frame(height: geometry.size.height * 0.25)
//                        .padding(.leading, 10)
//                    
//                    Text("MAILLARD")
//                        .font(.openSansBold(size: 11))
//                        .foregroundColor(.gray)
//                        .frame(height: geometry.size.height * 0.25)
//                        .padding(.leading, 10)
//                    
//                    Text("DRYING")
//                        .font(.openSansBold(size: 11))
//                        .foregroundColor(.gray)
//                        .frame(height: geometry.size.height * 0.35)
//                        .padding(.leading, 10)
//                    
//                    Text("PRE-HEAT")
//                        .font(.openSansBold(size: 11))
//                        .foregroundColor(.gray)
//                        .frame(height: geometry.size.height * 0.15)
//                        .padding(.leading, 10)
//                }
                
                // Grid lines
//                Canvas { context, size in
//                    let path = Path { path in
//                        // Horizontal lines
//                        for i in 0...10 {
//                            let y = CGFloat(i) * (size.height / 10)
//                            path.move(to: CGPoint(x: 0, y: y))
//                            path.addLine(to: CGPoint(x: size.width, y: y))
//                        }
//                        
//                        // Vertical lines
//                        for i in 0...15 {
//                            let x = CGFloat(i) * (size.width / 15)
//                            path.move(to: CGPoint(x: x, y: 0))
//                            path.addLine(to: CGPoint(x: x, y: size.height))
//                        }
//                    }
//                    
//                    context.stroke(path, with: .color(.gray.opacity(0.3)), lineWidth: 1)
//                }
                
                // Y-axis labels (temperature)
//                VStack(alignment: .leading, spacing: 0) {
//                    ForEach([500, 450, 400, 350, 300, 250, 200, 150, 100, 50, 0], id: \.self) { temp in
//                        Text("\(temp)")
//                            .font(.system(size: 9))
//                            .foregroundColor(.black)
//                            .frame(height: geometry.size.height / 10, alignment: .top)
//                    }
//                }
//                .padding(.leading, 5)
                
                // X-axis labels (time)
//                HStack(spacing: 0) {
//                    ForEach(0...15, id: \.self) { minute in
//                        Text("\(minute)")
//                            .font(.system(size: 9))
//                            .foregroundColor(.black)
//                            .frame(width: geometry.size.width / 15, alignment: .leading)
//                    }
//                }
//                .offset(y: geometry.size.height + 5)
//                .padding(.leading,40)
                
                // Roast curve (example curve - replace with actual data)
//                Path { path in
//                    let points: [(x: Double, y: Double)] = [
//                        (0, 0.95),
//                        (1, 0.85),
//                        (2, 0.75),
//                        (3, 0.65),
//                        (4, 0.55),
//                        (5, 0.48),
//                        (6, 0.42),
//                        (7, 0.38),
//                        (8, 0.35),
//                        (9, 0.32),
//                        (10, 0.30),
//                        (11, 0.28),
//                        (12, 0.26),
//                        (13, 0.24),
//                        (14, 0.22),
//                        (15, 0.20)
//                    ]
//                    
//                    path.move(to: CGPoint(
//                        x: points[0].x * (geometry.size.width / 15) + 40,
//                        y: points[0].y * geometry.size.height
//                    ))
//                    
//                    for point in points.dropFirst() {
//                        path.addLine(to: CGPoint(
//                            x: point.x * (geometry.size.width / 15) + 40,
//                            y: point.y * geometry.size.height
//                        ))
//                    }
//                }
//                .stroke(Color.black, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                
                // Target curve (dashed line)
//                Path { path in
//                    let points: [(x: Double, y: Double)] = [
//                        (0, 0.95),
//                        (1, 0.82),
//                        (2, 0.70),
//                        (3, 0.60),
//                        (4, 0.52),
//                        (5, 0.46),
//                        (6, 0.41),
//                        (7, 0.37),
//                        (8, 0.34),
//                        (9, 0.31),
//                        (10, 0.29),
//                        (11, 0.27),
//                        (12, 0.25),
//                        (13, 0.23),
//                        (14, 0.21),
//                        (15, 0.19)
//                    ]
//                    
//                    path.move(to: CGPoint(
//                        x: points[0].x * (geometry.size.width / 15) + 40,
//                        y: points[0].y * geometry.size.height
//                    ))
//                    
//                    for point in points.dropFirst() {
//                        path.addLine(to: CGPoint(
//                            x: point.x * (geometry.size.width / 15) + 40,
//                            y: point.y * geometry.size.height
//                        ))
//                    }
//                }
//                .stroke(Color.gray, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round, dash: [5, 3]))
                
                // Y-axis label "BEAN TEMP (°F)"
//                Text("BEAN TEMP (°F)")
//                    .font(.system(size: 8, weight: .bold))
//                    .foregroundColor(.black)
//                    .rotationEffect(.degrees(-90))
//                    .offset(x: geometry.size.width + 10, y: geometry.size.height / 2)
//            }
//            .overlay(
//                Rectangle()
//                    .stroke(Color.black, lineWidth: 2)
                    
//            )
//        }
//        .padding(.top, 100)
//    }
//}

// MARK: - Update FramedRectangle to use RoastGraphView
extension FramedRectangle {
    // Add this inside the body, for number == "2"
    /*
    if number == "2" {
        RoastGraphView(width: width)
            .offset(y: 10)
    }
    */
}
