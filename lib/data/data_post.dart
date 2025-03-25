class DataPost {
  int postId;
  String urlImage;
  String category;
  String type;
  String title;
  String date;
  String content;
  DataPost({required this.postId, required this.urlImage, required this.category, required this.type, required this.title, required this.date, required this.content});
  // Factory constructor để ánh xạ dữ liệu từ Firestore
  factory DataPost.fromMap(Map<String, dynamic> map) {
    return DataPost(
      postId: map['postId'] as int,
      urlImage: map['urlImage'] as String,
      category: map['category'] as String,
      type: map['type'] as String,
      title: map['title'] as String,
      date: map['date'] as String,
      content: map['content'] as String,
    );
  }
}









