import "package:cloud_firestore/cloud_firestore.dart" show DocumentSnapshot;

class Episode {
  final String id;
  final String fbId;
  final int epNum;
  final EpisodeKind kind;
  final String link;
  final String title;
  final DateTime airdate;

  const Episode({
    this.id,
    this.fbId,
    this.epNum,
    this.kind,
    this.link,
    this.title,
    this.airdate,
  });

  factory Episode.fromDocument(DocumentSnapshot document) {
    return Episode(
      id: document["id"],
      fbId: document.documentID,
      epNum: document["epNum"],
      kind: _mapKind(document["kind"]),
      link: document["link"],
      title: document["title"],
      airdate: DateTime.parse(document["airdate"]),
    );
  }
}

class EpisodeRange {
  final int init;
  final int end;
  final EpisodeKind kind;

  const EpisodeRange({
    this.init,
    this.end,
    this.kind,
  });
}

enum EpisodeKind {
  MOSTLY_CANON,
  CANON,
  MOSTLY_FILLER,
  FILLER,
}

EpisodeKind _mapKind(int fbKind) {
  switch (fbKind) {
    case 1:
      return EpisodeKind.MOSTLY_CANON;
    case 2:
      return EpisodeKind.CANON;
    case 3:
      return EpisodeKind.MOSTLY_FILLER;
    case 4:
      return EpisodeKind.FILLER;
  }

  return null;
}
