import SwiftUI

enum JustEnoughDesign {
    static let pageBackground = Color(red: 0.973, green: 0.963, blue: 0.936)
    static let ink = Color(red: 0.07, green: 0.065, blue: 0.055)
    static let secondaryInk = Color(red: 0.42, green: 0.39, blue: 0.34)
    static let accent = Color(red: 0.78, green: 0.18, blue: 0.08)
    static let blush = Color(red: 0.91, green: 0.58, blue: 0.52)
    static let glass = Color.white.opacity(0.72)

    static let spring = Animation.spring(response: 0.58, dampingFraction: 0.84)
}

extension View {
    func premiumPage() -> some View {
        background(JustEnoughDesign.pageBackground.ignoresSafeArea())
            .foregroundStyle(JustEnoughDesign.ink)
    }
}

extension Text {
    func editorialTitle(_ size: CGFloat = 38) -> some View {
        self
            .font(.system(size: size, weight: .regular, design: .rounded))
            .tracking(0)
    }

    func tinyCaps() -> some View {
        self
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .tracking(0)
            .foregroundStyle(JustEnoughDesign.secondaryInk.opacity(0.72))
    }
}
