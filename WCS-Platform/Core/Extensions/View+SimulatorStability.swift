import SwiftUI

private struct SimulatorTextSelectionStabilityModifier: ViewModifier {
    func body(content: Content) -> some View {
        if AppEnvironment.simulatorStabilityMode {
            content.textSelection(.disabled)
        } else {
            content
        }
    }
}

extension View {
    func simulatorStableTextSelection() -> some View {
        modifier(SimulatorTextSelectionStabilityModifier())
    }
}
