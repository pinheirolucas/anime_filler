import "dart:async" show Future;

import "package:shared_preferences/shared_preferences.dart" show SharedPreferences;

class SearchHistoryService {
  static const _key = "searchHistory";

  final SharedPreferences _prefs;

  SearchHistoryService(this._prefs);

  Future<bool> clear() async => await _prefs.remove(_key);
  Future<bool> putAndReorder(String search) async {
    final history = _prefs.getStringList(_key);

    if (history == null) {
      return await _prefs.setStringList(_key, [search]);
    }

    history.remove(search);
    history.insert(0, search);

    return await _prefs.setStringList(_key, history);
  }

  List<String> getHistory() => _prefs.getStringList(_key) ?? [];
}
