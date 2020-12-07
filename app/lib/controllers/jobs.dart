import 'package:app/models/job.dart';
import 'package:app/services/crud.dart';
import 'package:app/services/endpoints/job.dart';
import 'package:get/state_manager.dart';

class JobsController extends GetxController {
  final items = [].obs;
  final params = JobQueryParameters().obs;
  final loading = false.obs;

  final pagination = PaginatedQueryResponse<Job>().obs;

  JobService _crud;

  void onInit() {
    _crud = Get.find<JobService>();
    //ever(params, (_) => load());
  }

  Future load() async {
    pagination.value = PaginatedQueryResponse<Job>();
    loading.value = true;
    try {
      pagination.value = await _crud.search(params.value);
      items.value = pagination.value.items;
    } catch(err) {
    } finally {
      loading.value = false;
    }
  }

  Future more() async {
    if (pagination.value.next != null) {
      loading.value = true;
      try {
        pagination.value = await _crud.next(pagination.value);
        items.addAll(pagination.value.items);
      } catch(err) {
      } finally {
        loading.value = false;
      }
    }
  }

  Future sortBy(String sort) async {
    params.value.sort = sort;
    params.refresh();
    return await load();
  }
}
