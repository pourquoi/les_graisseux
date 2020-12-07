import 'dart:async';
import 'dart:convert';

import 'package:app/controllers/user.dart';
import 'package:app/models/chat.dart';
import 'package:app/models/user.dart';
import 'package:app/services/crud.dart';
import 'package:app/services/endpoints/chat.dart';
import 'package:get/get.dart';
import 'package:app/config.dart';
import 'package:eventsource/eventsource.dart';

class ChatController extends GetxService
{
  final loading = false.obs;
  final loadingMessages = false.obs;
  final sending = false.obs;

  final rooms = [].obs;
  final roomsPagination = PaginatedQueryResponse<ChatRoom>().obs;
  final roomsParams = ChatRoomQueryParameters().obs;

  final room = ChatRoom().obs;
  final roomMessages = List<ChatMessage>().obs;
  final roomPagination = PaginatedQueryResponse<ChatMessage>().obs;
  final roomParams = ChatMessageQueryParameters().obs;
  StreamSubscription roomSubscription;

  final feedMessages = List<ChatMessage>().obs;
  final feedPagination = PaginatedQueryResponse<ChatMessage>().obs;
  final feedParams = ChatMessageQueryParameters().obs;

  UserController userController;
  ChatRoomService chatRoomService;
  ChatMessageService chatMessageService;

  void onInit() {
    userController = Get.find<UserController>();
    chatRoomService = Get.find<ChatRoomService>();
    chatMessageService = Get.find<ChatMessageService>();
  }

  void onClose() {
    if (roomSubscription != null)
      roomSubscription.cancel();
  }

  Future subscribeRoom() async {
    if (roomSubscription != null) {
      roomSubscription.cancel();
    }
    roomSubscription = null;

    if (room.value.subscriptionToken != null) {
      
      EventSource eventSource = await EventSource.connect(
        MERCURE_ENDPOINT + '?topic=' + Uri.encodeComponent('http://example.com' + room.value.hydraId),
        headers: {'Authorization': 'Bearer ' + room.value.subscriptionToken}
      );

      roomSubscription = eventSource.listen((Event event) {
        Map eventData = jsonDecode(event.data);
        if (eventData != null && eventData["type"] == "new-message") {
          ChatMessage msg = ChatMessage.fromJson(eventData["data"]);
          _addMessage(msg);
        }
      });
    }
  }

  Future<bool> loadRooms() {
    loading.value = true;

    return chatRoomService.search(roomsParams.value).then((data) {
      roomsPagination.value = data;
      rooms.value = data.items;
      loading.value = false;
      return true;
    }).catchError((error) {
      loading.value = false;
      throw error;
    });
  }

  Future initRoom(User interlocutor) async {
    if (loading.value) return;
    loading.value = true;

    ChatRoomQueryParameters _params = ChatRoomQueryParameters(isPrivateChat: true, user: interlocutor);
    ChatRoom existing;
    
    try {
      PaginatedQueryResponse<ChatRoom> _response = await chatRoomService.search(_params);
      if (_response.items.isNotEmpty) {
        existing = _response.items[0];
      }
    } catch(error) {
      print(error);
    }

    if (existing != null) {
      room.value = existing;
    } else {
      room.value = ChatRoom(users: [
        ChatUser(user: userController.user.value),
        ChatUser(user: interlocutor)
      ]);
    }
    roomMessages.clear();
    roomPagination.value = PaginatedQueryResponse<ChatMessage>();
    roomParams.value = ChatMessageQueryParameters(uuid: room.value.uuid);
    loading.value = false;
  }

  Future loadRoom(String uuid) async {
    loading.value = true;
    roomMessages.clear();

    try {
      room.value = await chatRoomService.get(uuid);
      roomMessages.clear();
      roomPagination.value = PaginatedQueryResponse<ChatMessage>();
      roomParams.value = ChatMessageQueryParameters(uuid: uuid);
      loading.value = false;
      await loadRoomMessages();
      await subscribeRoom();
    } catch(error) {
      print(error);
      loading.value = false;
    }
  }

  Future loadRoomMessages() async {
    loadingMessages.value = true;
    try {
      roomPagination.value = await chatMessageService.search(roomParams.value);
      roomMessages.value = roomPagination.value.items;
      loadingMessages.value = false;
    } catch(error) {
      print(error);
      loadingMessages.value = false;
    };
  }

  Future loadFeed() {

  }

  Future send(String message) async {
    if (room.value.id == null) {
      sending.value = true;
      try {
        room.value = await chatRoomService.create(message, room.value.getInterlocutor(userController.user.value.id).user.hydraId);
        sending.value = false;
        roomMessages.clear();
        roomPagination.value = PaginatedQueryResponse<ChatMessage>();
        roomParams.value = ChatMessageQueryParameters(uuid: room.value.uuid);
        loading.value = false;
        await loadRoomMessages();
        await subscribeRoom();
      } catch(error) {
        sending.value = false;
        print(error);
      }
    } else {
      ChatMessage chatMessage = ChatMessage();
      chatMessage.room = room.value;
      chatMessage.message = message;
      sending.value = true;
      try {
        chatMessage = await chatMessageService.post(chatMessage);
        _addMessage(chatMessage);
      } catch(error) {
        print(error);
      } finally {
        sending.value = false;
      }
    }
  }

  Future createChat(String message, User user) {
    sending.value = true;
    return chatRoomService.create(message, user.hydraId).then((data) {
      sending.value = false;
      return data;
    }).catchError((error) {
      sending.value = false;
      throw error;
    });
  }

  void _addMessage(ChatMessage msg) {
    if (roomMessages.firstWhere((m) => m.id == msg.id, orElse: () => null) == null) {
      roomMessages.add(msg);
    }
  }
}