import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart" show CollectionReference, QuerySnapshot;
import "package:shared_preferences/shared_preferences.dart" show SharedPreferences;

import "details_view.dart" show DetailsView;
import "models/title.dart" as title;
import "retry_view.dart" show RetryView;
import "services/favorites_service.dart" show FavoritesService;

class ShowsListView extends StatefulWidget {
  final CollectionReference titlesCollection;
  final String search;
  final bool loadFromFavorites;
  final Widget emptyListFallback;
  final SharedPreferences prefs;
  final FavoritesService favoritesService;

  ShowsListView({
    @required this.titlesCollection,
    @required this.prefs,
    this.emptyListFallback,
    this.loadFromFavorites = false,
    this.search = "",
  }) : favoritesService = FavoritesService(prefs);

  @override
  State<StatefulWidget> createState() => _ShowsListViewState();
}

class _ShowsListViewState extends State<ShowsListView> {
  @override
  Widget build(BuildContext context) {
    return widget.loadFromFavorites
        ? _buildFavoritesTab(context)
        : StreamBuilder<QuerySnapshot>(
            stream: widget.titlesCollection
                .orderBy("title")
                .startAt([widget.search]).endAt(["${widget.search}\uf8ff"]).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return RetryView(
                  errorTitle: "Some error occurred",
                  errorDetail: "The request could not be processed",
                  iconData: Icons.sentiment_very_dissatisfied,
                  retryText: "RETRY",
                  onRetry: () => setState(() {}),
                );
              }

              return snapshot.connectionState == ConnectionState.waiting
                  ? LinearProgressIndicator()
                  : ListView(
                      children: snapshot.data.documents
                          .map((document) => title.Title.fromDocument(document))
                          .map(_buildListViewTile)
                          .toList());
            },
          );
  }

  Widget _buildListViewTile(title.Title t) {
    return _ShowCard(
      anime: t,
      onPressed: (context) async => await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DetailsView(collection: widget.titlesCollection, prefs: widget.prefs, anime: t),
            ),
          ),
    );
  }

  Widget _buildFavoritesTab(BuildContext context) {
    final ids = widget.favoritesService.getFavorites();

    return ids.isEmpty
        ? widget.emptyListFallback ?? Container()
        : FutureBuilder<List<title.Title>>(
            future: Future.wait(
              ids
                  .map((id) => widget.titlesCollection.document(id).get())
                  .map((document) async => title.Title.fromDocument(await document))
                  .toList(),
            ),
            builder: (context, snap) => ListView(
                  children: _sortFavorites(snap.data)?.map(_buildListViewTile)?.toList() ?? [],
                ),
          );
  }

  List<title.Title> _sortFavorites(List<title.Title> favs) {
    favs?.sort((x, y) => x.name.compareTo(y.name));
    return favs;
  }
}

class _ShowCard extends StatelessWidget {
  final title.Title _anime;
  final Function _onPressed;

  _ShowCard({title.Title anime, Function onPressed})
      : _anime = anime,
        _onPressed = onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(15, 5, 15, 5),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(17),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              child: Material(
                borderRadius: BorderRadius.circular(50),
                elevation: 3,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(_anime?.cover),
                  radius: 35,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 15),
                child: Text(
                  _anime?.name,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Container(
              child: OutlineButton(
                highlightedBorderColor: Colors.grey,
                child: Icon(
                  Icons.keyboard_arrow_right,
                ),
                shape: CircleBorder(),
                onPressed: () {
                  if (_onPressed != null) {
                    _onPressed(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
