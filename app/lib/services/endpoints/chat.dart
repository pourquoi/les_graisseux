import 'package:app/models/chat.dart';
import 'package:app/models/user.dart';

import 'package:app/services/crud.dart';

class ChatRoomQueryParameters extends PaginatedQueryParameters {
  User user;
  bool isPrivateChat;
  bool isApplicationChat;
  bool isJobChat;

  ChatRoomQueryParameters({
    this.user,
    this.isPrivateChat,
    this.isApplicationChat,
    this.isJobChat,
    String sort, String q, int page, int itemsPerPage
  }) : super(sort: sort, q: q, page: page, itemsPerPage: itemsPerPage);

  Map<String, dynamic> toJson() {
    var params = super.toJson();
    if (this.isPrivateChat != null) {
      params['private'] = this.isPrivateChat ? 'true' : 'false';
    }
    if (this.isApplicationChat != null) {
      params['exists[application]'] = this.isApplicationChat ? 'true' : 'false';
    }
    if (this.isJobChat != null) {
      params['exists[job]'] = this.isJobChat ? 'true' : 'false';
    }
    if (this.user != null) {
      params['users.user'] = this.user.id;
    }
    return params;
  }
}

class ChatMessageQueryParameters extends PaginatedQueryParameters {
  String uuid;

  ChatMessageQueryParameters({
    this.uuid, 
    String sort, String q, int page, int itemsPerPage
  }) : super(q: q, page: page, itemsPerPage: itemsPerPage);

  Map<String, dynamic> toJson() {
    var params = super.toJson();
    if (uuid != null) params['room.uuid'] = uuid;
    return params;
  }
}

class ChatRoomService extends CrudService<ChatRoom> {
  ChatRoomService() : super(resource: 'chat_rooms', fromJson: (data) => ChatRoom.fromJson(data), toJson: (room) => room.toJson());

  Future<ChatRoom> create(String message, String user) {
    return api.post('/api/$resource', data: {'message': message, 'to': user}).then((data) {
      return ChatRoom.fromJson(data);
    });
  }
}

class ChatMessageService extends CrudService<ChatMessage> {
  ChatMessageService() : super(resource: 'chat_messages', fromJson: (data) => ChatMessage.fromJson(data), toJson: (room) => room.toJson());
}
