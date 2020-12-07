
import 'package:app/models/bookmark.dart';
import 'package:app/models/user.dart';
import 'package:app/services/crud.dart';

class BookmarkQueryParameters extends PaginatedQueryParameters {
  User user;

  BookmarkQueryParameters({
    this.user, 
    String sort, String q, int page, int itemsPerPage
  }) : super(q: q, page: page, itemsPerPage: itemsPerPage);

  Map<String, dynamic> toJson() {
    var params = super.toJson();
    if (user != null) params['user'] = user.id;
    return params;
  }
}

class BookmarkService extends CrudService<Bookmark> {
  BookmarkService() : super(resource: 'bookmarks', fromJson: (data) => Bookmark.fromJson(data), toJson: (bookmark) => bookmark.toJson());
}
