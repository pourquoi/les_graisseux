import 'package:app/models/user.dart';
import 'package:app/services/crud.dart';
import 'package:meta/meta.dart';

class UserService extends CrudService<User> {
  UserService() : super(resource: 'users', fromJson: (data) => User.fromJson(data), toJson: (user) => user.toJson());

  Future<User> register({@required String email, @required String password}) {
    return api.post('/api/users', data: {'email': email, 'password': password})
      .then((data) {
        return User.fromJson(data);
      });
  }
}
