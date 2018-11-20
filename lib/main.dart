import "dart:async" show Future;

import "package:cloud_firestore/cloud_firestore.dart" show CollectionReference, Firestore;
import "package:connectivity/connectivity.dart" show Connectivity;
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart" show SharedPreferences;

import "home_view.dart" show HomeView;

Future<void> main() async {
  runApp(AnimeFiller(
    connectivity: Connectivity(),
    prefs: await SharedPreferences.getInstance(),
    titlesCollection: Firestore.instance.collection("titles"),
  ));
}

class AnimeFiller extends StatelessWidget {
  final Connectivity _connectivity;
  final SharedPreferences _prefs;
  final CollectionReference _titlesCollection;

  AnimeFiller({
    @required Connectivity connectivity,
    @required SharedPreferences prefs,
    @required CollectionReference titlesCollection,
  })  : _connectivity = connectivity,
        _prefs = prefs,
        _titlesCollection = titlesCollection;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Anime Filler List",
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: HomeView(
        connectivity: _connectivity,
        prefs: _prefs,
        titlesCollection: _titlesCollection,
      ),
    );
  }
}
