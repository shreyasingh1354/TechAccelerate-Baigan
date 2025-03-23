import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';

// Import your custom widgets
import 'package:baigan/widgets/custom_appbar.dart';
import 'package:baigan/widgets/home_screen_emergency_contact_widget.dart';
import 'package:baigan/widgets/home_screen_emergency_grid_widget.dart';
import 'package:baigan/widgets/home_screen_sos_widget.dart';
// or adjust the paths based on your folder structure

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- All your logic remains here ---

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

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _loadingLocation = false;
      });

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
          title: 'Home',
          showCartIcon: false,
        ),
        backgroundColor: Colors.grey.shade300,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Use your new custom widget
              const EmergencyContactsWidget(),
              const SizedBox(height: 30),
              // Use your new custom widget
              const EmergencyServicesGrid(),
              const SizedBox(height: 30),
              // Use your new custom widget
              SosButton(
                onPressed: () {
                  // Add SOS action here
                  print('SOS Pressed!');
                },
              ),
              // Additional logic or UI can go here
            ],
          ),
        ),
      ),
    );
  }
}