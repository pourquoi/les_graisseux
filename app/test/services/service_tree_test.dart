import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import 'package:app/services/api.dart';
import 'package:app/services/service_tree.dart';
import 'package:app/models/service_tree.dart';

class MockApi extends Mock implements ApiService {}

void main() {
  MockApi mockApi = MockApi();
  ServiceTreeService service = ServiceTreeService();
  service.api = mockApi;

  test('ServiceTree.search', () {
    when(mockApi.get(any, queryParameters: anyNamed('queryParameters')))
        .thenAnswer((_) async => {
              "@context": "/api/contexts/Service",
              "@id": "/api/services",
              "@type": "hydra:Collection",
              "hydra:member": [
                {
                  "@id": "/api/services/61",
                  "@type": "Service",
                  "id": 61,
                  "label": "Kristoffer Huels Jr.",
                  "description":
                      "Rerum accusamus beatae dolores enim et doloribus voluptatibus.",
                  "children": [],
                  "parent": null
                },
                {
                  "@id": "/api/services/62",
                  "@type": "Service",
                  "id": 62,
                  "label": "Hulda Bergnaum",
                  "description":
                      "Odit omnis vel excepturi similique. Quas beatae et nam itaque.",
                  "children": [],
                  "parent": null
                },
              ],
              "hydra:totalItems": 2,
            });

    expect(
        service.search().then((PaginatedQueryResponse<ServiceTree> r) {
          expect(r.total, 2);
        }),
        completes);
  });
}
