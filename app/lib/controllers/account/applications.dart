import 'package:app/controllers/user.dart';
import 'package:app/models/job_application.dart';
import 'package:app/services/crud_service.dart';
import 'package:app/services/endpoints/job.dart';
import 'package:get/state_manager.dart';

class JobApplicationsController extends GetxController
{
  final items = List<JobApplication>().obs;
  final pagination = PaginatedQueryResponse<JobApplication>().obs;
  final params = JobApplicationQueryParameters().obs;
  final loading = false.obs;

  JobApplicationService _api;
  UserController _userController;

  void onInit() {
    _api = Get.put(JobApplicationService());
    _userController = Get.find<UserController>();
  }

  Future<void> load() {
    params.value = JobApplicationQueryParameters(mechanic: _userController.user.value.mechanic.id);

    loading.value = true;
    return _api.search(params.value).then((response) {
      pagination.value = response;
      items.value = pagination.value.items;
      loading.value = false;
    }).catchError((error) {
      loading.value = true;
    });
  }

  Future<void> more() {
    if (pagination.value.next != null) {
      loading.value = true;
      return _api.next(pagination.value).then((response) {
        loading.value = false;
        pagination.value = response;
        items.addAll(response.items);
      }).catchError((error) {
        loading.value = true;
      });
    }
  }
}