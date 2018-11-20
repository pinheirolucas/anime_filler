import "package:flutter/material.dart";

class RetryView extends StatelessWidget {
  static void _noOp(BuildContext context) {}

  final IconData _iconData;
  final String _retryText;
  final String _errorTitle;
  final String _errorDetail;
  final bool _isLoading;
  final Function _onRetry;

  RetryView({
    @required IconData iconData,
    @required String retryText,
    @required String errorTitle,
    @required String errorDetail,
    bool isLoading = false,
    Function onRetry = _noOp,
  })  : _iconData = iconData,
        _retryText = retryText,
        _errorTitle = errorTitle,
        _errorDetail = errorDetail,
        _isLoading = isLoading,
        _onRetry = onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromRGBO(238, 238, 238, .8),
                ),
                child: Icon(
                  _iconData,
                  size: 50,
                  color: Color.fromRGBO(20, 20, 20, .8),
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                _errorTitle,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Text(
                _errorDetail,
                style: TextStyle(
                  color: Color.fromRGBO(80, 80, 80, .8),
                ),
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isLoading
                ? CircularProgressIndicator()
                : FlatButton(
                    textColor: Colors.deepOrange,
                    child: Text(_retryText?.toUpperCase()),
                    onPressed: () {
                      _onRetry(context);
                    },
                  ),
          ],
        ),
      ],
    );
  }
}
