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
    
    var body: some View {
        ZStack {
            FramedRectangleBackground(width: width, height: height)
            FramedRectangleBorders(width: width, height: height)
            FramedRectangleContent(
                number: number,
                width: width,
                height: height,
                imageName: imageName
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
            
            
            if number == "4" {
                SettingsPanelView(
                    rectangle2Extended: $rectangle2Extended,
                    rectangle3Extended: $rectangle3Extended,
                    rectangle4Extended: $rectangle4Extended,
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
    
    var body: some View {
        Group {
            // Top border
            Rectangle()
                .fill(Color.black)
                .frame(width: width, height: 80)
                .offset(y: -364)
            
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
    
    var body: some View {
        Group {
            if let imageName = imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: width - 40, height: height - 60)
                    .offset(y: -10)
            }
            
            if number == "2" {
                Text("ROAST GRAPH")
                    .font(.custom("OpenSans-Bold", size: 24))
                    .foregroundColor(.black)
                    .background(Color(red: 0.93, green: 0.93, blue: 0.93).opacity(0.9))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .offset(y: -244)
//            } else {
//                Text(number)
//                    .font(.custom("OpenSans-Bold", size: 48))
//                    .foregroundColor(.black)
            }
            if number == "3" {
                Text("PROFILE")
                    .font(.custom("OpenSans-Bold", size: 24))
                    .foregroundColor(.black)
                    .background(Color(red: 0.93, green: 0.93, blue: 0.93).opacity(0.9))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .offset(y: -244)
            }
            if number == "4" {
                Text("SETTINGS")
                    .font(.custom("OpenSans-Bold", size: 24))
                    .foregroundColor(.black)
                    .background(Color(red: 0.93, green: 0.93, blue: 0.93).opacity(0.9))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .offset(y: -244)
            }
        }
    }
}
