import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:baigan/widgets/custom_appbar.dart';
import 'package:baigan/widgets/home_screen_emergency_contact_widget.dart';
import 'package:baigan/widgets/home_screen_emergency_grid_widget.dart';
import 'package:baigan/widgets/home_screen_sos_widget.dart';
import 'package:http/http.dart' as http;

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
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    // Set system UI mode once in initState
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
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
            _locationError =
                'Location access is required for emergency services';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _loadingLocation = false;
          _locationError =
              'Please enable location in your device settings for emergency features';
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
        _locationError = 'Unable to access location: ${e.toString()}';
      });
    }
  }

  void _connectToWebSocket() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      print("Max reconnection attempts reached");
      return;
    }

    try {
      final wsUrl = 'ws://10.0.2.2/ws';
      print("Connecting to WebSocket at: $wsUrl");

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      setState(() {
        _isConnected = true;
        _reconnectAttempts = 0; // Reset on successful connection
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
          _scheduleReconnect();
        },
        onError: (error) {
          print("WebSocket error: $error");
          setState(() {
            _isConnected = false;
          });
          _scheduleReconnect();
        },
      );
    } catch (e) {
      print("WebSocket connection failed: $e");
      setState(() {
        _isConnected = false;
      });
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(
      Duration(seconds: 5 * (_reconnectAttempts + 1)), // Exponential backoff
      () {
        if (!_isConnected) {
          _reconnectAttempts++;
          print("Reconnecting WebSocket... Attempt $_reconnectAttempts");
          _connectToWebSocket();
        }
      },
    );
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
      // Reconnect if there's an error sending data
      if (_isConnected) {
        setState(() {
          _isConnected = false;
        });
        _scheduleReconnect();
      }
    }
  }

  Future<bool> _sendSosAlert() async {
    try {
      if (_currentPosition == null) {
        await _getCurrentLocation();
        if (_currentPosition == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Unable to get location. Please enable location services.'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
      }

      // Default emergency contact (you might want to get this from user settings)
      const String emergencyContact = "9082532164";

      final Uri uri = Uri.parse('http://10.0.2.2/send-sos').replace(
        queryParameters: {
          'lat': _currentPosition!.latitude.toString(),
          'lon': _currentPosition!.longitude.toString(),
          'contact': emergencyContact,
        },
      );

      final response = await http.post(uri);

      // Handle 307 redirect
      if (response.statusCode == 307) {
        final String? redirectUrl = response.headers['location'];
        if (redirectUrl != null) {
          final Uri newUrl = Uri.parse(redirectUrl);
          final newResponse = await http.post(
            newUrl,
            headers: {'Content-Type': 'application/json'},
          );

          if (newResponse.statusCode == 200 || newResponse.statusCode == 201) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('SOS alert sent successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            return true;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to send SOS alert. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
            return false;
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Redirect URL not found'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
      } else if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SOS alert sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send SOS alert. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error. Please check your connection.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _channel?.sink.close();
    _reconnectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  children: [
                    CustomAppBar(
                      title: 'Home',
                      showCartIcon: false,
                    ),
                    if (_locationError.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _locationError,
                                style: TextStyle(color: Colors.red.shade800),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.refresh,
                                  color: Colors.red.shade800),
                              onPressed: _getCurrentLocation,
                            )
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const EmergencyContactsWidget(),
                          const SizedBox(height: 16),
                          const EmergencyServicesGrid(),
                          const SizedBox(height: 16),
                          SosButton(
                            onPressed: _sendSosAlert,
                          ),
                          if (_loadingLocation)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Getting location...",
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
