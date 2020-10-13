import 'package:get/state_manager.dart';

import 'package:app/models/user.dart';

class AppController extends GetxController {
  final profileType = ProfileType.Undefined.obs;
  final onboardingSkipped = false.obs;

  final navIndex = 0.obs;
}
