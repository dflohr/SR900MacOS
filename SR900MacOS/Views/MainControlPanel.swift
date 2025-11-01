//
//  MainControlPanel.swift
//  SR900MacOS
//
//  Created by Nisarg Mangukiya on 01/11/25.
//


import SwiftUI

struct MainControlPanel: View {
    @ObservedObject var viewModel: ContentViewModel
    let onGraphButtonPressed: () -> Void
    let onProfilesButtonPressed: () -> Void
    let onSettingsButtonPressed: () -> Void
    
    var body: some View {
        FramedRectangle(
            number: "1",
            width: 607,
            imageName: nil,
            onGraphButtonPressed: onGraphButtonPressed,
            onProfilesButtonPressed: onProfilesButtonPressed,
            onSettingsButtonPressed: onSettingsButtonPressed,
            rectangle2Extended: $viewModel.rectangle2Extended,
            rectangle3Extended: $viewModel.rectangle3Extended,
            rectangle4Extended: $viewModel.rectangle4Extended
        )
    }
}