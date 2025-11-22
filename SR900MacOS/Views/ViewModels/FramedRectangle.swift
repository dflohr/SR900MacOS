//
//  FramedRectangle.swift
//  SR900MacOS
//
//  Created by Nisarg Mangukiya on 01/11/25.
//


import SwiftUI

struct FramedRectangle: View {
    let number: String
    let width: CGFloat
    let height: CGFloat = 768
    let imageName: String?
    let onGraphButtonPressed: (() -> Void)?
    let onProfilesButtonPressed: (() -> Void)?
    let onSettingsButtonPressed: (() -> Void)?
    
    @Binding var rectangle2Extended: Bool
    @Binding var rectangle3Extended: Bool
    @Binding var rectangle4Extended: Bool
    var voltageSupply: Binding<String>?
    
    // Graph handling system (optional - only needed for number == "2")
    var graphManager: GraphDataManager?
    var controlState: ControlState?
    
    var body: some View {
        ZStack {
            FramedRectangleBackground(width: width, height: height)
            FramedRectangleBorders(width: width, height: height, topBorderHeight: number == "1" ? 40 : 60)
            FramedRectangleContent(
                number: number,
                width: width,
                height: height,
                imageName: imageName,
                graphManager: graphManager,
                controlState: controlState
            )
            
            if number == "1" {
                MainControlInterface(
                    width: width,
                    onGraphButtonPressed: onGraphButtonPressed,
                    onProfilesButtonPressed: onProfilesButtonPressed,
                    onSettingsButtonPressed: onSettingsButtonPressed,
                    rectangle2Extended: $rectangle2Extended,
                    rectangle3Extended: $rectangle3Extended,
                    rectangle4Extended: $rectangle4Extended
                )
            }
            
            
            if number == "4", let voltageBinding = voltageSupply {
                SettingsPanelView(
                    rectangle2Extended: $rectangle2Extended,
                    rectangle3Extended: $rectangle3Extended,
                    rectangle4Extended: $rectangle4Extended,
                    voltageSupply: voltageBinding,
                    onGraphButtonPressed: onGraphButtonPressed,
                    onProfilesButtonPressed: onProfilesButtonPressed,
                    onSettingsButtonPressed: onSettingsButtonPressed,
                    width: width
                )
            }
            
            
            if number == "3", let voltageBinding = voltageSupply {
                ProfilePanelView(
                    rectangle2Extended: $rectangle2Extended,
                    rectangle3Extended: $rectangle3Extended,
                    rectangle4Extended: $rectangle4Extended,
                    voltageSupply: voltageBinding,
                    onGraphButtonPressed: onGraphButtonPressed,
                    onProfilesButtonPressed: onProfilesButtonPressed,
                    onSettingsButtonPressed: onSettingsButtonPressed,
                    width: width
                )
            }
            
        }
        .frame(width: width, height: height)
    }
}

// MARK: - Background Component
struct FramedRectangleBackground: View {
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        Rectangle()
            .fill(Color(red: 0.93, green: 0.93, blue: 0.93))
            .frame(width: width, height: height)
    }
}

// MARK: - Borders Component
struct FramedRectangleBorders: View {
    let width: CGFloat
    let height: CGFloat
    let topBorderHeight: CGFloat
    
    var body: some View {
        Group {
            // Top border
            Rectangle()
                .fill(Color.black)
                .frame(width: width, height: topBorderHeight)
                .offset(y: -(height/2 - topBorderHeight/2))
            
            // Bottom border
            Rectangle()
                .fill(Color.black)
                .frame(width: width, height: 20)
                .offset(y: 374)
            
            // Left border
            Rectangle()
                .fill(Color.black)
                .frame(width: 20, height: height)
                .offset(x: -(width/2 - 10))
            
            // Right border
            Rectangle()
                .fill(Color.black)
                .frame(width: 20, height: height)
                .offset(x: (width/2 - 10))
        }
    }
}

// MARK: - Content Component
struct FramedRectangleContent: View {
    let number: String
    let width: CGFloat
    let height: CGFloat
    let imageName: String?
    
    // Graph handling system
    var graphManager: GraphDataManager?
    var controlState: ControlState?
    
