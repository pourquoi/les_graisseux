import 'package:app/models/job.dart';
import 'package:app/services/crud_service.dart';
import 'package:app/services/endpoints/job.dart';
import 'package:get/state_manager.dart';

class JobsController extends GetxController {
  final items = [].obs;
  final params = JobQueryParameters().obs;
  final loading = false.obs;

  final pagination = PaginatedQueryResponse<Job>().obs;

  JobService jobService;

  void onInit() {
    jobService = Get.find<JobService>();
  }

  Future<bool> load() {
    pagination.value = PaginatedQueryResponse<Job>();
    loading.value = true;
    return jobService.search(params.value).then((response) {
      pagination.value = response;
      items.value = pagination.value.items;
      loading.value = false;
      return true;
    }).catchError((error) {
      loading.value = true;
      return false;
    });
  }

  Future<bool> more() {
    if (pagination.value.next != null) {
      return jobService.next(pagination.value).then((response) {
        pagination.value = response;
        items.addAll(response.items);
        return true;
      });
    }
    return Future.value(false);
  }
}
