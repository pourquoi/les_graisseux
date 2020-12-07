import 'package:app/models/vehicle_tree.dart';
import 'package:app/services/crud.dart';
import 'package:get/state_manager.dart';
import 'package:app/services/endpoints/vehicle_tree.dart';

class VehiclesController extends GetxController {
  VehicleTreeService _crud;

  final items = [].obs;
  final loading = false.obs;
  final params = VehicleTreeQueryParameters().obs;
  final pagination = PaginatedQueryResponse().obs;
  final tree = Map<String, List<VehicleTree>>().obs;

  void onInit() {
    _crud = Get.find<VehicleTreeService>();
    load();
  }

  Future load() async {
    loading.value = true;
    try {
      pagination.value = await _crud.search(params.value);
      items.value = pagination.value.items;
    } catch(err) {
    } finally {
      loading.value = false;
    }
  }

  void buildTree() {
    VehicleTreeLevel.entries.forEach((level) {
      tree[level.key] = List<VehicleTree>();
    });

    items.forEach((item) {
      if (!tree.containsKey(item.level)) {
        tree[item.level] = List<VehicleTree>();
      }
      tree[item.level].add(item);
    });
  }
}
