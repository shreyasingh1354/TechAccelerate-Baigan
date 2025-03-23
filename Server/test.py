import json
import numpy as np
import time
import asyncio
import logging
import os
from tensorflow.keras.models import load_model
from sklearn.preprocessing import StandardScaler
import pickle
from collections import deque

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Processing constants
PROCESSING_RATE = 10  # 10Hz
WINDOW_SIZE = 100

class FallDetector:
    def __init__(self, model_path=os.path.join('ml_models', 'best_fall_detection_model.h5'), scaler_path=os.path.join('ml_models', 'scaler.pkl')):
        self.model = load_model(model_path)
        
        try:
            with open(scaler_path, 'rb') as f:
                self.scaler = pickle.load(f)
        except FileNotFoundError:
            # Create default scaler
            self.scaler = StandardScaler()
            synthetic_data = np.random.uniform(-20, 20, (1000, 3))
            self.scaler.fit(synthetic_data)
            with open(scaler_path, 'wb') as f:
                pickle.dump(self.scaler, f)
        
        # Use deque to maintain a sliding window of accelerometer data
        self.data_window = deque(maxlen=WINDOW_SIZE)
        self.running = False
        self.latest_timestamp = None
    
    def process_data(self):
        """Process the current data window and make a prediction"""
        # Check if we have enough data
        if len(self.data_window) < WINDOW_SIZE:
            # Not enough data yet, pad with the available data
            logger.info(f"Not enough data in window ({len(self.data_window)}/{WINDOW_SIZE}). Padding with available data.")
            pad_count = WINDOW_SIZE - len(self.data_window)
            if len(self.data_window) > 0:
                # Pad with the first entry
                first_entry = self.data_window[0]
                padding = [first_entry] * pad_count
                sample = np.array(padding + list(self.data_window))
            else:
                # No data at all, return None
                return None
        else:
            # Use the full window
            sample = np.array(list(self.data_window))
        
        # Preprocess
        sample_scaled = self.scaler.transform(sample)
        sample_processed = sample_scaled.reshape(1, WINDOW_SIZE, 3)
        
        # Make prediction
        prediction = self.model.predict(sample_processed, verbose=0)[0][0]
        
        return {
            "is_fall": bool(prediction > 0.5),
            "confidence": float(prediction),
            "timestamp": self.latest_timestamp or time.time()
        }
    
    def update_data(self, data):
        """Add new accelerometer data to the sliding window"""
        try:
            acc_x = data['accelerometer']['x']
            acc_y = data['accelerometer']['y'] 
            acc_z = data['accelerometer']['z']
            
            # Add to the sliding window
            self.data_window.append([acc_x, acc_y, acc_z])
            
            # Update timestamp
            self.latest_timestamp = data.get("timestamp", time.time())
            
        except (KeyError, TypeError) as e:
            logger.error(f"Invalid accelerometer data format: {e}")
    
    async def start_processing(self, callback):
        self.running = True
        interval = 1.0 / PROCESSING_RATE
        
        while self.running:
            start_time = time.time()
            
            try:
                result = self.process_data()
                if result:
                    callback(result)
            except Exception as e:
                logger.error(f"Prediction error: {str(e)}")
            
            # Sleep to maintain fixed rate
            elapsed = time.time() - start_time
            await asyncio.sleep(max(0, interval - elapsed))
    
    def stop_processing(self):
        self.running = False