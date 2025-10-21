import WidgetKit
import SwiftUI

struct TouchSyncWidget: Widget {
    let kind: String = "TouchSyncWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TouchSyncProvider()) { entry in
            TouchSyncWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("TouchSync")
        .description("Stay connected with your partner's latest touch")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct TouchSyncProvider: TimelineProvider {
    func placeholder(in context: Context) -> TouchSyncEntry {
        TouchSyncEntry(date: Date(), lastTouch: "Squeeze Hand", partnerName: "Partner", connectionStreak: 7)
    }

    func getSnapshot(in context: Context, completion: @escaping (TouchSyncEntry) -> ()) {
        let entry = TouchSyncEntry(date: Date(), lastTouch: "Heart Trace", partnerName: "Love", connectionStreak: 12)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TouchSyncEntry>) -> ()) {
        // Get data from UserDefaults shared with main app
        let sharedDefaults = UserDefaults(suiteName: "group.touchsync.app")
        let lastTouch = sharedDefaults?.string(forKey: "lastTouch") ?? "No touches yet"
        let partnerName = sharedDefaults?.string(forKey: "partnerName") ?? "Partner"
        let streak = sharedDefaults?.integer(forKey: "connectionStreak") ?? 0
        
        let entry = TouchSyncEntry(
            date: Date(),
            lastTouch: lastTouch,
            partnerName: partnerName,
            connectionStreak: streak
        )
        
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(300))) // Update every 5 minutes
        completion(timeline)
    }
}

struct TouchSyncEntry: TimelineEntry {
    let date: Date
    let lastTouch: String
    let partnerName: String
    let connectionStreak: Int
}

struct TouchSyncWidgetEntryView: View {
    var entry: TouchSyncProvider.Entry
    
    var body: some View {
        ZStack {
            // Glassmorphism background
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            
            VStack(spacing: 8) {
                // Heart characters
                HStack(spacing: 12) {
                    HeartShape()
                        .fill(LinearGradient(
                            colors: [ColorPalette.crimson, ColorPalette.roseGold],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 24, height: 24)
                    
                    // Connection line with pulse
                    Rectangle()
                        .fill(ColorPalette.amber.opacity(0.6))
                        .frame(height: 2)
                        .overlay(
                            Rectangle()
                                .fill(ColorPalette.amber)
                                .frame(height: 2)
                                .scaleEffect(x: 0.5, anchor: .leading)
                        )
                    
                    HeartShape()
                        .fill(LinearGradient(
                            colors: [ColorPalette.deepPurple, ColorPalette.roseGold],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 24, height: 24)
                }
                
                // Last touch info
                VStack(spacing: 4) {
                    Text(entry.lastTouch)
                        .font(.caption.weight(.medium))
                        .foregroundColor(.primary)
                    
                    Text("from \(entry.partnerName)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                // Streak indicator
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(ColorPalette.amber)
                        .font(.caption2)
                    
                    Text("\(entry.connectionStreak) days")
                        .font(.caption2.weight(.medium))
                        .foregroundColor(.primary)
                }
            }
            .padding(12)
        }
    }
}

// Heart shape for widget
struct HeartShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: width * 0.5, y: height * 0.9))
        path.addCurve(
            to: CGPoint(x: width * 0.1, y: height * 0.3),
            control1: CGPoint(x: width * 0.5, y: height * 0.7),
            control2: CGPoint(x: width * 0.1, y: height * 0.5)
        )
        path.addArc(
            center: CGPoint(x: width * 0.25, y: height * 0.25),
            radius: width * 0.15,
            startAngle: .degrees(135),
            endAngle: .degrees(0),
            clockwise: false
        )
        path.addArc(
            center: CGPoint(x: width * 0.75, y: height * 0.25),
            radius: width * 0.15,
            startAngle: .degrees(180),
            endAngle: .degrees(45),
            clockwise: false
        )
        path.addCurve(
            to: CGPoint(x: width * 0.5, y: height * 0.9),
            control1: CGPoint(x: width * 0.9, y: height * 0.5),
            control2: CGPoint(x: width * 0.5, y: height * 0.7)
        )
        
        return path
    }
}