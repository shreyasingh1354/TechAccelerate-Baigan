import 'package:geolocator/geolocator.dart';

Future<Position?> fetchLocation() async {
  try {
    // Check the current permission status.
    LocationPermission permission = await Geolocator.checkPermission();

    // Request permission if not granted.
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Location permission denied.");
        return null;
      }
    }

    // If permission is permanently denied, inform the user.
    if (permission == LocationPermission.deniedForever) {
      print("Location permission permanently denied.");
      return null;
    }

    // Fetch the current position.
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    
    print("User's Location: Latitude: ${position.latitude}, Longitude: ${position.longitude}");
    return position;
  } catch (e) {
    print("Error fetching location: $e");
    return null;
  }
}