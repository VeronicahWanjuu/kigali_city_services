import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/bookmark_service.dart';


class BookmarkProvider extends ChangeNotifier {
  final BookmarkService _svc;
  List<String> _ids = [];
  StreamSubscription<List<String>>? _sub;


  List<String> get bookmarkedIds => _ids;
  bool isBookmarked(String id) => _ids.contains(id);


  BookmarkProvider(this._svc);


  void loadBookmarks(String uid) {
    _sub?.cancel();
    _sub = _svc.getBookmarkIds(uid).listen((ids) {
      _ids = ids;
      notifyListeners();
    });
  }


  Future<void> toggleBookmark(String uid, String placeId) async {
    if (isBookmarked(placeId)) {
      await _svc.removeBookmark(uid, placeId);
    } else {
      await _svc.addBookmark(uid, placeId);
    }
  }


  @override
  void dispose() { _sub?.cancel(); super.dispose(); }
}
