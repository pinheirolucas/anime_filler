import "dart:async" show Future;

import "package:shared_preferences/shared_preferences.dart" show SharedPreferences;

class FavoritesService {
  static const _prefix = "favorites#";

  final SharedPreferences _prefs;

  FavoritesService(this._prefs);

  bool isFavorite(String fav) => getFavorites().contains(fav);
  List<String> getFavorites() =>
      _prefs.getKeys().where((k) => k.startsWith(_prefix)).map((fav) => fav.replaceFirst(_prefix, "")).toList();
  List<String> getIds() => getFavorites().map((k) => _prefs.getString(k)).toList();
  Future<bool> remove(String id) async => await _prefs.remove("$_prefix$id");
  Future<bool> setFavorite(String k, String v) async => await _prefs.setString("$_prefix$k", v);
}
