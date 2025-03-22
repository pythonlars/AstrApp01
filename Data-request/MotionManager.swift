import CoreMotion
import Combine

class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()
    
    @Published var isRecording = false
    @Published var gyroData: [CMGyroData] = []
    @Published var accelerometerData: [CMAccelerometerData] = []
    
    // Sampling rate: 100Hz as specified in the plan
    private let samplingRate: Double = 100.0
    
    init() {
        setupSensors()
    }
    
    private func setupSensors() {
        queue.maxConcurrentOperationCount = 1
        motionManager.gyroUpdateInterval = 1.0 / samplingRate
        motionManager.accelerometerUpdateInterval = 1.0 / samplingRate
    }
    
    func startRecording() {
        guard motionManager.isGyroAvailable && motionManager.isAccelerometerAvailable else {
            print("Sensors not available")
            return
        }
        
        gyroData.removeAll()
        accelerometerData.removeAll()
        
        motionManager.startGyroUpdates(to: queue) { [weak self] data, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self?.gyroData.append(data)
            }
        }
        
        motionManager.startAccelerometerUpdates(to: queue) { [weak self] data, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self?.accelerometerData.append(data)
            }
        }
        
        isRecording = true
    }
    
    func stopRecording() {
        motionManager.stopGyroUpdates()
        motionManager.stopAccelerometerUpdates()
        isRecording = false
    }
} 