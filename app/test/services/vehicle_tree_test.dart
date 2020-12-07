import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import 'package:app/models/vehicle_tree.dart';
import 'package:app/services/endpoints/vehicle_tree.dart';
import 'package:app/services/api.dart';
import 'package:app/services/crud.dart';

class MockApi extends Mock implements ApiService {}

void main() {
  MockApi mockApi = MockApi();
  VehicleTreeService service = VehicleTreeService();
  service.api = mockApi;

  test('ServiceTree.search', () {
    when(mockApi.get(any, queryParameters: anyNamed('queryParameters')))
        .thenAnswer((_) async => {
              "@context": "/api/contexts/Vehicle",
              "@id": "/api/vehicles",
              "@type": "hydra:Collection",
              "hydra:member": [
                {
                  "@id": "/api/vehicles/60940",
                  "@type": "Vehicle",
                  "id": 60940,
                  "level": "brand",
                  "name": "Monty Watsica",
                  "children": [
                    {
                      "@id": "/api/vehicles/60959",
                      "@type": "Vehicle",
                      "id": 60959,
                      "level": "family",
                      "name": "Camden Ledner",
                      "parent": "/api/vehicles/60940",
                      "children": []
                    }
                  ]
                },
                {
                  "@id": "/api/vehicles/60941",
                  "@type": "Vehicle",
                  "id": 60941,
                  "level": "brand",
                  "name": "Maude Zulauf PhD",
                  "children": [
                    {
                      "@id": "/api/vehicles/60951",
                      "@type": "Vehicle",
                      "id": 60951,
                      "level": "family",
                      "name": "Caitlyn Wisoky II",
                      "parent": "/api/vehicles/60941",
                      "children": []
                    }
                  ]
                }
              ],
              "hydra:totalItems": 2,
            });

    expect(
        service.search(PaginatedQueryParameters()).then((PaginatedQueryResponse<VehicleTree> r) {
          expect(r.total, 2);
        }),
        completes);
  });
}
