class Entry {
  final int? id;
  final String title;
  final String username;
  final String password;
  final String url;
  final String notes;

  Entry(
      {this.id,
      required this.title,
      required this.username,
      required this.password,
      required this.url,
      required this.notes});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'password': password,
      'url': url,
      'notes': notes
    };
  }

  factory Entry.fromMap(Map<String, dynamic> map) {
    return Entry(
        id: map['id'],
        title: map['title'],
        username: map['username'],
        password: map['password'],
        url: map['url'],
        notes: map['notes']);
  }
}
