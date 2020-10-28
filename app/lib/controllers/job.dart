import 'package:app/models/job.dart';
import 'package:app/models/mechanic.dart';
import 'package:app/services/endpoints/job.dart';
import 'package:app/services/endpoints/mechanic.dart';
import 'package:get/state_manager.dart';

class JobController extends GetxController {
  JobService jobService;

  final job = Job().obs;

  final loading = false.obs;

  void onInit() {
    jobService = Get.find<JobService>();
  }

  void load(int id) {
    loading.value = true;
    jobService.get(id).then((m) {
      loading.value = false;
      job.value = m;
    })
    .catchError((error) {
      loading.value = false;
      throw error;
    });
  }
}
