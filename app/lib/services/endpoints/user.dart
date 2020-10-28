import 'package:app/models/user.dart';
import 'package:app/services/crud_service.dart';

class UserService extends CrudService {

  UserService() : super(resource: 'users', fromJson: (data) => User.fromJson(data), toJson: (user) => user.toJson());

}
