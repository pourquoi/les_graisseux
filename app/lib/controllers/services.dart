import 'package:app/services/crud.dart';
import 'package:app/services/endpoints/service_tree.dart';
import 'package:get/state_manager.dart';

class ServicesController extends GetxController {
  ServiceTreeService _crud;

  final items = [].obs;
  final loading = false.obs;
  final params = ServiceTreeQueryParameters().obs;
  final pagination = PaginatedQueryResponse().obs;

  void onInit() {
    _crud = Get.find<ServiceTreeService>();
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
}
