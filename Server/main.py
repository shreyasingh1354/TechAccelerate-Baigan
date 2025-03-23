from fastapi import FastAPI, WebSocket, WebSocketDisconnect
import json
import logging
import asyncio
from datetime import datetime
import uvicorn
from test import FallDetector

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI()
connections = set()

GEO_API_KEY="447746b793944a4ea89ee40c54badca4"
SMS_API_KEY="60WBkIAfEhPZnKCMS1XVxF2ya7vJdRLYrwopszjDgNQ3itHlTbr9q6Bzhbf1lKACJGv0HEIniTap78jV"

# Initialize fall detector
detector = FallDetector()
detector_task = None

def handle_prediction(result):
    # Just log the prediction result - no extra processing
    if result["is_fall"]:
        logger.info(f"FALL DETECTED! Confidence: {result['confidence']:.4f}")
    
    # Send prediction to all connected clients
    message = json.dumps(result)
    for websocket in connections.copy():
        asyncio.create_task(websocket.send_text(message))

@app.get("/")
async def root():
    return {"message": "WebSocket Fall Detection Running"}

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    global detector_task
    
    await websocket.accept()
    connections.add(websocket)
    client_id = id(websocket)
    logger.info(f"Client {client_id} connected. Total connections: {len(connections)}")
    
    # Start detector processing loop if not already running
    if detector_task is None or detector_task.done():
        detector.running = True
        detector_task = asyncio.create_task(detector.start_processing(handle_prediction))
    
    try:
        while True:
            # Get data from client
            data_str = await websocket.receive_text()
            
            try:
                # Parse JSON to validate
                data = json.loads(data_str)
                
                # Update detector with latest data
                detector.update_data(data)
                
            except json.JSONDecodeError:
                logger.error(f"Invalid JSON: {data_str}")
            except Exception as e:
                logger.error(f"Error: {str(e)}")
                
    except WebSocketDisconnect:
        connections.remove(websocket)
        logger.info(f"Client {client_id} disconnected. Remaining: {len(connections)}")
        
        # Stop detector if no connections left
        if len(connections) == 0 and detector_task is not None:
            detector.stop_processing()
            detector_task = None

@app.post("/get-hospitals/")
async def get_hospitals(lat: float, lon: float):
    url = f"https://api.geoapify.com/v2/places?categories=healthcare.hospital&filter=circle:{lat},{lon},5000&bias=proximity:{lat},{lon}&limit=20&apiKey={GEO_API_KEY}"

    response = requests.get(url)
    data = response.json()

    # Filter out hospitals that have an empty "details" field
    filtered_features = [feature for feature in data.get("features", []) if feature["properties"].get("details")]

    filtered_data = []
    for feature in filtered_features:
        properties = feature["properties"]
        coordinates = feature["geometry"]["coordinates"]

        filtered_data.append({
            "name": properties.get("address_line1", ""),
            "address": properties.get("address_line2", ""),
            "contact": properties.get("contact", {}).get("phone", ""),
            "location_url": f"https://www.google.com/maps?q={coordinates[1]},{coordinates[0]}"
        })

    return {"hospitals": filtered_data}

@app.post("/send-sos/")
async def send_sos(lat: float, lon: float, contact: str):
    url = "https://www.fast2sms.com/dev/bulkV2"
    location_link = f"https://www.google.com/maps/search/?api=1&query={lat},{lon}"

    querystring = {
        "authorization": SMS_API_KEY,
        "message": f"🚨 SOS\nThis is not a drill\nI'm in danger! Help me!! \n {location_link}",
        "language": "english",
        "route": "q",
        "numbers": contact
    }

    headers = {
        'cache-control': "no-cache"
    }

    response = requests.get(url, headers=headers, params=querystring)

    return {"status": response.status_code, "response": response.text}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)