import 'package:app/controllers/user.dart';
import 'package:app/models/job.dart';
import 'package:app/models/job_application.dart';
import 'package:app/models/mechanic.dart';
import 'package:app/services/endpoints/job.dart';
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

  Future load(int id) async {
    loading.value = true;
    try {
      job.value = await jobService.get(id);
    } catch(err) {
    } finally {
      loading.value = false;
    }
  }

  Future<JobApplication> apply({Mechanic mechanic, Job targetJob}) async {
    Job _job = targetJob ?? job.value;
    Mechanic _mechanic = mechanic ?? userController.user.value.mechanic; 
    try {
      return await jobService.apply(_job.hydraId, _mechanic.hydraId);
    } catch(err) {
    } finally {
    }
  }
}
