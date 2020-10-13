import 'package:app/services/service_tree.dart';
import 'package:get/state_manager.dart';

class ServicesController extends GetxController {
  ServiceTreeService serviceTreeService;

  final items = [].obs;

  final loading = false.obs;

  void onInit() {
    serviceTreeService = Get.find<ServiceTreeService>();

    search();
  }

  void search({String q}) {
    loading.value = true;
    serviceTreeService.search(ServiceTreeQueryParameters()).then((response) {
      items.value = response.items;
      loading.value = false;
    }).catchError((error) {
      loading.value = true;
      throw error;
    });
  }
}
