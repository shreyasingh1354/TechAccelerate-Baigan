// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:url_launcher/url_launcher.dart';
// import 'package:geolocator/geolocator.dart';
// import 'geo_loc.dart'; // Import your location service

// // Hospital model class
// class Hospital {
//   final String name;
//   final String address;
//   final String contact;
//   final String locationUrl;

//   Hospital({
//     required this.name,
//     required this.address,
//     required this.contact,
//     required this.locationUrl,
//   });

//   factory Hospital.fromJson(Map<String, dynamic> json) {
//     return Hospital(
//       name: json['name'] ?? '',
//       address: json['address'] ?? '',
//       contact: json['contact'] != null ? json['contact'].toString() : '',
//       locationUrl: json['location_url'] ?? '',
//     );
//   }
// }

// // Hospital service to fetch data
// class HospitalService {
//   static final HospitalService _instance = HospitalService._internal();

//   factory HospitalService() {
//     return _instance;
//   }

//   HospitalService._internal();

//   // API endpoint - replace with your actual endpoint
//   final String apiUrl = 'http://65.0.61.170/get-hospitals';

//   // Fetch hospitals data by passing latitude and longitude
//   Future<List<Hospital>> fetchHospitals(double lat, double lon) async {
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: json.encode({
//           'lat': lat,
//           'lon': lon,
//         }),
//       );
      
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> responseData = json.decode(response.body);
//         final List<dynamic> data = responseData['hospitals'];
//         return data.map((item) => Hospital.fromJson(item)).toList();
//       } else {
//         throw Exception('Failed to load hospitals: ${response.statusCode}');
//       }
//     } catch (e) {
//       print("Error fetching hospitals: $e");
//       // For testing only - load sample data when API fails
//       return _loadSampleData();
//     }
//   }

//   // Sample data for testing
//   List<Hospital> _loadSampleData() {
//     final String sampleJson = '''
//     {
//       "hospitals": [
//         {
//           "name": "Chaitanya Eye Hospital",
//           "address": "AS Rama Rao Road, Moghalraja Puram, Vijayawada - 520010, Andhra Pradesh, India",
//           "contact": "08662475153; 2485868",
//           "location_url": "https://www.google.com/maps?q=16.504254300081598,80.6476515"
//         },
//         {
//           "name": "V.G.R. Diabetes Specialities Hospital",
//           "address": "AS Rama Rao Road, Moghalraja Puram, Vijayawada - 520010, Andhra Pradesh, India",
//           "contact": "",
//           "location_url": "https://www.google.com/maps?q=16.50576250008177,80.6468676"
//         },
//         {
//           "name": "Maxivision Eye Hospital",
//           "address": "MG Road, Labbipet, Vijayawada - 520010, Andhra Pradesh, India",
//           "contact": "08662495933",
//           "location_url": "https://www.google.com/maps?q=16.50023010008115,80.64853189999998"
//         },
//         {
//           "name": "Prashant Hospital",
//           "address": "MG Road, Labbipet, Vijayawada - 520010, Andhra Pradesh, India",
//           "contact": "",
//           "location_url": "https://www.google.com/maps?q=16.500506600081188,80.64394269999998"
//         },
//         {
//           "name": "S V R Neuro & Trauma Hospital",
//           "address": "Jammi Chettu Street, Labbipet, Vijayawada - 520002, Andhra Pradesh, India",
//           "contact": "08662435555; 2433939",
//           "location_url": "https://www.google.com/maps?q=16.504044000081578,80.6425358"
//         }
//       ]
//     }
//     ''';
    
//     final Map<String, dynamic> responseData = json.decode(sampleJson);
//     final List<dynamic> data = responseData['hospitals'];
//     return data.map((item) => Hospital.fromJson(item)).toList();
//   }
// }

// // Hospital card component
// class HospitalCard extends StatelessWidget {
//   final Hospital hospital;
//   final VoidCallback onLocationTap;
//   final VoidCallback? onCallTap;

//   const HospitalCard({
//     Key? key,
//     required this.hospital,
//     required this.onLocationTap,
//     this.onCallTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16.0),
//       elevation: 4.0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12.0),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               hospital.name,
//               style: const TextStyle(
//                 fontSize: 18.0,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8.0),
//             Text(
//               hospital.address,
//               style: const TextStyle(
//                 fontSize: 14.0,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 16.0),
//             Row(
//               children: [
//                 if (hospital.contact.isNotEmpty) ...[
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       icon: const Icon(Icons.call, size: 16.0),
//                       label: const Text('Call'),
//                       onPressed: onCallTap,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         foregroundColor: Colors.white,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8.0),
//                 ],
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     icon: const Icon(Icons.location_on, size: 16.0),
//                     label: const Text('Location'),
//                     onPressed: onLocationTap,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                       foregroundColor: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Hospital list with built-in fetching logic using geo_loc.dart
// class HospitalList extends StatefulWidget {
//   const HospitalList({Key? key}) : super(key: key);

//   @override
//   State<HospitalList> createState() => _HospitalListState();
// }

// class _HospitalListState extends State<HospitalList> {
//   final HospitalService _hospitalService = HospitalService();
//   List<Hospital> _hospitals = [];
//   bool _isLoading = true;
//   String _errorMessage = '';
//   Position? _userLocation;

//   @override
//   void initState() {
//     super.initState();
//     _getLocationAndFetchHospitals();
//   }

//   Future<void> _getLocationAndFetchHospitals() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     try {
//       // Use your geo_loc.dart function to get the location
//       final position = await fetchLocation();
      
//       if (position == null) {
//         setState(() {
//           _errorMessage = 'Unable to get your location. Please check app permissions.';
//           _isLoading = false;
//         });
//         return;
//       }
      
//       _userLocation = position;
      
//       // Fetch hospitals with user location
//       final hospitals = await _hospitalService.fetchHospitals(
//         position.latitude, 
//         position.longitude
//       );
      
//       setState(() {
//         _hospitals = hospitals;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _launchUrl(String url) async {
//     final Uri uri = Uri.parse(url);
//     if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Could not launch $url')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
    
//     if (_errorMessage.isNotEmpty && _hospitals.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               _errorMessage,
//               style: const TextStyle(color: Colors.red),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _getLocationAndFetchHospitals,
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }
    
//     return Column(
//       children: [
//         if (_userLocation != null)
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Text(
//               'Showing hospitals near: ${_userLocation!.latitude.toStringAsFixed(4)}, ${_userLocation!.longitude.toStringAsFixed(4)}',
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         Expanded(
//           child: ListView.builder(
//             padding: const EdgeInsets.all(16.0),
//             itemCount: _hospitals.length,
//             itemBuilder: (context, index) {
//               final hospital = _hospitals[index];
//               return HospitalCard(
//                 hospital: hospital,
//                 onLocationTap: () => _launchUrl(hospital.locationUrl),
//                 onCallTap: hospital.contact.isNotEmpty
//                     ? () => _launchUrl('tel:${hospital.contact.split(';').first.trim()}')
//                     : null,
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }