import tensorflow as tf
import numpy as np
from sklearn.model_selection import train_test_split
import coremltools

def create_trick_classifier():
    model = tf.keras.Sequential([
        tf.keras.layers.LSTM(64, input_shape=(100, 6), return_sequences=True),
        tf.keras.layers.LSTM(32),
        tf.keras.layers.Dense(16, activation='relu'),
        tf.keras.layers.Dropout(0.2),
        tf.keras.layers.Dense(3, activation='softmax')
    ])
    
    model.compile(
        optimizer='adam',
        loss='categorical_crossentropy',
        metrics=['accuracy']
    )
    
    return model

def preprocess_data(gyro_data, accel_data):
    combined_data = np.concatenate([gyro_data, accel_data], axis=2)
    mean = np.mean(combined_data, axis=(0, 1))
    std = np.std(combined_data, axis=(0, 1))
    normalized_data = (combined_data - mean) / std
    return normalized_data, mean, std

def train_model(X_train, y_train, X_val, y_val):
    model = create_trick_classifier()
    
    early_stopping = tf.keras.callbacks.EarlyStopping(
        monitor='val_loss',
        patience=5,
        restore_best_weights=True
    )
    
    history = model.fit(
        X_train,
        y_train,
        epochs=50,
        batch_size=32,
        validation_data=(X_val, y_val),
        callbacks=[early_stopping]
    )
    
    return model, history

def convert_to_coreml(model, mean, std):
    input_description = {
        'input_data': 'Sequence of gyroscope and accelerometer readings'
    }
    output_description = {
        'output': 'Probability distribution over trick classes'
    }
    
    coreml_model = coremltools.convert(
        model,
        inputs=[
            coremltools.TensorType(
                shape=(1, 100, 6),
                name='input_data'
            )
        ],
        preprocessing_args={
            'input_data': {
                'mean': mean,
                'std': std
            }
        },
        minimum_deployment_target=coremltools.target.iOS15
    )
    
    coreml_model.input_description = input_description
    coreml_model.output_description = output_description
    coreml_model.save('TrickClassifier.mlmodel')

if __name__ == '__main__':
    # Load your collected sensor data here
    # This is placeholder data - replace with real collected data
    X = np.random.randn(1000, 100, 6)  # 1000 samples, 100 timesteps, 6 features
    y = np.random.randint(0, 3, 1000)  # 3 classes
    
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)
    X_train_processed, mean, std = preprocess_data(X_train[:,:,:3], X_train[:,:,3:])
    X_test_processed, _, _ = preprocess_data(X_test[:,:,:3], X_test[:,:,3:])
    
    y_train = tf.keras.utils.to_categorical(y_train)
    y_test = tf.keras.utils.to_categorical(y_test)
    
    model, history = train_model(X_train_processed, y_train, X_test_processed, y_test)
    convert_to_coreml(model, mean, std) 