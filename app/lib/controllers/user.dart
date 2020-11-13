import 'package:app/models/media.dart';
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

  Future bootstrap() async {
    api = Get.find<ApiService>();
    userService = Get.find<UserService>();
    api.token = token;
    await loadFromStorage();
  }

  Future loadFromStorage() async {
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
  }

  Future saveToStorage() async {
    GetStorage box = GetStorage();
    box.write("token", token.value);
    box.write("user.id", user.value.id);
    box.write("user.email", user.value.email);
    box.write("user.username", user.value.username);
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
    user.value = User(email: user.value.email, username: user.value.username);
    saveToStorage();
  }

  Future register({@required String email, @required String password}) async {
    token.nil();
    loading.value = true;
    return api.post('/api/users',
        data: {'email': email, 'password': password}).then((data) {
      user.value = User.fromJson(data);
      saveToStorage();
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
      saveToStorage();
    }).catchError((error) {
      token.nil();
      status.value = UserStatus.loggedout;
      loading.value = false;
      throw error;
    });
  }

  Future editUsername(String username) async {
    loading.value = true;
    return userService.patch(user.value.id, {'username': username}).then((data) {
      user.value.username = username;
      user.refresh();
      loading.value = false;
      saveToStorage();
      return user;
    }).catchError((error) {
      loading.value = false;
      throw error;
    });
  }

  Future editAvatar(Media media) async {
    loading.value = true;
    return userService.patch(user.value.id, {'avatar': media.hydraId}).then((data) {
      user.value.avatar = media;
      user.refresh();
      loading.value = false;
      return user;
    }).catchError((error) {
      loading.value = false;
      throw error;
    });
  }
}
