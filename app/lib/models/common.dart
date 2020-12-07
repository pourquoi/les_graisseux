const CTX_MAP_BY_IDS = 'mapByIds';

class HydraResource {
  String hydraId;
  String hydraType;
  String subscriptionToken;

  HydraResource();

  bool get loaded => hydraId != null;

  Map<String, dynamic> initContext() {
    return {CTX_MAP_BY_IDS: {}};
  }

  void parseJson(Map<String, dynamic> json, {Map<String, dynamic> context}) {
    hydraId = json['@id'];
    hydraType = json['@type'];
    subscriptionToken = json['@subscription'];
  }

  Map<String, dynamic> toJson({Map<String, dynamic> context}) {
    return {
      '@id': hydraId,
      '@type': hydraType
    };
  }
}

class Geocoordinate {
  double latitude;
  double longitude;

  Geocoordinate({this.latitude, this.longitude});
}