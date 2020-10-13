import 'package:get/state_manager.dart';
import 'package:app/services/vehicle_tree.dart';

class VehiclesController extends GetxController {
  VehicleTreeService vehicleTreeService;

  final items = [].obs;

  final loading = false.obs;

  void onInit() {
    vehicleTreeService = Get.find<VehicleTreeService>();

    search(level: VehicleTreeLevel.brand);
  }

  void search({String q, VehicleTreeLevel level}) {
    loading.value = true;
    vehicleTreeService.search(VehicleTreeQueryParameters(q: q)).then((response) {
      items.value = response.items;
      loading.value = false;
    }).catchError((error) {
      loading.value = true;
      throw error;
    });
  }
}
