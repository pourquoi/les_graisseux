import 'package:app/services/job.dart';
import 'package:get/state_manager.dart';

class JobsController extends GetxController {
  JobService jobService;

  final items = [].obs;

  final loading = false.obs;

  void onInit() {
    jobService = Get.find<JobService>();
    this.search();
  }

  void search({String q}) {
    loading.value = true;
    jobService.search(JobQueryParameters(q: q)).then((response) {
      items.value = response.items;
      loading.value = false;
    }).catchError((error) {
      loading.value = true;
      throw error;
    });
  }
}
