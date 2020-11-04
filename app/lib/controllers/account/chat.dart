import 'package:app/controllers/user.dart';
import 'package:app/models/chat.dart';
import 'package:app/models/user.dart';
import 'package:app/services/crud_service.dart';
import 'package:app/services/endpoints/chat.dart';
import 'package:get/get.dart';

class ChatController extends GetxService
{
  final loading = false.obs;
  final sending = false.obs;

  final rooms = [].obs;
  final roomsPagination = PaginatedQueryResponse<ChatRoom>().obs;
  final roomsParams = ChatRoomQueryParameters().obs;

  final room = ChatRoom().obs;
  final roomMessages = List<ChatMessage>().obs;
  final roomPagination = PaginatedQueryResponse<ChatMessage>().obs;
  final roomParams = ChatMessageQueryParameters().obs;

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

  Future initRoom(User interlocutor) {
    room.value = ChatRoom(users: [
      ChatUser(user: userController.user.value),
      ChatUser(user: interlocutor)
    ]);
    roomMessages.clear();
    roomPagination.value = PaginatedQueryResponse<ChatMessage>();
    roomParams.value = ChatMessageQueryParameters(uuid: room.value.uuid);
  }

  Future loadRoom(String uuid) {
    loading.value = true;

    return chatRoomService.get(uuid).then((data) {
      room.value = data;
      roomMessages.clear();
      roomPagination.value = PaginatedQueryResponse<ChatMessage>();
      roomParams.value = ChatMessageQueryParameters(uuid: uuid);
      loading.value = false;
      loadRoomMessages();
    }).catchError((error) {
      loading.value = false;
      throw error;
    });
  }

  Future loadRoomMessages() {
    return chatMessageService.search(roomParams.value).then((data) {
      roomPagination.value = data;
      roomMessages.value = data.items;
      loading.value = false;
    }).catchError((error) {
      loading.value = false;
      throw error;
    });
  }

  Future loadFeed() {

  }

  Future send(String message) {
    if (room.value.id == null) {
      sending.value = true;
      return chatRoomService.create(message, room.value.getInterlocutor(userController.user.value.id).user.hydraId).then((data) {
        sending.value = false;
        room.value = data;
        roomMessages.clear();
        roomPagination.value = PaginatedQueryResponse<ChatMessage>();
        roomParams.value = ChatMessageQueryParameters(uuid: room.value.uuid);
        loading.value = false;
        loadRoomMessages();
      }).catchError((error) {
        sending.value = false;
        throw error;
      });
    }

    ChatMessage chatMessage = ChatMessage();
    chatMessage.room = room.value;
    chatMessage.message = message;
    sending.value = true;
    return chatMessageService.post(chatMessage).then((data) {
      roomMessages.add(data);
      sending.value = false;
    }).catchError((error) {
      sending.value = false;
      throw error;
    });
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
}