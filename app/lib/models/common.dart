const CTX_MAP_BY_IDS = 'mapByIds';

class HydraResource {
  String hydraId;
  String hydraType;

  Map<String, dynamic> initContext() {
    return {CTX_MAP_BY_IDS: {}};
  }
}

class Geocoordinate {
  double latitude;
  double longitude;

  Geocoordinate({this.latitude, this.longitude});
}