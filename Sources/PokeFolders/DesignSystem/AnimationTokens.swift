import SwiftUI

enum AnimationTokens {
    static let quick = Animation.easeInOut(duration: 0.16)
    static let smooth = Animation.easeInOut(duration: 0.24)
    static let spring = Animation.spring(response: 0.34, dampingFraction: 0.82)
    static let softSpring = Animation.spring(response: 0.42, dampingFraction: 0.88)
}
