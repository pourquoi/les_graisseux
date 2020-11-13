import 'package:app/models/mechanic.dart';
import 'package:app/services/crud_service.dart';
import 'package:app/services/endpoints/mechanic.dart';
import 'package:get/state_manager.dart';

class MechanicsController extends GetxController {
  MechanicService mechanicService;

  final items = [].obs;
  final pagination = PaginatedQueryResponse<Mechanic>().obs;
  final params = MechanicQueryParameters().obs;
  final loading = false.obs;

  void onInit() {
    mechanicService = Get.find<MechanicService>();
  }

  Future<void> load() {
    loading.value = true;
    return mechanicService.search(params.value).then((response) {
      pagination.value = response;
      items.value = response.items;
      loading.value = false;
    }).catchError((error) {
      loading.value = true;
      throw error;
    });
  }

  Future<void> more() {
    if (pagination.value.next != null) {
      return mechanicService.next(pagination.value).then((response) {
        pagination.value = response;
        items.addAll(response.items);
      });
    }
  }
}
