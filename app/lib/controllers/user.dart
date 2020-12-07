import 'dart:async';
import 'dart:convert';

import 'package:app/config.dart';
import 'package:app/controllers/app.dart';
import 'package:app/models/address.dart';
import 'package:app/models/media.dart';
import 'package:app/services/api.dart';
import 'package:app/services/endpoints/user.dart';
import 'package:app/utils/feedback.dart';
import 'package:dio/dio.dart';
import 'package:eventsource/eventsource.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:app/models/user.dart';
import 'package:get_storage/get_storage.dart';

import 'package:app/routes.dart' as routes;

class UserController extends GetxController {
  AppController _appController;
  ApiService _api;
  UserService _crud;

  final token = ''.obs;
  final user = User().obs;
  final loading = false.obs;
  final loggedIn = false.obs;

  StreamSubscription _errorSub;
  StreamSubscription _tokenSub;
  StreamSubscription userSubscription;

  void onInit() {
    _api = Get.find<ApiService>();
    _crud = Get.find<UserService>();
    _appController = Get.find<AppController>();

    _tokenSub = token.listen((t) { 
      _api.token = t;
      if (t == null) {
        loggedIn.value = false;
      }
    });

    _errorSub = _api.errorStream.listen((DioError error) {
      if (error.response != null && error.response.statusCode == 401) {
        token.nil();
        if (!error.request.uri.path.endsWith('authentication_token')) {
          Get.toNamed(routes.login);
        }
      }
    });
  }

  void onClose() {
    _errorSub.cancel();
    _tokenSub.cancel();
    if (userSubscription != null)
      userSubscription.cancel();
  }

  Future bootstrap() async {
    await _read();
  }

  Future _read() async {
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

  Future _store() async {
    GetStorage box = GetStorage();
    box.write("token", token.value);
    box.write("user.id", user.value.id);
    box.write("user.email", user.value.email);
    box.write("user.username", user.value.username);
  }

  Future subscribeRoom() async {
    if (userSubscription != null) {
      userSubscription.cancel();
    }
    userSubscription = null;

    if (user.value.subscriptionToken != null) {
      
      EventSource eventSource = await EventSource.connect(
        MERCURE_ENDPOINT + '?topic=' + Uri.encodeComponent('http://example.com' + user.value.hydraId),
        headers: {'Authorization': 'Bearer ' + user.value.subscriptionToken}
      );

      userSubscription = eventSource.listen((Event event) {
        Map eventData = jsonDecode(event.data);
        print(eventData);
        if (eventData != null && eventData["type"] == "new-message") {
          
        }
      });
    }
  }

  Future login({@required String email, @required String password}) async {
    loading.value = true;
    token.nil();
    try {
      Map<String, dynamic> data = await _api.post('/authentication_token', data: {'email': email, 'password': password});
      token.value = data['token'];
      user.value.id = data['uid'];
    } catch(err) {
      displayError(message: "Invalid email or password");
    }

    if (!token.isNull) {
      try {
        await refresh();
        Get.toNamed(routes.home);
      } catch(err) {}
    }

    if (user.value.mechanic != null) {
      _appController.profileType.value = ProfileType.Mechanic;
    } else {
      _appController.profileType.value = ProfileType.Customer;
    }

    loading.value = false;
  }

  Future logout() async {
    token.nil();
    user.value = User(email: user.value.email, username: user.value.username);
    _store();
  }

  Future register({@required String email, @required String password}) async {
    token.nil();
    loading.value = true;
    try {
      user.value = await _crud.register(email: email, password: password);
      _store();
      return login(email: email, password: password);
    } catch(err) {
    } finally {
      loading.value = false;
    }
  }

  Future refresh() async {
    loading.value = true;
    try {
      User u = await _crud.get(user.value.id);
      user.value = u;
      loggedIn.value = true;
      _store();
      subscribeRoom();
    } catch(err) {
    } finally {
      loading.value = false;
    }
  }

  Future editUsername(String username) async {
    loading.value = true;
    try {
      _crud.patch(user.value.id, {'username': username});
      user.value.username = username;
      user.refresh();
      _store();
    } catch(err) {
    } finally {
      loading.value = false;
    }
  }

  Future editAvatar(Media media) async {
    loading.value = true;
    try {
      await _crud.patch(user.value.id, {'avatar': media.hydraId});
      user.value.avatar = media;
      user.refresh();
    } catch(err) {
    } finally {
      loading.value = false;
    }
  }

  Future editAddress(Address address) async {
    loading.value = true;
    try {
      User u = await _crud.patch(user.value.id, {'address': address.toJson()});
      user.value.address = u.address;
      user.refresh();
    } catch(err) {
    } finally {
      loading.value = false;
    }
  }
}
