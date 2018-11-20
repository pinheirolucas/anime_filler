import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart" show SharedPreferences;

import "services/search_history_service.dart" show SearchHistoryService;
import "services/settings_service.dart" show SettingsService;

class SettingsView extends StatelessWidget {
  final SearchHistoryService _searchHistoryService;
  final SettingsService _settingsService;

  SettingsView({@required SharedPreferences prefs})
      : _searchHistoryService = SearchHistoryService(prefs),
        _settingsService = SettingsService(prefs);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SwitchListTile(
          title: Text("Show episode titles"),
          value: _settingsService.getShowTitles(),
          onChanged: (value) {
            _settingsService.setShowTitles(value);
          },
        ),
        _PickerListTile(
          title: Text("Episode order"),
          dialogTitle: "Select an option",
          value: _settingsService.getEpisodesOrder(),
          options: [
            "First to last",
            "Last to first",
          ],
          onChange: (value) => _settingsService.setEpisodesOrder(value),
        ),
        _PickerListTile(
          title: Text("View options"),
          dialogTitle: "Select an option",
          value: _settingsService.getViewOptions(),
          options: [
            "Show filler and canon",
            "Show only filler",
            "Show only canon",
          ],
          onChange: (value) => _settingsService.setViewOptions(value),
        ),
        ListTile(
          title: Text("Clear search history"),
          onTap: () async {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text("Clear anime search history?"),
                    content: Text(
                      "All the searched animes listed on your search history will be discarted.",
                      style: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.4)),
                    ),
                    actions: [
                      FlatButton(
                        child: Text("CANCEL"),
                        onPressed: () => Navigator.pop(context, false),
                      ),
                      FlatButton(
                        child: Text("CLEAR"),
                        onPressed: () async {
                          await _searchHistoryService.clear();
                          Navigator.pop(context, true);
                        },
                      ),
                    ],
                  ),
            );
          },
        ),
      ],
    );
  }
}

class _PickerListTile extends StatefulWidget {
  static void noOp(String value) {}

  final String dialogTitle;
  final Widget title;
  final String value;
  final List<String> options;
  final Function onChange;

  _PickerListTile({
    this.dialogTitle,
    this.title,
    this.value,
    this.options = const [],
    this.onChange = noOp,
  });

  @override
  State<StatefulWidget> createState() => _PickerListTileState(value);
}

class _PickerListTileState extends State<_PickerListTile> {
  String _value;

  _PickerListTileState([this._value = ""]);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: widget.title,
      trailing: Padding(
        padding: EdgeInsets.only(right: 15),
        child: Text(
          _value,
          style: TextStyle(
            color: Color.fromRGBO(0, 0, 0, 0.4),
          ),
        ),
      ),
      onTap: () async {
        final result = await showDialog<String>(
          context: context,
          builder: (context) => SimpleDialog(
                title: Text(widget.dialogTitle),
                children: widget.options
                    .map((option) => SimpleDialogOption(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 5,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(option),
                                _value == option
                                    ? Icon(
                                        Icons.check,
                                        color: Color.fromRGBO(0, 0, 0, 0.4),
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context, option);
                          },
                        ))
                    .toList(),
              ),
        );

        if (result == null) {
          return;
        }

        setState(() {
          _value = result;
          widget.onChange(_value);
        });
      },
    );
  }
}
