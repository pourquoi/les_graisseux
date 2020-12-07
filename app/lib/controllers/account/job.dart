import 'package:app/controllers/user.dart';
import 'package:app/models/customer.dart';
import 'package:app/models/job.dart';
import 'package:app/models/user.dart';
import 'package:app/services/endpoints/customer.dart';
import 'package:app/services/endpoints/job.dart';
import 'package:get/get.dart';

class AccountJobController extends GetxController {
  final job = Job().obs;
  final loading = false.obs;

  JobService _jobService;
  CustomerService _customerService;
  UserController _userController;

  void onInit() {
    _userController = Get.find<UserController>();
    _jobService = Get.find<JobService>();
    _customerService = Get.find<CustomerService>();
  }

  void initJob() async {
    job.value = Job();
  }

  void load(int id) {
    loading.value = true;
    _jobService.get(id).then((m) {
      loading.value = false;
      job.value = m;
    })
    .catchError((error) {
      loading.value = false;
      throw error;
    });
  }

  Future submit() async {
    User user = _userController.user.value;
    
    loading.value = true;

    if (user.customer == null) {
      Customer newCustomer = Customer(user: user);
      Customer customer;
      try {
        customer = await _customerService.post(newCustomer);
      } catch(error) {
        loading.value = false;
        throw error;
      }
      user.updateCustomer(customer);
    }

    job.value.customer = user.customer;

    return _jobService.post(job.value).then((job) {
      loading.value = false;
    }).catchError((error) {
      loading.value = false;
      throw error;
    });
  }
}