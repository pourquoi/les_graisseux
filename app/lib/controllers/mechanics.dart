import 'package:app/models/mechanic.dart';
import 'package:app/services/crud.dart';
import 'package:app/services/endpoints/mechanic.dart';
import 'package:get/state_manager.dart';

class MechanicsController extends GetxController {
  MechanicService _crud;

  final items = [].obs;
  final pagination = PaginatedQueryResponse<Mechanic>().obs;
  final params = MechanicQueryParameters().obs;
  final loading = false.obs;

  void onInit() {
    _crud = Get.find<MechanicService>();
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

  Future more() async {
    if (pagination.value.next != null) {
      loading.value = true;
      try {
        pagination.value = await _crud.next(pagination.value);
        items.addAll(pagination.value.items);
      } catch(err) {
      } finally {
        loading.value = false;
      }
    }
  }

  Future sortBy(String sort) async {
    params.value.sort = sort;
    params.refresh();
    return await load();
  }
}
