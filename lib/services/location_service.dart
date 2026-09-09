import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Handles fetching the device's current location and converting
/// coordinates into a readable place name.
class LocationService {
  /// Returns the current position, requesting permission if needed.
  /// Returns null if permission is denied or location is unavailable.
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );
    } catch (e) {
      // Fallback to last known position if current fix times out (e.g. on emulators)
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (_) {
        return null;
      }
    }
  }

  /// Converts coordinates into a readable "City, Country" string.
  /// Falls back to formatted coordinates if geocoding is unavailable.
  Future<String?> getPlaceName(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final city = (place.locality != null && place.locality!.isNotEmpty)
            ? place.locality
            : ((place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty)
                ? place.subAdministrativeArea
                : place.administrativeArea);
        final parts = [city, place.country]
            .where((s) => s != null && s.isNotEmpty)
            .join(', ');
        if (parts.isNotEmpty) return parts;
      }
    } catch (_) {}
    return '${latitude.toStringAsFixed(2)}°, ${longitude.toStringAsFixed(2)}°';
  }
}