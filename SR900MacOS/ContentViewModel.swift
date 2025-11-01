import SwiftUI

class ContentViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var rectangle2Offset: CGFloat = -570
    @Published var rectangle3Offset: CGFloat = -570
    @Published var rectangle4Offset: CGFloat = -570
    @Published var animationsComplete: Bool = false
    @Published var rectangle2Extended: Bool = false
    @Published var rectangle3Extended: Bool = false
    @Published var rectangle4Extended: Bool = false
    
    // MARK: - Configuration
    let animationEnabled: Bool = false
    
    // MARK: - Animation Constants
    private struct AnimationConstants {
        static let duration: TimeInterval = 0.5
        static let initialDelay: TimeInterval = 1.0
        static let pauseDelay: TimeInterval = 1.0
        static let rectangle2RevealOffset: CGFloat = -40
        static let rectangle3RevealOffset: CGFloat = -90
        static let rectangle4RevealOffset: CGFloat = -140
        static let hiddenOffset: CGFloat = -570
    }
    
    // MARK: - Public Methods
    func handleGraphButtonPress() {
        guard animationsComplete else { return }
        
        if rectangle3Extended {
            retractPanel(.profiles) {
                self.extendPanel(.graph)
            }
        } else if rectangle4Extended {
            retractPanel(.settings) {
                self.extendPanel(.graph)
            }
        } else {
            togglePanel(.graph)
        }
    }
    
    func handleProfilesButtonPress() {
        guard animationsComplete else { return }
        
        if rectangle2Extended {
            retractPanel(.graph) {
                self.extendPanel(.profiles)
            }
        } else if rectangle4Extended {
            retractPanel(.settings) {
                self.extendPanel(.profiles)
            }
        } else {
            togglePanel(.profiles)
        }
    }
    
    func handleSettingsButtonPress() {
        guard animationsComplete else { return }
        
        if rectangle2Extended {
            retractPanel(.graph) {
                self.extendPanel(.settings)
            }
        } else if rectangle3Extended {
            retractPanel(.profiles) {
                self.extendPanel(.settings)
            }
        } else {
            togglePanel(.settings)
        }
    }
    
    func startInitialAnimationSequence() {
        if !animationEnabled {
            animationsComplete = true
            return
        }
        
        performInitialAnimation()
    }
    
    // MARK: - Private Methods
    private enum Panel {
        case graph, profiles, settings
    }
    
    private func togglePanel(_ panel: Panel) {
        switch panel {
        case .graph:
            let targetOffset = rectangle2Extended ? AnimationConstants.hiddenOffset : AnimationConstants.rectangle2RevealOffset
            animateOffset(for: panel, to: targetOffset) {
                self.rectangle2Extended.toggle()
            }
        case .profiles:
            let targetOffset = rectangle3Extended ? AnimationConstants.hiddenOffset : AnimationConstants.rectangle3RevealOffset
            animateOffset(for: panel, to: targetOffset) {
                self.rectangle3Extended.toggle()
            }
        case .settings:
            let targetOffset = rectangle4Extended ? AnimationConstants.hiddenOffset : AnimationConstants.rectangle4RevealOffset
            animateOffset(for: panel, to: targetOffset) {
                self.rectangle4Extended.toggle()
            }
        }
    }
    
    private func extendPanel(_ panel: Panel) {
        switch panel {
        case .graph:
            animateOffset(for: panel, to: AnimationConstants.rectangle2RevealOffset) {
                self.rectangle2Extended = true
            }
        case .profiles:
            animateOffset(for: panel, to: AnimationConstants.rectangle3RevealOffset) {
                self.rectangle3Extended = true
            }
        case .settings:
            animateOffset(for: panel, to: AnimationConstants.rectangle4RevealOffset) {
                self.rectangle4Extended = true
            }
        }
    }
    
    private func retractPanel(_ panel: Panel, completion: @escaping () -> Void) {
        animateOffset(for: panel, to: AnimationConstants.hiddenOffset) {
            switch panel {
            case .graph:
                self.rectangle2Extended = false
            case .profiles:
                self.rectangle3Extended = false
            case .settings:
                self.rectangle4Extended = false
            }
            completion()
        }
    }
    
    private func animateOffset(for panel: Panel, to offset: CGFloat, completion: @escaping () -> Void) {
        withAnimation(.linear(duration: AnimationConstants.duration)) {
            switch panel {
            case .graph:
                rectangle2Offset = offset
            case .profiles:
                rectangle3Offset = offset
            case .settings:
                rectangle4Offset = offset
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + AnimationConstants.duration) {
            completion()
        }
    }
    
    private func performInitialAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + AnimationConstants.initialDelay) {
            withAnimation(.linear(duration: AnimationConstants.duration)) {
                self.rectangle2Offset = AnimationConstants.rectangle2RevealOffset
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.linear(duration: AnimationConstants.duration)) {
                self.rectangle2Offset = AnimationConstants.hiddenOffset
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            withAnimation(.linear(duration: AnimationConstants.duration)) {
                self.rectangle3Offset = AnimationConstants.rectangle3RevealOffset
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
            withAnimation(.linear(duration: AnimationConstants.duration)) {
                self.rectangle3Offset = AnimationConstants.hiddenOffset
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            self.animationsComplete = true
        }
    }
}