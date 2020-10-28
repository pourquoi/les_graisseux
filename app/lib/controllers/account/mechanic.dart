import 'package:get/get.dart';

import 'package:app/models/user.dart';
import 'package:app/models/mechanic.dart';
import 'package:app/controllers/user.dart';
import 'package:app/services/endpoints/mechanic.dart';

class AccountMechanicController extends GetxController
{
  final mechanic = Mechanic().obs;
  final loading = false.obs;

  UserController _userController;
  MechanicService _mechanicService;

  void onInit() {
    _userController = Get.find<UserController>();
    _mechanicService = Get.find<MechanicService>();
  }

  void initMechanic() {
    mechanic.value = Mechanic();
  }

  Future load() async {
    User user = _userController.user.value;

    if (user.mechanic != null) {
      if(user.mechanic.id != null) {
        loading.value = true;
        return _mechanicService.get(user.mechanic.id)
          .then((m) {
            mechanic.value = m;
            loading.value = false;
            return m;
          })
          .catchError((error) {
            loading.value = false;
            throw error;
          });
      } else {
        mechanic.value = user.mechanic;
        return mechanic.value;
      }
    } else {
      initMechanic();
      return mechanic.value;
    }
  }

  Future submit() async {
    User user = _userController.user.value;

    mechanic.value.user = user;
    
    loading.value = true;
    if (user.mechanic == null || user.mechanic.id == null) {
      return _mechanicService.post(mechanic.value).then((m) {
        user.updateMechanic(m);
        mechanic.value = m;
        loading.value = false;
      })
      .catchError((error) {
        loading.value = false;
      });
    } else {
      return _mechanicService.put(mechanic.value.id, mechanic.value).then((m) {
        user.updateMechanic(m);
        mechanic.value = m;
        loading.value = false;
      })
      .catchError((error) {
        loading.value = false;
      });
    }
  }
}