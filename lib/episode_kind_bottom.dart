import "package:flutter/material.dart";

import "./models/episode.dart" show EpisodeKind;

class EpisodeKindBottom extends StatelessWidget {
  final EpisodeKind _kind;

  EpisodeKindBottom(this._kind);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _getIcon(),
    );
  }

  Widget _getIcon() {
    switch (_kind) {
      case EpisodeKind.MOSTLY_CANON:
        return Icon(
          Icons.star_half,
          color: Colors.lightGreen,
        );
      case EpisodeKind.CANON:
        return Icon(
          Icons.star,
          color: Colors.lightGreen,
        );
      case EpisodeKind.MOSTLY_FILLER:
        return Icon(
          Icons.star_half,
          color: Colors.deepOrangeAccent,
        );
      case EpisodeKind.FILLER:
        return Icon(
          Icons.star,
          color: Colors.deepOrangeAccent,
        );
    }

    return null;
  }
}
