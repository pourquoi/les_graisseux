import 'package:app/controllers/user.dart';
import 'package:app/models/job_application.dart';
import 'package:app/services/crud.dart';
import 'package:app/services/endpoints/job.dart';
import 'package:get/state_manager.dart';

class JobApplicationsController extends GetxController
{
  final items = List<JobApplication>().obs;
  final pagination = PaginatedQueryResponse<JobApplication>().obs;
  final params = JobApplicationQueryParameters().obs;
  final loading = false.obs;

  JobApplicationService _crud;
  UserController _userController;

  void onInit() {
    _crud = Get.put(JobApplicationService());
    _userController = Get.find<UserController>();
  }

  Future<void> load() async {
    params.value = JobApplicationQueryParameters(mechanic: _userController.user.value.mechanic.id);
    loading.value = true;
    try {
      pagination.value = await _crud.search(params.value);
      items.value = pagination.value.items;
    } catch(err) {
    } finally {
      loading.value = false;
    }
  }

  Future<void> more() async {
    if (pagination.value.next != null) {
      loading.value = true;
      try {
        pagination.value = await _crud.next(pagination.value);
        items.addAll(pagination.value.items);
      } catch(err) {
      } finally {
        loading.value = true;
      }
    }
  }
}