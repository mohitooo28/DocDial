import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart' as geo;

class LocationService {
  final loc.Location _location = loc.Location();

  Future<String> getLocationName() async {
    try {
      final loc.LocationData locationData = await _location.getLocation();
      double latitude = locationData.latitude!;
      double longitude = locationData.longitude!;

      // Get the location name from latitude and longitude
      List<geo.Placemark> placemarks =
          await geo.placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        geo.Placemark place = placemarks[0];
        return "${place.locality}, ${place.administrativeArea}, ${place.country}";
      }
      return "Location not found";
    } catch (e) {
      print("Error fetching location: $e");
      return "Error fetching location";
    }
  }
}
