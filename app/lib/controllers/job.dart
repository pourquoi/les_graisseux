import 'package:app/controllers/user.dart';
import 'package:app/models/job.dart';
import 'package:app/models/job_application.dart';
import 'package:app/models/mechanic.dart';
import 'package:app/services/endpoints/job.dart';
import 'package:app/services/endpoints/mechanic.dart';
import 'package:get/state_manager.dart';

class JobController extends GetxController {
  JobService jobService;
  UserController userController;

  final job = Job().obs;
  final loading = false.obs;

  void onInit() {
    jobService = Get.find<JobService>();
    userController = Get.find<UserController>();
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

  Future<JobApplication> apply({Mechanic mechanic, Job targetJob}) {
    Job _job = targetJob ?? job.value;
    Mechanic _mechanic = mechanic ?? userController.user.value.mechanic; 

    return jobService.apply(_job.hydraId, _mechanic.hydraId).then((app) {
      _job.application = app;
      if (_job.id == job.value.id) job.refresh();
      return app;
    });
  }
}
