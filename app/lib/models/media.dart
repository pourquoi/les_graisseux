import 'package:app/models/common.dart';

class Media extends HydraResource
{
  int id;
  String url;

  Media({this.url});

  Media.fromJson(Map<String, dynamic> json, {Map<String, dynamic> context}) { 
    parseJson(json, context: context);
  }

  void parseJson(Map<String, dynamic> json,
      {Map<String, dynamic> context}) {
    if (context == null) context = initContext();
    super.parseJson(json, context: context);

    id = json['id'];
    url = json['content_url'];

    context[CTX_MAP_BY_IDS][json['@id']] = this;
  }
}