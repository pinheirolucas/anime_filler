import "dart:async" show Future;

import "package:connectivity/connectivity.dart" show Connectivity, ConnectivityResult;
import "package:flutter/material.dart";

import "retry_view.dart" show RetryView;

class NoConnectivityView extends StatefulWidget {
  final Connectivity _connectivity;

  NoConnectivityView({@required Connectivity connectivity}) : _connectivity = connectivity;

  @override
  State<StatefulWidget> createState() => _NoConnectivityViewState(_connectivity);
}

class _NoConnectivityViewState extends State<NoConnectivityView> {
  final Connectivity _connectivity;
  bool _isChecking = false;

  _NoConnectivityViewState(this._connectivity);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _connectivity.checkConnectivity() != ConnectivityResult.none;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("No internet connection"),
        ),
        body: RetryView(
          errorTitle: "Can't load page",
          errorDetail: "Check your internet connection and try again",
          iconData: Icons.perm_scan_wifi,
          retryText: "RETRY",
          isLoading: _isChecking,
          onRetry: _onRetry,
        ),
      ),
    );
  }

  void _onRetry(BuildContext context) async {
    setState(() {
      _isChecking = true;
    });
    await Future.delayed(Duration(seconds: 2));

    final result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Internet connection not established yet"),
        duration: Duration(seconds: 3),
      ));
      setState(() {
        _isChecking = false;
      });
      return;
    }

    Navigator.of(context).pop();
  }
}
