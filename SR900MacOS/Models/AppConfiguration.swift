//
//  AppConfiguration.swift
//  SR900MacOS
//
//  Created by Nisarg Mangukiya on 01/11/25.
//


import Foundation
import CoreGraphics

// MARK: - App Configuration
struct AppConfiguration {
    static let animationEnabled = false
    static let temperatureUnit = " F"
    static let version = "0.06"
    static let copyright = "© 2025-2026 Roast-Tech"
}

// MARK: - UI Constants
struct UIConstants {
    struct Dimensions {
        static let defaultHeight: CGFloat = 768
        static let mainPanelWidth: CGFloat = 607
        static let graphPanelWidth: CGFloat = 510
        static let secondaryPanelWidth: CGFloat = 410
        static let borderTopHeight: CGFloat = 80
        static let borderBottomHeight: CGFloat = 20
        static let borderSideWidth: CGFloat = 20
    }
    
    struct Colors {
        static let backgroundGray = CGColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1.0)
        static let buttonBackground = CGColor(red: 0.85, green: 0.75, blue: 0.6, alpha: 1.0)
    }
    
    struct Animation {
        static let duration: TimeInterval = 0.5
        static let initialDelay: TimeInterval = 1.0
        static let pauseDelay: TimeInterval = 1.0
    }
    
    struct Offsets {
        static let rectangle2Reveal: CGFloat = -40
        static let rectangle3Reveal: CGFloat = -90
        static let rectangle4Reveal: CGFloat = -140
        static let hiddenPosition: CGFloat = -570
        static let basePosition: CGFloat = -570
    }
}

// MARK: - Button Labels
enum BottomNavigationButton: String, CaseIterable {
    case graph = "GRAPH"
    case profiles = "PROFILES"
    case settings = "SETTINGS"
    case readMe = "READ-ME"
    
    var label: String {
        return self.rawValue
    }
}

// MARK: - Connection State
enum ConnectionType {
    case ble
    case usb
    case activity
}

// MARK: - Panel Type
enum PanelType: String {
    case graph
    case profiles
    case settings
    
    var revealOffset: CGFloat {
        switch self {
        case .graph: return UIConstants.Offsets.rectangle2Reveal
        case .profiles: return UIConstants.Offsets.rectangle3Reveal
        case .settings: return UIConstants.Offsets.rectangle4Reveal
        }
    }
}

// MARK: - Temperature Mode
enum TemperatureMode: String {
    case heating = "Heating"
    case cooling = "Cooling"
}
