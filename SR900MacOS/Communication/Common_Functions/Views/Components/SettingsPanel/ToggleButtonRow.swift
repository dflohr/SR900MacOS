//
//  ToggleButtonRow.swift
//  SR900MacOS
//
//  Created by Nisarg Mangukiya on 01/11/25.
//

import SwiftUI


struct ToggleButtonRow: View {
    let title: String
    let leftLabel: String
    let rightLabel: String
    let leftSelected: Bool
    let actionLeft: () -> Void
    let actionRight: () -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(title)
                    .font(.openSansSemiBold(size: 14))
                Spacer()
                HStack(spacing: 0) {
                    Button(leftLabel, action: actionLeft)
                        .frame(width: 80, height: 30)
                        .background(leftSelected ? Color(red: 0.7, green: 0.85, blue: 0.4) : Color.white)
                        .border(Color.black, width: 1)
                        .buttonStyle(.plain)
                        .font(.openSansSemiBold(size: 14))

                    Button(rightLabel, action: actionRight)
                        .frame(width: 80, height: 30)
                        .background(!leftSelected ? Color(red: 0.7, green: 0.85, blue: 0.4) : Color.white)
                        .border(Color.black, width: 1)
                        .buttonStyle(.plain)
                        .font(.openSansSemiBold(size: 14))
                }
            }
            .padding(8)
            .background(Color.white)
            .border(Color.black)
        }
    }
}
