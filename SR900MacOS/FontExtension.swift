//
//  FontExtension.swift
//  UI Test
//
//  Created for OpenSans font support
//
import SwiftUI

extension Font {
    // OpenSans Regular
    static func openSans(size: CGFloat) -> Font {
        return Font.custom("OpenSans-Regular", size: size)
    }
    
    // OpenSans Bold
    static func openSansBold(size: CGFloat) -> Font {
        return Font.custom("OpenSans-Bold", size: size)
    }
    
    // OpenSans SemiBold
    static func openSansSemiBold(size: CGFloat) -> Font {
        return Font.custom("OpenSans-SemiBold", size: size)
    }
}

// Helper to register fonts programmatically (for macOS)
func registerCustomFonts() {
    let fontNames = ["OpenSans-Regular", "OpenSans-Bold", "OpenSans-SemiBold"]
    
    for fontName in fontNames {
        guard let fontURL = Bundle.main.url(forResource: fontName, withExtension: "ttf") else {
            print("❌ Failed to find font: \(fontName)")
            continue
        }
        
        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error) {
            print("❌ Error registering font \(fontName): \(error.debugDescription)")
        } else {
            print("✅ Successfully registered font: \(fontName)")
        }
    }
}
