import 'dart:convert';
import 'dart:io';
import 'package:meta/meta.dart';
import 'package:get/state_manager.dart';
import 'package:http/http.dart';
import 'package:uuid/uuid.dart';

import 'package:app/config.dart';

class Place {
  String country;
  String streetNumber;
  String street;
  String city;
  String zipCode;
  double latitude;
  double longitude;

  Place({
    this.streetNumber,
    this.street,
    this.city,
    this.zipCode,
  });

  @override
  String toString() {
    return 'Place(streetNumber: $streetNumber, street: $street, city: $city, zipCode: $zipCode)';
  }
}

class Suggestion {
  final String placeId;
  final String description;

  Suggestion(this.placeId, this.description);

  @override
  String toString() {
    return 'Suggestion(description: $description, placeId: $placeId)';
  }
}

/// Provider for Google Places API.
class PlaceApiProvider extends GetxService {
  final client = Client();

  static const endpoint = 'https://maps.googleapis.com/maps/api';

  PlaceApiProvider();

  /// The search session token. 
  /// One session token should be used for all the api calls made while the user is searching a place.
  String sessionToken;

  void onInit() {
    initSession();
  }

  static final String androidKey = GOOGLE_PLACE_API_KEY;
  static final String iosKey = GOOGLE_PLACE_API_KEY;
  final apiKey = Platform.isAndroid ? androidKey : iosKey;

  /// Regenerate the search session token.
  void initSession() {
    sessionToken = Uuid().v4();
  }

  Future<Suggestion> reverseGeocode({@required double lat, @required double lng}) async {
    final url = '$endpoint/geocode/json?latlng=$lat,$lng&key=$apiKey';
    final Response response = await client.get(url);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        return Suggestion(result['results'][0]['place_id'], result['results'][0]['formatted_address']);
        /*
        final place = Place();
        _parseComponents(place, result['results'][0]['address_components']);
        _parseGeometry(place, result['results'][0]['geometry']);
        return place;
        */
      } else {
        throw Exception('Reverse geocode call failed with status ${result['status']}');
      }
    } else {
      throw Exception('Reverse geocode call failed');
    }
  }

  /// Call Place Autocomplete and return parsed suggestions.
  /// https://developers.google.com/places/web-service/autocomplete
  Future<List<Suggestion>> fetchSuggestions(String input, {String lang = 'fr', String types='(regions)'}) async {
    final url = '$endpoint/place/autocomplete/json?input=$input&types=$types&language=$lang&components=country:fr&key=$apiKey&sessiontoken=$sessionToken';
    
    final Response response = await client.get(url);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      
      if (result['status'] == 'OK') {
        print(result['predictions']);
        return result['predictions']
            .map<Suggestion>((p) => Suggestion(p['place_id'], p['description']))
            .toList();
      }

      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }

      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  /// Call Place Autocomplete and return parsed suggestions.
  /// https://developers.google.com/places/web-service/details
  Future<Place> getPlaceDetailFromId(String placeId) async {
    final url = '$endpoint/place/details/json?place_id=$placeId&fields=address_component,geometry&key=$apiKey&sessiontoken=$sessionToken';
    final response = await client.get(url);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);

      if (result['status'] == 'OK') {
        final place = Place();
        _parseComponents(place, result['result']['address_components']);
        _parseGeometry(place, result['result']['geometry']);
        return place;
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  void _parseComponents(Place place, List<dynamic> components) {
    components.forEach((c) {
      final List type = c['types'];
      if (type.contains('country')) {
        place.country = c['short_name'];
      }
      if (type.contains('street_number')) {
        place.streetNumber = c['long_name'];
      }
      if (type.contains('route')) {
        place.street = c['long_name'];
      }
      if (type.contains('locality')) {
        place.city = c['long_name'];
      }
      if (type.contains('postal_code')) {
        place.zipCode = c['long_name'];
      }
    });
  }

  void _parseGeometry(Place place, Map<String, dynamic> geometry) {
    if (geometry.containsKey('location')) {
      place.latitude = geometry['location']['lat'];
      place.longitude = geometry['location']['lng'];
    }
  }
}