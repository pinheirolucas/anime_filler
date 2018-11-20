import "package:cloud_firestore/cloud_firestore.dart" show DocumentSnapshot;

class Title {
  final String id;
  final String fbId;
  final String cover;
  final String description;
  final String fbCover;
  final String fillerInfo;
  final String link;
  final String name;
  final DateTime updatedAt;

  const Title({
    this.id,
    this.fbId,
    this.cover,
    this.description,
    this.fbCover,
    this.fillerInfo,
    this.link,
    this.name,
    this.updatedAt,
  });

  factory Title.fromDocument(DocumentSnapshot document) {
    return Title(
      id: document["id"],
      fbId: document.documentID,
      cover: document["cover"],
      description: document["description"],
      fbCover: document["fbCover"],
      fillerInfo: document["fillerInfo"],
      link: document["link"],
      name: document["title"],
      updatedAt: DateTime.parse(document["updatedAt"]),
    );
  }
}
