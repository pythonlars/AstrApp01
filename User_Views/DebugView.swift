yimport SwiftUI
import CoreMotion

struct DebugView: View {
    @ObservedObject var motionManager: MotionManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Debug Information")
                .font(.headline)
                .padding(.bottom)
            
            Group {
                Text("Gyroscope Data:")
                    .font(.subheadline)
                    .bold()
                
                if let lastGyro = motionManager.gyroData.last {
                    Text("X: \(String(format: "%.2f", lastGyro.rotationRate.x))")
                    Text("Y: \(String(format: "%.2f", lastGyro.rotationRate.y))")
                    Text("Z: \(String(format: "%.2f", lastGyro.rotationRate.z))")
                }
                
                Text("Accelerometer Data:")
                    .font(.subheadline)
                    .bold()
                    .padding(.top)
                
                if let lastAccel = motionManager.accelerometerData.last {
                    Text("X: \(String(format: "%.2f", lastAccel.acceleration.x))")
                    Text("Y: \(String(format: "%.2f", lastAccel.acceleration.y))")
                    Text("Z: \(String(format: "%.2f", lastAccel.acceleration.z))")
                }
            }
            
            VStack(alignment: .leading) {
                Text("Recording Stats:")
                    .font(.subheadline)
                    .bold()
                    .padding(.top)
                
                Text("Samples Collected: \(motionManager.gyroData.count)")
                Text("Recording Time: \(String(format: "%.1f", Double(motionManager.gyroData.count) / 100.0))s")
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
} 