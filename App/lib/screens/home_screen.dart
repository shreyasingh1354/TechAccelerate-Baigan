import 'package:baigan/theme/app_colors.dart';
import 'package:baigan/widgets/profile_info_widget.dart';
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
          title: 'Home',
          showCartIcon: false,
        ),
        backgroundColor: Colors.grey.shade300,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add a title for emergency contacts
              const Text(
                'Emergency Contacts',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      blurRadius: 3.0,
                      color: Colors.black26,
                      offset: Offset(1.0, 1.0),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10),

// Replace the Row with a SingleChildScrollView for horizontal scrolling
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ProfileInfoWidget(
                        name: 'Aryan', imgPath: 'assets/images/profile2.jpg'),
                    const SizedBox(width: 10), // Add spacing between widgets
                    ProfileInfoWidget(
                        name: 'Shreya', imgPath: 'assets/images/profile1.jpg'),
                    const SizedBox(width: 10),
                    ProfileInfoWidget(
                        name: 'Nithish', imgPath: 'assets/images/profile3.jpg'),
                    const SizedBox(width: 10),
                    ProfileInfoWidget(
                        name: 'Maheep', imgPath: 'assets/images/profile4.jpg'),
                    const SizedBox(width: 10),
                    ProfileInfoWidget(
                        name: 'Parth', imgPath: 'assets/images/profile5.jpg'),
                  ],
                ),
              ),

              // Add this below the SingleChildScrollView section
              const SizedBox(height: 30),

              // Section title with enhanced styling
              Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.emergency,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Emergency Services',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 1.0,
                        shadows: [
                          Shadow(
                            blurRadius: 2.0,
                            color: Colors.black12,
                            offset: Offset(0.5, 0.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

// Container for the GridView with proper styling
              Container(
                height: 280, // Fixed height for the grid
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.8, // Adjust for better proportions
                  ),
                  itemCount: 5, // Number of emergency services
                  itemBuilder: (context, index) {
                    // List of names and image paths
                    final List<String> names = [
                      'Police',
                      'Hospital',
                      'Fire',
                      'Ambulance',
                      'Emergency',
                    ];
                    final List<IconData> icons = [
                      Icons.local_police,
                      Icons.local_hospital,
                      Icons.local_fire_department,
                      Icons.emergency,
                      Icons.warning_amber,
                    ];
                    final List<Color> colors = [
                      Colors.blue,
                      Colors.red,
                      Colors.orange,
                      Colors.green,
                      Colors.purple,
                    ];

                    return Container(
                      decoration: BoxDecoration(
                        color: colors[index].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: colors[index].withOpacity(0.3)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: colors[index].withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              icons[index],
                              color: colors[index],
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            names[index],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              // color: ,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              Spacer(),

              Center(
                child: ElevatedButton(
                  clipBehavior: Clip.antiAlias,
                  style: ElevatedButton.styleFrom(
                    overlayColor: Colors.red,
                    backgroundColor: Colors.red.withOpacity(0.4),
                    fixedSize: const Size(100, 100),
                    shape: const CircleBorder(),
                    elevation: 18,
                    shadowColor: Colors.red,
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () {
                    // Get.toNamed(AppPage.getProfile());
                  },
                  child: const Text(
                    'SOS',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.white),
                  ),
                ),
              )

              //               // Connection Status
              //               Card(
              //                 elevation: 4,
              //                 child: Padding(
              //                   padding: const EdgeInsets.all(16.0),
              //                   child: Column(
              //                     crossAxisAlignment: CrossAxisAlignment.start,
              //                     children: [
              //                       const Text(
              //                         'WebSocket Status',
              //                         style: TextStyle(
              //                           fontSize: 18,
              //                           fontWeight: FontWeight.bold,
              //                         ),
              //                       ),
              //                       const SizedBox(height: 10),
              //                       Row(
              //                         children: [
              //                           Container(
              //                             width: 12,
              //                             height: 12,
              //                             decoration: BoxDecoration(
              //                               color: _isConnected ? Colors.green : Colors.red,
              //                               shape: BoxShape.circle,
              //                             ),
              //                           ),
              //                           const SizedBox(width: 8),
              //                           Text(
              //                             _isConnected
              //                                 ? 'Connected to Server'
              //                                 : 'Disconnected',
              //                             style: TextStyle(
              //                               color: _isConnected ? Colors.green : Colors.red,
              //                               fontWeight: FontWeight.bold,
              //                             ),
              //                           ),
              //                         ],
              //                       ),
              //                       const SizedBox(height: 10),
              //                       Text('Last Response: $_lastMessage',
              //                           style: TextStyle(fontSize: 12)),
              //                     ],
              //                   ),
              //                 ),
              //               ),

              //               const SizedBox(height: 16),

              //               // Real Accelerometer Data
              //               Card(
              //                 elevation: 4,
              //                 child: Padding(
              //                   padding: const EdgeInsets.all(16.0),
              //                   child: Column(
              //                     crossAxisAlignment: CrossAxisAlignment.start,
              //                     children: [
              //                       const Text(
              //                         'Real Accelerometer Data',
              //                         style: TextStyle(
              //                           fontSize: 18,
              //                           fontWeight: FontWeight.bold,
              //                         ),
              //                       ),
              //                       const SizedBox(height: 10),
              //                       Row(
              //                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //                         children: [
              //                           _sensorValueBox('X', _xValue.toStringAsFixed(3)),
              //                           _sensorValueBox('Y', _yValue.toStringAsFixed(3)),
              //                           _sensorValueBox('Z', _zValue.toStringAsFixed(3)),
              //                         ],
              //                       ),
              //                     ],
              //                   ),
              //                 ),
              //               ),

              //               const SizedBox(height: 16),

              //               // Location Data
              //               Card(
              //                 elevation: 4,
              //                 child: Padding(
              //                   padding: const EdgeInsets.all(16.0),
              //                   child: Column(
              //                     crossAxisAlignment: CrossAxisAlignment.start,
              //                     children: [
              //                       const Text(
              //                         'Current Location',
              //                         style: TextStyle(
              //                           fontSize: 18,
              //                           fontWeight: FontWeight.bold,
              //                         ),
              //                       ),
              //                       const SizedBox(height: 10),
              //                       if (_loadingLocation)
              //                         const Center(child: CircularProgressIndicator())
              //                       else if (_locationError.isNotEmpty)
              //                         Text(
              //                           _locationError,
              //                           style: const TextStyle(color: Colors.red),
              //                         )
              //                       else if (_currentPosition != null)
              //                         Column(
              //                           children: [
              //                             _locationInfoRow(
              //                                 'Latitude', '${_currentPosition!.latitude}°'),
              //                             const SizedBox(height: 8),
              //                             _locationInfoRow('Longitude',
              //                                 '${_currentPosition!.longitude}°'),
              //                             const SizedBox(height: 8),
              //                             _locationInfoRow('Altitude',
              //                                 '${_currentPosition!.altitude.toStringAsFixed(2)} m'),
              //                             const SizedBox(height: 8),
              //                             _locationInfoRow('Accuracy',
              //                                 '${_currentPosition!.accuracy.toStringAsFixed(2)} m'),
              //                           ],
              //                         )
              //                       else
              //                         const Text('Location not available'),
              //                       const SizedBox(height: 10),
              //                       ElevatedButton(
              //                         onPressed: _getCurrentLocation,
              //                         child: const Text('Refresh Location'),
              //                       ),
              //                     ],
              //                   ),
              //                 ),
              //               ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _sensorValueBox(String axis, String value) {
  //   return Column(
  //     children: [
  //       Text(axis, style: const TextStyle(fontWeight: FontWeight.bold)),
  //       Text(value),
  //     ],
  //   );
  // }

  // Widget _locationInfoRow(String label, String value) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [Text(label), Text(value)],
  //   );
  // }
}
