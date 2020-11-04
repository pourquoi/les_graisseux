import 'package:app/models/chat.dart';

import 'package:app/services/crud_service.dart';

class ChatRoomQueryParameters extends PaginatedQueryParameters {
  ChatRoomQueryParameters({String q, int page, int itemsPerPage}) : super(q: q, page: page, itemsPerPage: itemsPerPage);

  Map<String, dynamic> toJson() {
    var params = super.toJson();
    return params;
  }
}

class ChatMessageQueryParameters extends PaginatedQueryParameters {
  String uuid;
  ChatMessageQueryParameters({this.uuid, String q, int page, int itemsPerPage}) : super(q: q, page: page, itemsPerPage: itemsPerPage);

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
