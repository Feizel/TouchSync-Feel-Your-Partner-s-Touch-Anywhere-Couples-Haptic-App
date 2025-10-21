import CoreHaptics
import Foundation

@MainActor
class HapticsManager: ObservableObject {
    static let shared = HapticsManager()
    
    private var engine: CHHapticEngine?
    private var isPlaying = false
    
    var supportsHaptics: Bool {
        CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }
    
    init() {
        setupEngine()
    }
    
    private func setupEngine() {
        guard supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
            
            engine?.resetHandler = { [weak self] in
                try? self?.engine?.start()
            }
            
            engine?.stoppedHandler = { [weak self] reason in
                switch reason {
                case .audioSessionInterrupt, .applicationSuspended, .idleTimeout:
                    try? self?.engine?.start()
                default:
                    break
                }
            }
        } catch {
            print("Haptic engine setup failed: \(error)")
        }
    }
    
    func playGesture(_ gesture: HapticGesture) {
        guard let engine = engine, !isPlaying else { return }
        
        do {
            let pattern = try createPattern(for: gesture)
            let player = try engine.makePlayer(with: pattern)
            
            isPlaying = true
            
            // Notify heart characters to animate
            NotificationCenter.default.post(
                name: .hapticGestureStarted,
                object: gesture
            )
            
            try player.start(atTime: 0)
            
            // Reset playing state after gesture duration
            DispatchQueue.main.asyncAfter(deadline: .now() + gesture.duration) {
                self.isPlaying = false
            }
            
        } catch {
            print("Failed to play haptic: \(error)")
            isPlaying = false
        }
    }
    
    func playRealtimeTouch(intensity: Float, sharpness: Float = 0.5) {
        guard let engine = engine else { return }
        
        do {
            let event = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
                ],
                relativeTime: 0,
                duration: 0.1
            )
            
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
            
        } catch {
            print("Failed to play realtime haptic: \(error)")
        }
    }
    
    private func createPattern(for gesture: HapticGesture) throws -> CHHapticPattern {
        let events = gesture.events.map { event in
            CHHapticEvent(
                eventType: event.type,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: event.intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: event.sharpness)
                ],
                relativeTime: event.time,
                duration: event.duration
            )
        }
        
        return try CHHapticPattern(events: events, parameters: [])
    }
}

struct HapticGesture {
    let name: String
    let events: [HapticEvent]
    let duration: TimeInterval
    let icon: String
    let color: String
    
    static let squeezeHand = HapticGesture(
        name: "Squeeze Hand",
        events: [
            HapticEvent(time: 0.0, type: .hapticTransient, intensity: 0.8, sharpness: 0.5, duration: 0),
            HapticEvent(time: 0.2, type: .hapticTransient, intensity: 0.8, sharpness: 0.5, duration: 0),
            HapticEvent(time: 0.4, type: .hapticTransient, intensity: 0.8, sharpness: 0.5, duration: 0)
        ],
        duration: 0.6,
        icon: "🤝",
        color: "#8B0000"
    )
    
    static let foreheadKiss = HapticGesture(
        name: "Forehead Kiss",
        events: [
            HapticEvent(time: 0.0, type: .hapticContinuous, intensity: 0.4, sharpness: 0.2, duration: 1.0)
        ],
        duration: 1.0,
        icon: "😘",
        color: "#B76E79"
    )
    
    static let hug = HapticGesture(
        name: "Hug",
        events: [
            HapticEvent(time: 0.0, type: .hapticContinuous, intensity: 0.3, sharpness: 0.3, duration: 3.0),
            HapticEvent(time: 1.5, type: .hapticContinuous, intensity: 0.8, sharpness: 0.3, duration: 0.5),
            HapticEvent(time: 2.5, type: .hapticContinuous, intensity: 0.3, sharpness: 0.3, duration: 0.5)
        ],
        duration: 3.0,
        icon: "🤗",
        color: "#FF6B35"
    )
    
    static let shoulderTap = HapticGesture(
        name: "Shoulder Tap",
        events: [
            HapticEvent(time: 0.0, type: .hapticTransient, intensity: 1.0, sharpness: 0.8, duration: 0),
            HapticEvent(time: 0.15, type: .hapticTransient, intensity: 1.0, sharpness: 0.8, duration: 0)
        ],
        duration: 0.3,
        icon: "👋",
        color: "#4A0E4E"
    )
    
    static let heartTrace = HapticGesture(
        name: "Heart Trace",
        events: [
            HapticEvent(time: 0.0, type: .hapticTransient, intensity: 0.7, sharpness: 0.4, duration: 0),
            HapticEvent(time: 0.3, type: .hapticContinuous, intensity: 0.5, sharpness: 0.3, duration: 0.4),
            HapticEvent(time: 0.8, type: .hapticTransient, intensity: 0.7, sharpness: 0.4, duration: 0),
            HapticEvent(time: 1.1, type: .hapticContinuous, intensity: 0.5, sharpness: 0.3, duration: 0.4),
            HapticEvent(time: 1.6, type: .hapticTransient, intensity: 0.8, sharpness: 0.5, duration: 0)
        ],
        duration: 2.0,
        icon: "💖",
        color: "#8B0000"
    )
    
    static let allGestures = [squeezeHand, foreheadKiss, hug, shoulderTap, heartTrace]
}

struct HapticEvent {
    let time: TimeInterval
    let type: CHHapticEvent.EventType
    let intensity: Float
    let sharpness: Float
    let duration: TimeInterval
}

extension Notification.Name {
    static let hapticGestureStarted = Notification.Name("hapticGestureStarted")
}