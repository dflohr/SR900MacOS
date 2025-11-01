//
//  DisplaySection.swift
//  SR900MacOS
//
//  Created by Nisarg Mangukiya on 01/11/25.
//


import SwiftUI

// MARK: - Display Section
struct DisplaySection: View {
    @ObservedObject var controlState: MainControlState
    
    var body: some View {
        ScrollView {
            Text(controlState.displayText)
                .font(.openSansBold(size: 14))
                .foregroundColor(.green)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .frame(width: 540, height: 60)
        .background(Color.black)
        .padding(.bottom, 60)
    }
}

// MARK: - Bottom Section
struct BottomSection: View {
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .padding(.horizontal, 14)
                .padding(.bottom, 13)
                .offset(x: 4, y: -4)
            
            Rectangle()
                .fill(Color.black)
                .frame(height: 1)
                .padding(.horizontal, -10)
                .offset(y: -5)
            
            FooterSection()
        }
    }
}

// MARK: - Footer Section
struct FooterSection: View {
    var body: some View {
        HStack {
            Text("Ver. 0.06")
                .font(.openSansBold(size: 14))
                .foregroundColor(.black)
                .offset(y: 3)
            
            Spacer()
            
            Text("© 2025-2026 Roast-Tech")
                .font(.openSansBold(size: 14))
                .foregroundColor(.black)
                .offset(x: -135, y: 3)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}

// MARK: - Divider Component
struct Divider: View {
    var body: some View {
        HStack(spacing: 0) {
            // Placeholder for bottom buttons area
        }
    }
}
