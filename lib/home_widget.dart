import "package:flutter/material.dart";

import "navigation_icon.dart" show NavigationIconView;
import "shows_list_view.dart" show ShowsListView;

class HomeWidget extends StatefulWidget {
  HomeWidget({Key key}) : super(key: key);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> with TickerProviderStateMixin {
  int _currentIndex = 0;
  List<NavigationIconView> _views;
  final _searchDelegate = _SearchAnimeDelegate();

  @override
  void initState() {
    super.initState();

    _views = [
      NavigationIconView(
        icon: Icon(Icons.format_list_bulleted),
        title: "Animes",
        vsync: this,
      ),
      NavigationIconView(
        icon: Icon(Icons.favorite_border),
        activeIcon: Icon(Icons.favorite),
        title: "Favorites",
        vsync: this,
      ),
    ];

    for (var view in _views) {
      view.controller.addListener(_rebuild);
    }

    _views[_currentIndex].controller.value = 1.0;
  }

  @override
  void dispose() {
    for (var view in _views) {
      view.controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Anime Filler List"),
        actions: [
          IconButton(
            tooltip: "Search",
            icon: Icon(Icons.search),
            onPressed: () async {
              await showSearch(
                context: context,
                delegate: _searchDelegate,
              );

              // TODO: do something with the search
            },
          ),
        ],
      ),
      body: ShowsListView(),
      bottomNavigationBar: BottomNavigationBar(
        items: _views.map((view) => view.item).toList(),
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() {
              _views[index].controller.reverse();
              _currentIndex = index;
              _views[index].controller.forward();
            }),
      ),
    );
  }

  void _rebuild() {
    setState(() {
      // Rebuild in order to animate views.
    });
  }
}

class _SearchAnimeDelegate extends SearchDelegate<String> {
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
    return ShowsListView();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView(
      children: [
        _buildShowTile("Naruto"),
        _buildShowTile("Naruto Shippuden"),
        _buildShowTile("Boruto: Naruto Next Generations"),
        _buildShowTile("Dragon Ball Super")
      ],
    );
  }

  Widget _buildShowTile(String name) {
    return ListTile(
      leading: Icon(Icons.history),
      // TODO: bold on match
      title: Text(name),
      onTap: () {
        // TODO: implements selection
      },
    );
  }
}
