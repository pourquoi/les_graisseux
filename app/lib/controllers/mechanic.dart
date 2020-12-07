import 'package:app/models/mechanic.dart';
import 'package:app/services/endpoints/mechanic.dart';
import 'package:get/state_manager.dart';

class MechanicController extends GetxController {
  MechanicService mechanicService;

  final mechanic = Mechanic().obs;

  final loading = false.obs;

  void onInit() {
    mechanicService = Get.find<MechanicService>();
  }

  Future load(int id) async {
    loading.value = true;
    try {
      mechanic.value = await mechanicService.get(id);
      loading.value = false;
    } catch(err) {
    } finally {
      loading.value = false;
    }
  }
}
