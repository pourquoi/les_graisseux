import 'package:app/models/user.dart';
import 'package:app/services/crud_service.dart';
import 'package:get_storage/get_storage.dart';
import 'package:meta/meta.dart';
import 'package:get/state_manager.dart';

import 'package:app/services/api.dart';

enum UserStatus { anonymous, loggedin, loggedout }

class UserService extends CrudService {
  final token = ''.obs;
  final user = User().obs;
  final loading = false.obs;
  final status = UserStatus.anonymous.obs;

  ApiService api;

  User fromJson(m) => User.fromJson(m);

  UserService() : super(resource: 'users') {
    token.nil();
  }

  Future<UserService> init() async {
    api = Get.find<ApiService>();
    api.token = token;

    GetStorage box = GetStorage();
    String storedToken = box.read("token");
    int storedUserId = box.read("user.id");

    if (storedToken != null && storedUserId != null) {
      token.value = storedToken;
      user.update((value) {
        value.id = storedUserId;
        value.email = box.read("user.email");
        value.username = box.read("user.username");
      });
      await refresh();
    } else {
      await logout();
    }

    return this;
  }

  Future login({@required String email, @required String password}) async {
    loading.value = true;
    return api.post('/authentication_token',
        data: {'email': email, 'password': password}).then((data) {
      token.value = data['token'];
      user.value.id = data['uid'];
      return refresh();
    }).catchError((error) {
      token.nil();
      status.value = UserStatus.anonymous;
      loading.value = false;
      throw error;
    });
  }

  Future logout() async {
    token.nil();
    status.value = UserStatus.loggedout;
  }

  Future register({@required String email, @required String password}) async {
    token.nil();
    loading.value = false;
    return api.post('/api/users',
        data: {'email': email, 'password': password}).then((data) {
      user.value = User.fromJson(data);
      loading.value = false;
    }).catchError((error) {
      loading.value = false;
      status.value = UserStatus.anonymous;
      throw error;
    });
  }

  Future refresh() async {
    loading.value = true;
    return api.get('/api/users/${user.value.id}').then((data) {
      user.value = User.fromJson(data);
      status.value = UserStatus.loggedin;
      loading.value = false;
    }).catchError((error) {
      token.nil();
      status.value = UserStatus.loggedout;
      loading.value = false;
      throw error;
    });
  }
}
