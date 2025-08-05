import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Animation Utilities
struct AnimationUtils {
    // MARK: - Animation Presets
    
    /// Standard button press animation
    static let buttonPress = Animation.spring(response: 0.3, dampingFraction: 0.6)
    
    /// Smooth transition animation
    static let smoothTransition = Animation.easeInOut(duration: 0.3)
    
    /// Quick pop animation
    static let quickPop = Animation.spring(response: 0.4, dampingFraction: 0.7)
    
    /// Slow and smooth animation
    static let slowSmooth = Animation.easeInOut(duration: 0.6)
    
    /// Bouncy animation
    static let bouncy = Animation.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.25)
    
    /// Subtle animation
    static let subtle = Animation.easeOut(duration: 0.2)
    
    /// Delayed appearance animation
    static func delayedAppearance(delay: Double = 0.1) -> Animation {
        return Animation.easeInOut(duration: 0.3).delay(delay)
    }
    
    /// Staggered animation for lists
    static func staggered(index: Int, baseDelay: Double = 0.05) -> Animation {
        return Animation.spring(response: 0.4, dampingFraction: 0.7)
            .delay(Double(index) * baseDelay)
    }
    // MARK: - Motion Sensitivity
    
    /// Returns appropriate animation based on reduce motion setting
    static func motionSensitive(_ animation: Animation?) -> Animation? {
        #if canImport(UIKit)
        return UIAccessibility.isReduceMotionEnabled ? nil : animation
        #else
        return animation
        #endif
    }
    
    /// Returns appropriate animation duration based on reduce motion setting
    static func motionSensitiveDuration(_ duration: Double) -> Double {
        #if canImport(UIKit)
        return UIAccessibility.isReduceMotionEnabled ? 0.1 : duration
        #else
        return duration
        #endif
    }
    
    // MARK: - Haptic Feedback
    
    /// Trigger light impact haptic feedback
    static func hapticLight() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }
    
    /// Trigger medium impact haptic feedback
    static func hapticMedium() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #endif
    }
    
    /// Trigger heavy impact haptic feedback
    static func hapticHeavy() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        #endif
    }
    
    /// Trigger selection haptic feedback
    static func hapticSelection() {
        #if canImport(UIKit)
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        #endif
    }
    
    /// Trigger notification haptic feedback
    static func hapticNotification(type: HapticNotificationType = .success) {
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        switch type {
        case .success:
            generator.notificationOccurred(.success)
        case .warning:
            generator.notificationOccurred(.warning)
        case .error:
            generator.notificationOccurred(.error)
        }
        #endif
    }
    
    enum HapticNotificationType {
        case success
        case warning
        case error
    }
}

// MARK: - Animation View Modifiers

/// Button press animation modifier
struct ButtonPressAnimationModifier: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(AnimationUtils.motionSensitive(.spring(response: 0.3, dampingFraction: 0.6)), value: isPressed)
            .onTapGesture {
                withAnimation {
                    isPressed = true
                    AnimationUtils.hapticLight()
                    
                    // Reset after animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            isPressed = false
                        }
                    }
                }
            }
    }
}

/// Pulse animation modifier
struct PulseAnimationModifier: ViewModifier {
    @State private var isPulsing = false
    let duration: Double
    let scale: CGFloat
    let autoStart: Bool
    
    init(duration: Double = 1.5, scale: CGFloat = 1.1, autoStart: Bool = true) {
        self.duration = duration
        self.scale = scale
        self.autoStart = autoStart
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? scale : 1.0)
            .animation(
                AnimationUtils.motionSensitive(
                    Animation.easeInOut(duration: duration)
                        .repeatForever(autoreverses: true)
                ),
                value: isPulsing
            )
            .onAppear {
                if autoStart {
                    isPulsing = true
                }
            }
    }
}

/// Shimmer loading effect modifier
struct ShimmerModifier: ViewModifier {
    @State private var isAnimating = false
    let duration: Double
    
    init(duration: Double = 1.5) {
        self.duration = duration
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    ZStack {
                        Color.white.opacity(0.3)
                            .mask(
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.clear, .white.opacity(0.5), .clear]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .rotationEffect(.degrees(70))
                                    .offset(x: isAnimating ? geometry.size.width : -geometry.size.width)
                            )
                    }
                }
            )
            .onAppear {
                withAnimation(Animation.linear(duration: duration).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}

/// Fade in animation modifier
struct FadeInModifier: ViewModifier {
    @State private var opacity: Double = 0
    let duration: Double
    let delay: Double
    
    init(duration: Double = 0.3, delay: Double = 0) {
        self.duration = duration
        self.delay = delay
    }
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: duration).delay(delay)) {
                    opacity = 1
                }
            }
    }
}

/// Slide in animation modifier
struct SlideInModifier: ViewModifier {
    @State private var offset: CGFloat = 100
    @State private var opacity: Double = 0
    let direction: SlideDirection
    let duration: Double
    let delay: Double
    
    init(direction: SlideDirection = .bottom, duration: Double = 0.3, delay: Double = 0) {
        self.direction = direction
        self.duration = duration
        self.delay = delay
    }
    
    func body(content: Content) -> some View {
        content
            .offset(
                x: direction == .leading || direction == .trailing ? 
                    (direction == .leading ? offset : -offset) : 0,
                y: direction == .top || direction == .bottom ? 
                    (direction == .top ? offset : -offset) : 0
            )
            .opacity(opacity)
            .onAppear {
                withAnimation(Animation.easeOut(duration: duration).delay(delay)) {
                    offset = 0
                    opacity = 1
                }
            }
    }
    
    enum SlideDirection {
        case top, bottom, leading, trailing
    }
}

// MARK: - View Extensions

extension View {
    /// Apply button press animation
    func buttonPressAnimation() -> some View {
        modifier(ButtonPressAnimationModifier())
    }
    
    /// Apply pulse animation
    func pulseAnimation(duration: Double = 1.5, scale: CGFloat = 1.1, autoStart: Bool = true) -> some View {
        modifier(PulseAnimationModifier(duration: duration, scale: scale, autoStart: autoStart))
    }
    
    /// Apply shimmer loading effect
    func shimmer(duration: Double = 1.5) -> some View {
        modifier(ShimmerModifier(duration: duration))
    }
    
    /// Apply fade in animation
    func fadeIn(duration: Double = 0.3, delay: Double = 0) -> some View {
        modifier(FadeInModifier(duration: duration, delay: delay))
    }
    
    /// Apply slide in animation
    func slideIn(from direction: SlideInModifier.SlideDirection = .bottom, 
                duration: Double = 0.3, 
                delay: Double = 0) -> some View {
        modifier(SlideInModifier(direction: direction, duration: duration, delay: delay))
    }
    
    /// Apply staggered animation for list items
    func staggeredAppear(index: Int, baseDelay: Double = 0.05) -> some View {
        self.opacity(0)
            .animation(nil, value: UUID())
            .overlay(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            withAnimation(AnimationUtils.staggered(index: index, baseDelay: baseDelay)) {
                                self.opacity(1)
                            }
                        }
                }
            )
    }
}

// MARK: - Button Styles

/// Scale button style with accessibility support
struct AccessibleScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(
                AnimationUtils.motionSensitive(.easeOut(duration: 0.2)),
                value: configuration.isPressed
            )
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    AnimationUtils.hapticLight()
                }
            }
    }
}

/// Bounce button style with accessibility support
struct BouncyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(
                AnimationUtils.motionSensitive(.spring(response: 0.4, dampingFraction: 0.6)),
                value: configuration.isPressed
            )
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    AnimationUtils.hapticMedium()
                }
            }
    }
}
