import 'package:app/models/mechanic.dart';
import 'package:app/services/endpoints/mechanic.dart';
import 'package:get/state_manager.dart';

class MechanicsController extends GetxController {
  MechanicService mechanicService;

  final items = [].obs;

  final loading = false.obs;

  void onInit() {
    mechanicService = Get.find<MechanicService>();
    this.search();
  }

  void search({String q}) {
    loading.value = true;
    mechanicService.search(MechanicQueryParameters(q: q)).then((response) {
      print(response.items);
      items.value = response.items;
      loading.value = false;
    }).catchError((error) {
      loading.value = true;
      throw error;
    });
  }
}
