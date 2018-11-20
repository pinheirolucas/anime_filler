import "dart:async" show Future;

import "package:cloud_firestore/cloud_firestore.dart" show CollectionReference;
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart" show SharedPreferences;
import "package:url_launcher/url_launcher.dart" show canLaunch, launch;

import "episode_kind_bottom.dart" show EpisodeKindBottom;
import "models/title.dart" as title;
import "models/episode.dart" show Episode, EpisodeKind, EpisodeRange;
import "services/favorites_service.dart" show FavoritesService;
import "services/settings_service.dart" show SettingsService;
import "settings_view.dart" show SettingsView;

class DetailsView extends StatefulWidget {
  final title.Title _anime;
  final CollectionReference _collection;
  final FavoritesService favoritesService;
  final SettingsService settingsService;
  final SharedPreferences prefs;

  DetailsView({@required CollectionReference collection, @required this.prefs, @required title.Title anime})
      : _collection = collection,
        _anime = anime,
        favoritesService = FavoritesService(prefs),
        settingsService = SettingsService(prefs);

  @override
  State<StatefulWidget> createState() => _DetailsViewState(_collection, _anime);
}

class _DetailsViewState extends State<DetailsView> {
  final title.Title _anime;
  final CollectionReference _collection;
  List<Episode> episodes = [];
  List<EpisodeRange> canonRanges = [];
  List<EpisodeRange> fillerRanges = [];
  List<String> favorites = [];
  bool isFavorite = false;

  _DetailsViewState(this._collection, this._anime);

  int get totalEpisodes => episodes?.length ?? 0;
  String get originalRun =>
      hasEpisodes ? "${episodes.first.airdate.year} - ${episodes.last.airdate.year}" : "(no episodes)";
  int get totalFillers =>
      episodes
          ?.where((episode) => episode.kind == EpisodeKind.FILLER || episode.kind == EpisodeKind.MOSTLY_FILLER)
          ?.length ??
      0;
  int get totalFillersPercent => totalEpisodes == 0 ? 0 : ((totalFillers * 100) / totalEpisodes).round();
  bool get hasEpisodes => episodes?.isNotEmpty ?? false;
  bool get hasCanon => canonRanges?.isNotEmpty ?? false;
  bool get hasFiller => fillerRanges?.isNotEmpty ?? false;
  bool get hasQuickList => hasCanon || hasFiller;

