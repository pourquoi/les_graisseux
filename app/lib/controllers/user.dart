import 'package:app/services/api.dart';
import 'package:app/services/endpoints/user.dart';
import 'package:get/state_manager.dart';
import 'package:meta/meta.dart';
import 'package:app/models/user.dart';
import 'package:get_storage/get_storage.dart';

enum UserStatus { anonymous, loggedin, loggedout }

class UserController extends GetxController {
  ApiService api;
  UserService userService;

  final token = ''.obs;
  final user = User().obs;
  final loading = false.obs;
  final status = UserStatus.anonymous.obs;

  void onInit() {
  }

  Future<UserController> bootstrap() async {
    api = Get.find<ApiService>();
    userService = Get.find<UserService>();

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
      api.token = token;
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
    loading.value = true;
    return api.post('/api/users',
        data: {'email': email, 'password': password}).then((data) {
      user.value = User.fromJson(data);
      return login(email: email, password: password);
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