    var body: some View {
        Group {
//            if let imageName = imageName {
//                Image(imageName)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: width - 40, height: height - 60)
//                    .offset(y: -10)
//            }
            
            if number == "2" {
                Text("ROAST PROFILE GRAPH")
                    .font(.custom("OpenSans-Bold", size: 24))
                    .foregroundColor(.black)
                    .background(Color(red: 0.93, green: 0.93, blue: 0.93).opacity(0.9))
                    .padding(.horizontal, 0)
                    .padding(.vertical, 5)
                    .offset(y: -300)  // ✅ Move title up more
                
                // ✅ Add the graph view
                if let graphManager = graphManager, let controlState = controlState {
                    RoastGraphView(
                        graphManager: graphManager,
                        controlState: controlState,
                        width: width,
                        imageName: imageName
                    )
                    .offset(y: 20)
                } else {
                    // Fallback if graph system not initialized
                    Text("Graph system not initialized")
                        .font(.custom("OpenSans-Regular", size: 14))
                        .foregroundColor(.red)
                        .offset(y: 20)
                }
            }
            
//            if number == "2" {
//                Text("ROAST GRAPH")
//                    .font(.custom("OpenSans-Bold", size: 24))
//                    .foregroundColor(.black)
//                    .background(Color(red: 0.93, green: 0.93, blue: 0.93).opacity(0.9))
//                    .padding(.horizontal, 10)
//                    .padding(.vertical, 5)
//                    .offset(y: -244)
//            } else {
//                Text(number)
//                    .font(.custom("OpenSans-Bold", size: 48))
//                    .foregroundColor(.black)
//            }
            if number == "3" {
                Text("ROAST PROFILE")
                    .font(.custom("OpenSans-Bold", size: 24))
                    .foregroundColor(.black)
                    .background(Color(red: 0.93, green: 0.93, blue: 0.93).opacity(0.9))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .offset(y: -300)
            }
            if number == "4" {
                Text("SETTINGS")
                    .font(.custom("OpenSans-Bold", size: 24))
                    .foregroundColor(.black)
                    .background(Color(red: 0.93, green: 0.93, blue: 0.93).opacity(0.9))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .offset(y: -300)
            }
        }
    }
}

// MARK: - Previews
#Preview("Rectangle 1 - Main Control Interface") {
    FramedRectangle(
        number: "1",
        width: 600,
        imageName: nil,
        onGraphButtonPressed: { print("Graph pressed") },
        onProfilesButtonPressed: { print("Profiles pressed") },
        onSettingsButtonPressed: { print("Settings pressed") },
        rectangle2Extended: .constant(false),
        rectangle3Extended: .constant(false),
        rectangle4Extended: .constant(false),
        voltageSupply: nil
    )
}

#Preview("Rectangle 2 - Graph") {
    @Previewable @State var controlState = ControlState()
    @Previewable @State var graphManager: GraphDataManager? = nil
    
    FramedRectangle(
        number: "2",
        width: 607,
        imageName: nil,
        onGraphButtonPressed: nil,
        onProfilesButtonPressed: nil,
        onSettingsButtonPressed: nil,
        rectangle2Extended: .constant(false),
        rectangle3Extended: .constant(false),
        rectangle4Extended: .constant(false),
        voltageSupply: nil,
        graphManager: graphManager,
        controlState: controlState
    )
    .onAppear {
        if graphManager == nil {
            graphManager = GraphDataManager(controlState: controlState)
        }
    }
}

#Preview("Rectangle 3 - Profile Panel") {
    @Previewable @State var voltage = "AVERAGE"
    FramedRectangle(
        number: "3",
        width: 410,
        imageName: nil,
        onGraphButtonPressed: nil,
        onProfilesButtonPressed: nil,
        onSettingsButtonPressed: nil,
        rectangle2Extended: .constant(false),
        rectangle3Extended: .constant(false),
        rectangle4Extended: .constant(false),
        voltageSupply: $voltage
    )
}

#Preview("Rectangle 4 - Settings Panel") {
    @Previewable @State var voltage = "AVERAGE"
    FramedRectangle(
        number: "4",
        width: 410,
        imageName: nil,
        onGraphButtonPressed: nil,
        onProfilesButtonPressed: nil,
        onSettingsButtonPressed: nil,
        rectangle2Extended: .constant(false),
        rectangle3Extended: .constant(false),
        rectangle4Extended: .constant(false),
        voltageSupply: $voltage
    )
}
