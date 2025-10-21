import SwiftUI
import UIKit

struct DrawingCanvasView: UIViewRepresentable {
    @StateObject private var hapticsManager = HapticsManager.shared
    @Binding var isActive: Bool
    
    func makeUIView(context: Context) -> DrawingCanvas {
        let canvas = DrawingCanvas()
        canvas.delegate = context.coordinator
        return canvas
    }
    
    func updateUIView(_ uiView: DrawingCanvas, context: Context) {
        // Update if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, DrawingCanvasDelegate {
        let parent: DrawingCanvasView
        
        init(_ parent: DrawingCanvasView) {
            self.parent = parent
        }
        
        func touchBegan(at point: CGPoint, velocity: CGFloat) {
            parent.isActive = true
            let intensity = min(1.0, 0.3 + (velocity / 1000.0) * 0.7)
            parent.hapticsManager.playRealtimeTouch(intensity: Float(intensity))
            
            // Notify heart characters
            NotificationCenter.default.post(name: .drawingStarted, object: nil)
        }
        
        func touchMoved(to point: CGPoint, velocity: CGFloat) {
            let intensity = min(1.0, 0.3 + (velocity / 1000.0) * 0.7)
            parent.hapticsManager.playRealtimeTouch(intensity: Float(intensity))
        }
        
        func touchEnded(at point: CGPoint) {
            parent.isActive = false
            parent.hapticsManager.playRealtimeTouch(intensity: 0.2) // Final tap
            
            // Notify heart characters
            NotificationCenter.default.post(name: .drawingEnded, object: nil)
        }
    }
}

protocol DrawingCanvasDelegate: AnyObject {
    func touchBegan(at point: CGPoint, velocity: CGFloat)
    func touchMoved(to point: CGPoint, velocity: CGFloat)
    func touchEnded(at point: CGPoint)
}

class DrawingCanvas: UIView {
    weak var delegate: DrawingCanvasDelegate?
    
    private var currentPath = UIBezierPath()
    private var paths: [UIBezierPath] = []
    private var lastPoint: CGPoint = .zero
    private var lastTimestamp: TimeInterval = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor.black
        layer.cornerRadius = 20
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 74/255, green: 14/255, blue: 78/255, alpha: 1.0).cgColor
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Draw all completed paths
        context.setStrokeColor(UIColor(red: 255/255, green: 107/255, blue: 53/255, alpha: 1.0).cgColor)
        context.setLineWidth(3.0)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        
        for path in paths {
            context.addPath(path.cgPath)
            context.strokePath()
        }
        
        // Draw current path
        if !currentPath.isEmpty {
            context.addPath(currentPath.cgPath)
            context.strokePath()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let point = touch.location(in: self)
        lastPoint = point
        lastTimestamp = touch.timestamp
        
        currentPath = UIBezierPath()
        currentPath.move(to: point)
        
        delegate?.touchBegan(at: point, velocity: 0)
        setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let point = touch.location(in: self)
        let timestamp = touch.timestamp
        
        // Calculate velocity
        let distance = sqrt(pow(point.x - lastPoint.x, 2) + pow(point.y - lastPoint.y, 2))
        let timeDelta = timestamp - lastTimestamp
        let velocity = timeDelta > 0 ? distance / timeDelta : 0
        
        currentPath.addLine(to: point)
        
        delegate?.touchMoved(to: point, velocity: velocity)
        
        lastPoint = point
        lastTimestamp = timestamp
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let point = touch.location(in: self)
        paths.append(currentPath)
        currentPath = UIBezierPath()
        
        delegate?.touchEnded(at: point)
        setNeedsDisplay()
    }
    
    func clearCanvas() {
        paths.removeAll()
        currentPath = UIBezierPath()
        setNeedsDisplay()
    }
}

extension Notification.Name {
    static let drawingStarted = Notification.Name("drawingStarted")
    static let drawingEnded = Notification.Name("drawingEnded")
}