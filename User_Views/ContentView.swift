import SwiftUI
import CoreMotion

struct ContentView: View {
    @StateObject private var motionManager = MotionManager()
    @State private var recognizedTrick: String = "No Trick"
    @State private var showDebugMode = false
    @State private var rotationX: Float = 0
    @State private var rotationY: Float = 0
    @State private var rotationZ: Float = 0
    
    var body: some View {
        VStack(spacing: 20) {
            // 3D Cube Visualization
            CubeView(
                rotationX: rotationX,
                rotationY: rotationY,
                rotationZ: rotationZ
            )
            .frame(height: 300)
            .background(Color.black.opacity(0.1))
            .cornerRadius(15)
            
            // Trick Display
            Text(recognizedTrick)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primary)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(15)
            
            // Control Buttons
            HStack(spacing: 20) {
                Button(action: {
                    if motionManager.isRecording {
                        motionManager.stopRecording()
                    } else {
                        motionManager.startRecording()
                    }
                }) {
                    Text(motionManager.isRecording ? "Stop Recording" : "Start Recording")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(motionManager.isRecording ? Color.red : Color.green)
                        .cornerRadius(10)
                }
                
                Button(action: { showDebugMode.toggle() }) {
                    Text("Debug Mode")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            
            if showDebugMode {
                DebugView(motionManager: motionManager)
            }
        }
        .padding()
        .onReceive(motionManager.$gyroData) { data in
            guard let lastData = data.last else { return }
            rotationX = Float(lastData.rotationRate.x)
            rotationY = Float(lastData.rotationRate.y)
            rotationZ = Float(lastData.rotationRate.z)
        }
    }
} 