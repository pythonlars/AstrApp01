import CoreML
import CoreMotion

enum TrickType: String {
    case flip180 = "180"
    case flip360 = "360"
    case backflip = "Backflip"
    case unknown = "Unknown"
}

class TrickClassifier {
    private var model: MLModel?
    private let windowSize = 100 // 1 second of data at 100Hz
    private var dataBuffer: [(gyro: CMGyroData, accel: CMAccelerometerData)] = []
    
    init() {
        loadModel()
    }
    
    private func loadModel() {
        do {
            // Replace "TrickClassifier" with your actual model name after training
            if let modelURL = Bundle.main.url(forResource: "TrickClassifier", withExtension: "mlmodelc") {
                model = try MLModel(contentsOf: modelURL)
            }
        } catch {
            print("Failed to load Core ML model: \(error)")
        }
    }
    
    func addSensorData(gyro: CMGyroData, accel: CMAccelerometerData) {
        dataBuffer.append((gyro: gyro, accel: accel))
        
        // Keep only the last second of data
        if dataBuffer.count > windowSize {
            dataBuffer.removeFirst()
        }
    }
    
    func predictTrick() -> TrickType {
        guard dataBuffer.count == windowSize,
              let model = model else {
            return .unknown
        }
        
        do {
            // Prepare input data
            var inputData = MLMultiArray(shape: [1, 100, 6], dataType: .float32)
            
            // Fill input data with sensor readings
            for (index, data) in dataBuffer.enumerated() {
                // Gyroscope data
                inputData[[0, index, 0] as [NSNumber]] = NSNumber(value: data.gyro.rotationRate.x)
                inputData[[0, index, 1] as [NSNumber]] = NSNumber(value: data.gyro.rotationRate.y)
                inputData[[0, index, 2] as [NSNumber]] = NSNumber(value: data.gyro.rotationRate.z)
                
                // Accelerometer data
                inputData[[0, index, 3] as [NSNumber]] = NSNumber(value: data.accel.acceleration.x)
                inputData[[0, index, 4] as [NSNumber]] = NSNumber(value: data.accel.acceleration.y)
                inputData[[0, index, 5] as [NSNumber]] = NSNumber(value: data.accel.acceleration.z)
            }
            
            // Make prediction
            let prediction = try model.prediction(from: MLDictionaryFeatureProvider(dictionary: [
                "input_data": inputData
            ]))
            
            if let outputValue = prediction.featureValue(for: "output"),
               let probabilities = outputValue.multiArrayValue {
                var maxProb: Float = 0
                var maxIndex = 0
                
                for i in 0..<3 {
                    let prob = probabilities[[i] as [NSNumber]].floatValue
                    if prob > maxProb {
                        maxProb = prob
                        maxIndex = i
                    }
                }
                
                switch maxIndex {
                case 0: return .flip180
                case 1: return .flip360
                case 2: return .backflip
                default: return .unknown
                }
            }
        } catch {
            print("Prediction error: \(error)")
        }
        
        return .unknown
    }
} 