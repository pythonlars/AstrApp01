import SwiftUI
import CoreMotion
import ARKit

struct UserInterface: View {
    @StateObject private var motionManager = MotionManager()
    @State private var currentRotation: Double = 0
    @State private var recognizedTrick: String = "Warte auf Trick..."
    @State private var trickScore: Int = 0
    @State private var isRecording = false
    @State private var sensorData: [Double] = Array(repeating: 0, count: 30)
    
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Erkannter Trick")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                
                // 3D Visualisierung
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 200, height: 200)
                    
                    BoardVisualization(rotation: currentRotation)
                        .frame(width: 100, height: 100)
                }
                .frame(height: 250)
                
                // Trick Information
                HStack {
                    Text("\(trickScore)°")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(recognizedTrick)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                
                // Sensor Visualization
                VStack(alignment: .leading, spacing: 10) {
                    Text("Sensor Daten")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    SensorVisualization(data: sensorData)
                        .frame(height: 60)
                }
                .padding()
                
                // Control Buttons
                HStack(spacing: 40) {
                    Button(action: {
                        isRecording.toggle()
                        if isRecording {
                            motionManager.startMotionUpdates()
                        } else {
                            motionManager.stopMotionUpdates()
                            analyzeTrick()
                        }
                    }) {
                        Circle()
                            .fill(isRecording ? Color.red : Color.white)
                            .frame(width: 60, height: 60)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                    }
                }
            }
            .padding()
        }
        .onReceive(timer) { _ in
            if isRecording {
                updateSensorData()
            }
        }
    }
    
    private func updateSensorData() {
        guard let motion = motionManager.motionManager.deviceMotion else { return }
        
        // Aktualisiere Rotationsdaten
        currentRotation = motion.attitude.roll * 180 / .pi
        
        // Aktualisiere Sensor-Visualisierung
        sensorData.removeFirst()
        sensorData.append(motion.rotationRate.z)
    }
    
    private func analyzeTrick() {
        // Beispiel-Trick-Erkennung basierend auf Rotation
        let totalRotation = abs(currentRotation)
        
        if totalRotation > 330 {
            recognizedTrick = "360 Flip"
            trickScore = 360
        } else if totalRotation > 150 {
            recognizedTrick = "180 Flip"
            trickScore = 180
        } else {
            recognizedTrick = "Kein Trick erkannt"
            trickScore = 0
        }
    }
}

struct BoardVisualization: View {
    var rotation: Double
    
    var body: some View {
        Rectangle()
            .fill(Color.white)
            .frame(width: 80, height: 80)
            .rotationEffect(.degrees(rotation))
            .animation(.linear, value: rotation)
    }
}

struct SensorVisualization: View {
    var data: [Double]
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let step = geometry.size.width / CGFloat(data.count - 1)
                let scale = geometry.size.height / 4
                
                path.move(to: CGPoint(x: 0, y: geometry.size.height / 2))
                
                for (index, value) in data.enumerated() {
                    let x = CGFloat(index) * step
                    let y = geometry.size.height / 2 - CGFloat(value) * scale
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(Color.white, lineWidth: 2)
        }
    }
}

class MotionManager: ObservableObject {
    let motionManager = CMMotionManager()
    
    init() {
        motionManager.deviceMotionUpdateInterval = 0.1
    }
    
    func startMotionUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates()
        }
    }
    
    func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
}
