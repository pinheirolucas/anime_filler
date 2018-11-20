import "package:shared_preferences/shared_preferences.dart" show SharedPreferences;

class SettingsService {
  static const _showTitlesKey = "showTitles";
  static const _episodeOrderKey = "episodeOrder";
  static const _viewOptionsKey = "viewOptions";

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  Future<bool> setShowTitles(bool value) async => await _prefs.setBool(_showTitlesKey, value);
  bool getShowTitles() => _prefs.getBool(_showTitlesKey) ?? true;

  Future<bool> setEpisodesOrder(String episodeOrder) async => await _prefs.setString(_episodeOrderKey, episodeOrder);
  String getEpisodesOrder() => _prefs.getString(_episodeOrderKey) ?? "First to last";

  Future<bool> setViewOptions(String viewOptions) async => await _prefs.setString(_viewOptionsKey, viewOptions);
  String getViewOptions() => _prefs.getString(_viewOptionsKey) ?? "Show filler and canon";
}
