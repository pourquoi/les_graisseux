import 'package:app/models/mechanic.dart';
import 'package:app/services/mechanic.dart';
import 'package:get/state_manager.dart';

class MechanicController extends GetxController {
  MechanicService mechanicService;

  final current = Mechanic().obs;

  final loading = false.obs;

  void onInit() {
    mechanicService = Get.find<MechanicService>();
  }

  void load(int id) {
    loading.value = true;
    mechanicService.get(id).then((m) {
      loading.value = false;
      current.value = m;
    })
    .catchError((error) {
      loading.value = false;
      throw error;
    });
  }
}
