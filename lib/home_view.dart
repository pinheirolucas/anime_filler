import "dart:async" show StreamSubscription;

import "package:connectivity/connectivity.dart" show Connectivity, ConnectivityResult;
import "package:cloud_firestore/cloud_firestore.dart" show CollectionReference;
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart" show SharedPreferences;

import "navigation_icon.dart" show NavigationIconView;
import "no_connectivity_view.dart" show NoConnectivityView;
import "retry_view.dart" show RetryView;
import "services/search_history_service.dart" show SearchHistoryService;
import "settings_view.dart" show SettingsView;
import "shows_list_view.dart" show ShowsListView;

class HomeView extends StatefulWidget {
  final Connectivity _connectivity;
  final SharedPreferences _prefs;
  final CollectionReference _titlesCollection;

  HomeView({
    Key key,
    Connectivity connectivity,
    SharedPreferences prefs,
    CollectionReference titlesCollection,
  })  : _connectivity = connectivity,
        _prefs = prefs,
        _titlesCollection = titlesCollection,
        super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState(_connectivity, _prefs, _titlesCollection);
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  final Connectivity _connectivity;
  final SharedPreferences _prefs;
  final CollectionReference _titlesCollection;

  StreamSubscription _connectivitySubscription;

  _HomeTab _currentTab = _HomeTab.ANIMES;
  Map<_HomeTab, NavigationIconView> _views;
  _SearchAnimeDelegate _searchDelegate;

  _HomeViewState(this._connectivity, this._prefs, this._titlesCollection) {
    _searchDelegate = _SearchAnimeDelegate(titlesCollection: _titlesCollection, prefs: _prefs);
  }

  @override
  void initState() {
    _connectivity.checkConnectivity().then((result) => _checkConnectionChangeResult(result));
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_checkConnectionChangeResult);

    _views = {
      _HomeTab.ANIMES: NavigationIconView(
        icon: Icon(Icons.format_list_bulleted),
        title: "Animes",
        vsync: this,
      ),
      _HomeTab.FAVORITES: NavigationIconView(
        icon: Icon(Icons.favorite_border),
        activeIcon: Icon(Icons.favorite),
        title: "Favorites",
        vsync: this,
      ),
      _HomeTab.SETTINGS: NavigationIconView(
        icon: Icon(Icons.settings),
        title: "Settings",
        vsync: this,
      ),
    };

    _views.forEach((_, view) => view.controller.addListener(_rebuild));

    _views[_currentTab].controller.value = 1.0;

    super.initState();
  }

  @override
  void dispose() {
    _views.forEach((_, view) => view.controller.dispose());
    _connectivitySubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Anime Filler List"),
        actions: _currentTab == _HomeTab.ANIMES
            ? [
                IconButton(
                  tooltip: "Search",
                  icon: Icon(Icons.search),
                  onPressed: _spawnSearch,
                ),
              ]
            : [],
      ),
      body: _currentTab == _HomeTab.SETTINGS
          ? SettingsView(prefs: _prefs)
          : ShowsListView(
              titlesCollection: _titlesCollection,
              prefs: _prefs,
              loadFromFavorites: _currentTab == _HomeTab.FAVORITES,
              emptyListFallback: RetryView(
                errorTitle: "No favorites found",
                errorDetail: "Start adding your favorite animes for a quick access",
                iconData: Icons.favorite,
                retryText: "BACK TO ANIMES",
                onRetry: (context) => _setTab(0),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: _views.values.map((view) => view.item).toList(),
        currentIndex: _currentTab.index,
        type: BottomNavigationBarType.fixed,
        onTap: _setTab,
      ),
    );
  }

  void _rebuild() {
    setState(() {
      // Rebuild in order to animate views.
    });
  }

  Future<void> _checkConnectionChangeResult(ConnectivityResult result) async {
    if (result != ConnectivityResult.none) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoConnectivityView(connectivity: _connectivity),
        fullscreenDialog: true,
      ),
    );
  }

  void _spawnSearch() async {
    await showSearch(
      context: context,
      delegate: _searchDelegate,
    );
  }

  void _setTab(index) => setState(() {
        final tab = _homeTabMapping[index];

        _views[tab].controller.reverse();
        _currentTab = tab;
        _views[tab].controller.forward();
      });
}

class _SearchAnimeDelegate extends SearchDelegate<String> {
  final CollectionReference _titlesCollection;
  final SharedPreferences _prefs;
  final SearchHistoryService _searchHistoryService;

  _SearchAnimeDelegate({@required CollectionReference titlesCollection, @required SharedPreferences prefs})
      : _titlesCollection = titlesCollection,
        _prefs = prefs,
        _searchHistoryService = SearchHistoryService(prefs);

  @override
  List<Widget> buildActions(BuildContext context) {
    if (query.isEmpty) {
      return [];
    }

    return [
      IconButton(
        tooltip: "Clear",
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: "Back",
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ShowsListView(
      titlesCollection: _titlesCollection,
      prefs: _prefs,
      search: query,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final history = _searchHistoryService.getHistory();

    return history.isEmpty
        ? Center(
            child: Text("No search history"),
          )
        : ListView(
            children: history.map((text) => _buildShowTile(context, text)).toList(),
          );
  }

  @override
  void showResults(BuildContext context) {
    _searchHistoryService.putAndReorder(query);

    super.showResults(context);
  }

  Widget _buildShowTile(BuildContext context, String name) {
    return ListTile(
      leading: Icon(Icons.history),
      trailing: IconButton(
        icon: Icon(
          Icons.call_made,
          textDirection: TextDirection.rtl,
        ),
        onPressed: () => query = name,
      ),
      title: Text(name),
      onTap: () {
        query = name;
        showResults(context);
      },
    );
  }
}

enum _HomeTab {
  ANIMES,
  FAVORITES,
  SETTINGS,
}

final _homeTabMapping = <int, _HomeTab>{
  _HomeTab.ANIMES.index: _HomeTab.ANIMES,
  _HomeTab.FAVORITES.index: _HomeTab.FAVORITES,
  _HomeTab.SETTINGS.index: _HomeTab.SETTINGS,
};
