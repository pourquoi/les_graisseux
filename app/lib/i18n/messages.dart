import 'package:get/route_manager.dart';
import 'package:app/i18n/fr.dart' as fr;
import 'package:app/i18n/en.dart' as en;

void _flattenJson(dynamic json, Map<String, String> flatten, {String prefix=''}) {
  json.forEach((key, value) {
    if (value is Map) _flattenJson(value, flatten, prefix: '$prefix$key.');
    else flatten['$prefix$key'] = value.toString();
  });
}

Map<String, String> flattenJson(Map<String, dynamic> json) {
  Map<String, String> flatten = {};
  _flattenJson(json, flatten);
  return flatten;
}

class Messages extends Translations {
  Map<String, Map<String, String>> get keys => {
    'fr': flattenJson(fr.messages),
    'en': flattenJson(en.messages),
  };
}
