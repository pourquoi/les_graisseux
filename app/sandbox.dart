import 'dart:convert';

void main() {
  String json =
      '{"hydra:member":[{"@id":"\/api\/services\/61","@type":"Service","id":61,"label":"Kristoffer Huels Jr.","description":"Rerum accusamus beatae dolores enim et doloribus voluptatibus. Quae sapiente quia suscipit doloribus cupiditate dolorem.","children":[],"parent":null}]}';
  Map<String, dynamic> data = jsonDecode(json);

  data['hydra:member'].map((m) {
    return m;
  });

  if (data.containsKey('hydra:member')) {
    print('data contains hydra:member');
  }
}
