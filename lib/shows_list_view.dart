import "package:flutter/material.dart";

import "details_view.dart" show DetailsView;

class ShowsListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _ShowCard(
          image: NetworkImage(
              "https://www.animefillerlist.com/sites/default/files/styles/anime_poster/public/boruto.jpg?itok=edaw6VbS"),
          title: "Boruto: Naruto Next Generations",
        ),
        _ShowCard(
          image: NetworkImage(
              "https://www.animefillerlist.com/sites/default/files/styles/anime_poster/public/screenshot_2018-07-13-16-17-292.png?itok=SC9Bv-J8"),
          title: "Dragon Ball Super",
        ),
        _ShowCard(
          image: NetworkImage(
              "https://www.animefillerlist.com/sites/default/files/styles/anime_poster/public/tv_061.jpg?itok=17ZhJ8Ai"),
          title: "Naruto",
        ),
        _ShowCard(
          image: NetworkImage(
              "https://www.animefillerlist.com/sites/default/files/styles/anime_poster/public/screenshot_2017-10-21-01-10-442.png?itok=7QZlrOg5"),
          title: "Naruto Shippuden",
        ),
        FlatButton(
          textTheme: ButtonTextTheme.accent,
          child: Text("Load more"),
          onPressed: () {
            // TODO: load more
          },
        ),
      ],
    );
  }
}

class _ShowCard extends StatelessWidget {
  final ImageProvider image;
  final String title;

  _ShowCard({@required this.image, @required this.title});

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
                  backgroundImage: image,
                  radius: 35,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 15),
                child: Text(
                  title,
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
                onPressed: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsView()));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
