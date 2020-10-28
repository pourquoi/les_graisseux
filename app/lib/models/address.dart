import 'package:app/models/common.dart';
import 'package:app/services/google/place_service.dart';

class Address extends HydraResource
{
  int id;

  String country;
  String locality;
  String postalCode;
  String street;

  double latitude;
  double longitude;

  Address({this.country, this.locality, this.postalCode, this.street, this.latitude, this.longitude});

  bool get geolocated => latitude != null && longitude != null;

  String toString() {
    return (street != null ? street + ', ' : '') + (locality != null ? locality + ' ' : '') + (country != null ? country.toUpperCase() : '');
  }

  Address.fromJson(Map<String, dynamic> json, {Map<String, dynamic> context}) { 
    parseJson(json, context: context); 
  }

  Address.fromPlace(Place place) {
    country = place.country;
    locality = place.city;
    postalCode = place.zipCode;
    if (place.streetNumber != null) street = place.streetNumber;
    if (place.street != null) street = (street != null ? street + ' ' : '') + place.street;
    latitude = place.latitude;
    longitude = place.longitude;
  }

  void parseJson(Map<String, dynamic> json, {Map<String, dynamic> context}) {
    if (context == null) context = initContext();
    super.parseJson(json, context: context);

    id = json['id'];
    country = json['country'];
    locality = json['locality'];
    postalCode = json.containsKey('postal_code') ? json['postal_code'] : null;
    street = json.containsKey('street') ? json['street'] : null;
    latitude = json.containsKey('latitude') ? json['latitude'] : null;
    longitude = json.containsKey('longitude') ? json['longitude'] : null;

    context[CTX_MAP_BY_IDS][json['@id']] = this;
  }

  Map<String, dynamic> toJson({Map<String, dynamic> context}) {
    Map<String, dynamic> data = {
      'id': id,
      'country': country,
      'locality': locality,
      'postal_code': postalCode,
      'street': street,
      'latitude': latitude,
      'longitude': longitude
    };

    return data..addAll(super.toJson(context: context));
  }
}