import 'dart:convert';
import 'dart:io';

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

class PlaceApiProvider extends GetxService {
  final client = Client();

  PlaceApiProvider();

  String sessionToken;

  void onInit() {
    initSession();
  }

  static final String androidKey = GOOGLE_PLACE_API_KEY;
  static final String iosKey = GOOGLE_PLACE_API_KEY;
  final apiKey = Platform.isAndroid ? androidKey : iosKey;

  void initSession() {
    sessionToken = Uuid().v4();
  }

  Future<List<Suggestion>> fetchSuggestions(String input, {String lang = 'fr'}) async {
    final request =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=address&language=$lang&components=country:fr&key=$apiKey&sessiontoken=$sessionToken';
    final response = await client.get(request);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        // compose suggestions in a list
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

  Future<Place> getPlaceDetailFromId(String placeId) async {
    final request =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=address_component,geometry&key=$apiKey&sessiontoken=$sessionToken';
    final response = await client.get(request);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        print(result['result']);
        final components =
            result['result']['address_components'] as List<dynamic>;
        // build result
        final place = Place();
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
        final geometry = 
            result['result']['geometry'] as Map<String, dynamic>;
        
        if (geometry.containsKey('location')) {
          place.latitude = geometry['location']['lat'];
          place.longitude = geometry['location']['lng'];
        }
        return place;
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }
}