import "package:flutter/material.dart";

import "home_widget.dart" show HomeWidget;

void main() => runApp(AnimeFiller());

class AnimeFiller extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Anime Filler List",
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: HomeWidget(),
    );
  }
}
