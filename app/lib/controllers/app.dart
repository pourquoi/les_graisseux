import 'package:get/get.dart';
import 'package:app/models/user.dart';
import 'package:get_storage/get_storage.dart';

class AppController extends GetxController {
  final profileType = ProfileType.Undefined.obs;
  final onboardingSkipped = false.obs;

  final navIndex = 0.obs;

  void onInit() {
    profileType.listen((_) {
      saveToStorage();
    });

    onboardingSkipped.listen((_) {
      saveToStorage();
    });
  }

  void onClose() {
    saveToStorage();
    super.onClose();
  }

  Future bootstrap() async {
    await loadFromStorage();
  }

  Future loadFromStorage() async {
    GetStorage box = GetStorage();
    String storedProfile = box.read("app.profile_type");

    ProfileType.values.forEach((type) { 
      if (type.toString() == storedProfile) {
        profileType.value = type;
      }
    });

    bool storedOnboardingSkipped = box.read<bool>("app.onboarding_skipped");
    if (storedOnboardingSkipped != null) onboardingSkipped.value = storedOnboardingSkipped;
  }

  Future saveToStorage() async {
    GetStorage box = GetStorage();
    box.write("app.profile_type", profileType.value.toString());
    box.write("app.onboarding_skipped", onboardingSkipped.value);
  }

  void toggleProfile() {
    if (profileType.value == ProfileType.Mechanic) {
      profileType.value = ProfileType.Customer;
    } else {
      profileType.value = ProfileType.Mechanic;
    }
  }
}
