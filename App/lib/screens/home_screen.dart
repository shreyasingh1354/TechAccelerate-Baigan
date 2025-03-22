import 'package:flutter/material.dart';
import 'package:baigan/widgets/custom_appbar.dart';
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Accelerometer data
  double _xValue = 0.0;
  double _yValue = 0.0;
  double _zValue = 0.0;

  // Location data
  Position? _currentPosition;
  String _locationError = '';
  bool _loadingLocation = false;

  // WebSocket variables
  WebSocketChannel? _channel;
  bool _isConnected = false;
  String _lastMessage = "No messages received";

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    _connectToWebSocket();
    _startListeningToAccelerometer();
    _getCurrentLocation();
  }

  void _startListeningToAccelerometer() {
    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _xValue = event.x;
        _yValue = event.y;
        _zValue = event.z;
      });
      _sendSensorData();
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _loadingLocation = true;
      _locationError = '';
    });

    try {
      // Check for location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _loadingLocation = false;
            _locationError = 'Location permission denied';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _loadingLocation = false;
          _locationError = 'Location permission permanently denied';
        });
        return;
      }

      // Get the current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _loadingLocation = false;
      });

      // Send updated data including new location
      _sendSensorData();
    } catch (e) {
      setState(() {
        _loadingLocation = false;
        _locationError = 'Error getting location: $e';
      });
    }
  }

  void _connectToWebSocket() {
    try {
      final wsUrl = 'ws://10.0.2.2:8000/ws';
      print("Connecting to WebSocket at: $wsUrl");

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      setState(() {
        _isConnected = true;
      });

      _channel!.stream.listen(
        (message) {
          print('Received from server: $message');
          setState(() {
            _lastMessage = message.toString();
          });
        },
        onDone: () {
          print("WebSocket closed");
          setState(() {
            _isConnected = false;
          });
          _reconnectWebSocket();
        },
        onError: (error) {
          print("WebSocket error: $error");
          setState(() {
            _isConnected = false;
          });
          _reconnectWebSocket();
        },
      );
    } catch (e) {
      print("WebSocket connection failed: $e");
      setState(() {
        _isConnected = false;
      });
      _reconnectWebSocket();
    }
  }

  void _reconnectWebSocket() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!_isConnected) {
        print("Reconnecting WebSocket...");
        _connectToWebSocket();
      }
    });
  }

  void _sendSensorData() {
    if (!_isConnected || _channel == null) return;

    final data = {
      "timestamp": DateTime.now().toIso8601String(),
      "accelerometer": {"x": _xValue, "y": _yValue, "z": _zValue},
      "location": _currentPosition != null
          ? {
              "latitude": _currentPosition!.latitude,
              "longitude": _currentPosition!.longitude,
              "altitude": _currentPosition!.altitude,
              "accuracy": _currentPosition!.accuracy
            }
          : null
    };

    try {
      _channel!.sink.add(jsonEncode(data));
    } catch (e) {
      print("Error sending data: $e");
    }
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Baigan',
          showCartIcon: true,
        ),
        backgroundColor: Colors.grey.shade300,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Connection Status
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'WebSocket Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _isConnected ? Colors.green : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isConnected
                                  ? 'Connected to Server'
                                  : 'Disconnected',
                              style: TextStyle(
                                color: _isConnected ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('Last Response: $_lastMessage',
                            style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Real Accelerometer Data
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Real Accelerometer Data',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _sensorValueBox('X', _xValue.toStringAsFixed(3)),
                            _sensorValueBox('Y', _yValue.toStringAsFixed(3)),
                            _sensorValueBox('Z', _zValue.toStringAsFixed(3)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Location Data
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Location',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_loadingLocation)
                          const Center(child: CircularProgressIndicator())
                        else if (_locationError.isNotEmpty)
                          Text(
                            _locationError,
                            style: const TextStyle(color: Colors.red),
                          )
                        else if (_currentPosition != null)
                          Column(
                            children: [
                              _locationInfoRow(
                                  'Latitude', '${_currentPosition!.latitude}°'),
                              const SizedBox(height: 8),
                              _locationInfoRow('Longitude',
                                  '${_currentPosition!.longitude}°'),
                              const SizedBox(height: 8),
                              _locationInfoRow('Altitude',
                                  '${_currentPosition!.altitude.toStringAsFixed(2)} m'),
                              const SizedBox(height: 8),
                              _locationInfoRow('Accuracy',
                                  '${_currentPosition!.accuracy.toStringAsFixed(2)} m'),
                            ],
                          )
                        else
                          const Text('Location not available'),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _getCurrentLocation,
                          child: const Text('Refresh Location'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sensorValueBox(String axis, String value) {
    return Column(
      children: [
        Text(axis, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }

  Widget _locationInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label), Text(value)],
    );
  }
}