  @override
  void initState() {
    _getEpisodes().then((eps) => setState(() {
          episodes
            ..clear()
            ..addAll(eps);
        }));

    isFavorite = widget.favoritesService.isFavorite(_anime.fbId);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_anime?.name),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            tooltip: "Settings",
            onPressed: () async {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                        appBar: AppBar(
                          title: Text("Settings"),
                        ),
                        body: SettingsView(prefs: widget.prefs),
                      ),
                  fullscreenDialog: true,
                ),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              elevation: 3,
              margin: EdgeInsets.fromLTRB(15, 5, 15, 5),
              child: Padding(
                padding: EdgeInsets.all(17),
                child: Container(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Original run:"),
                          Text(originalRun),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total episodes:"),
                          Text(totalEpisodes.toString()),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total fillers:"),
                          Text("$totalFillers ($totalFillersPercent%)"),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          OutlineButton.icon(
                            icon: Icon(Icons.open_in_browser),
                            label: Text("view on animefillerlist.com"),
                            textColor: Colors.deepOrangeAccent,
                            onPressed: _launchTitlePage,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            _buildQuickList(),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  Card(
                    elevation: 3,
                    margin: EdgeInsets.fromLTRB(15, 5, 15, 5),
                    child: DataTable(
                      columns: _buildEpisodesGridColumns(),
                      rows: episodes.where(_filterEpisodeByKind).map(_buildEpisodeRow).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
        tooltip: "Favorite",
        onPressed: _toggleFavorite,
      ),
    );
  }

  Widget _buildQuickList() => hasQuickList
      ? Card(
          elevation: 3,
          margin: EdgeInsets.fromLTRB(15, 5, 15, 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(238, 238, 238, 1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(17, 8, 17, 8),
                  child: Container(
                    child: Text("Quick List"),
                  ),
                ),
              ),
              Divider(
                height: 0,
                color: Color.fromRGBO(62, 62, 62, 1),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(17, 8, 17, 8),
                child: Column(
                  children: [
                    hasCanon
                        ? Row(
                            children: [
                              Text(
                                "Canon",
                                style: TextStyle(fontWeight: FontWeight.w400),
                              ),
                            ],
                          )
                        : Container(),
                    hasCanon
                        ? Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                                child: ActionChip(
                                  label: Text("1 - 55"),
                                  padding: EdgeInsets.all(0),
                                  onPressed: () {
                                    // TODO: jump to first episode
                                  },
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                                child: ActionChip(
                                  label: Text("1 - 55"),
                                  padding: EdgeInsets.all(0),
                                  onPressed: () {
                                    // TODO: jump to first episode
                                  },
                                ),
                              ),
                            ],
                          )
                        : Container(),
                    hasFiller
                        ? Row(
                            children: [
                              Text(
                                "Filler",
                                style: TextStyle(fontWeight: FontWeight.w400),
                              ),
                            ],
                          )
                        : Container(),
                    hasFiller
                        ? Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                                child: ActionChip(
                                  label: Text("1 - 55"),
                                  padding: EdgeInsets.all(0),
                                  onPressed: () {
                                    // TODO: jump to first episode
                                  },
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                                child: ActionChip(
                                  label: Text("1 - 55"),
                                  padding: EdgeInsets.all(0),
                                  onPressed: () {
                                    // TODO: jump to first episode
                                  },
                                ),
                              ),
                            ],
                          )
                        : Container(),
                  ],
                ),
              ),
            ],
          ),
        )
      : Container();

  List<DataColumn> _buildEpisodesGridColumns() => widget.settingsService.getShowTitles()
      ? [
          DataColumn(label: Text("#")),
          DataColumn(label: Text("Title")),
          DataColumn(label: Text("Kind")),
        ]
      : [
          DataColumn(label: Text("#")),
          DataColumn(label: Text("Kind")),
        ];

  DataRow _buildEpisodeRow(Episode episode) => DataRow(
        cells: widget.settingsService.getShowTitles()
            ? [
                DataCell(Text(episode.epNum.toString())),
                DataCell(Text(episode.title)),
                DataCell(EpisodeKindBottom(episode.kind)),
              ]
            : [
                DataCell(Text(episode.epNum.toString())),
                DataCell(EpisodeKindBottom(episode.kind)),
              ],
      );

  Future<void> _launchTitlePage() async {
    if (await canLaunch(_anime?.link)) {
      await launch(_anime?.link);
    }
  }

  Future<void> _toggleFavorite() async {
    if (isFavorite) {
      favorites?.remove(_anime.fbId);
      await widget.favoritesService.remove(_anime.fbId);
      setState(() {
        isFavorite = false;
      });
      return;
    }

    favorites.add(_anime.fbId);
    await widget.favoritesService.setFavorite(_anime.fbId, _anime.id);
    setState(() {
      isFavorite = true;
    });
  }

  bool _filterEpisodeByKind(Episode episode) {
    switch (widget.settingsService.getViewOptions()) {
      case "Show only filler":
        return episode.kind == EpisodeKind.FILLER || episode.kind == EpisodeKind.MOSTLY_FILLER;
      case "Show only canon":
        return episode.kind == EpisodeKind.CANON || episode.kind == EpisodeKind.MOSTLY_CANON;
    }

    return true;
  }

  Future<List<Episode>> _getEpisodes() async {
    return _collection
        .document("${_anime.fbId}")
        .collection("episodes")
        .orderBy("epNum", descending: widget.settingsService.getEpisodesOrder() == "Last to first")
        .getDocuments()
        .then((snapshot) => snapshot.documents.map((document) => Episode.fromDocument(document)).toList());
  }
}
