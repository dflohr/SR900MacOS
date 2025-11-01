import SwiftUI
import AppKit

struct HeaderSection: View {
    var body: some View {
        HStack {
            WindowControlButtons()
                .offset(x: -16, y: -6)
            
            Spacer()
            
            LogoView()
                .offset(x: -135, y: -6)
            
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.black)
    }
}

// MARK: - Window Control Buttons
struct WindowControlButtons: View {
    var body: some View {
        HStack(spacing: 8) {
            WindowControlButton(
                color: .red,
                icon: "xmark",
                action: { NSApplication.shared.keyWindow?.close() },
                helpText: "Close"
            )
            
            WindowControlButton(
                color: .yellow,
                icon: "minus",
                action: { NSApplication.shared.keyWindow?.miniaturize(nil) },
                helpText: "Minimize"
            )
            
            WindowControlButton(
                color: .green,
                icon: "arrow.up.left.and.arrow.down.right",
                action: { NSApplication.shared.keyWindow?.toggleFullScreen(nil) },
                helpText: "Full Screen"
            )
        }
    }
}

struct WindowControlButton: View {
    let color: Color
    let icon: String
    let action: () -> Void
    let helpText: String
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 15, height: 15)
                .overlay(
                    Image(systemName: icon)
                        .font(.openSansBold(size: 10))
                        .foregroundColor(.black.opacity(0.6))
                )
        }
        .buttonStyle(PlainButtonStyle())
        .help(helpText)
    }
}

// MARK: - Logo View
struct LogoView: View {
    var body: some View {
        Image("RT_Logo")
            .resizable()
            .scaledToFit()
            .frame(width: 240, height: 34)
    }
}

// MARK: - Font Extension
extension Font {
    static func openSans(size: CGFloat) -> Font {
        .custom("OpenSans", size: size)
    }
    
    static func openSansBold(size: CGFloat) -> Font {
        .custom("OpenSans-Bold", size: size)
    }
}