import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:news_app/data/data_post.dart';
import 'package:news_app/screens/post_detail.dart';

class Explore extends StatelessWidget {
  const Explore({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Khám phá Thế Giới",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("news").where("type", isEqualTo: 'World').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Không có dữ liệu', style: TextStyle(color: Colors.white),));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
                }
                final posts = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index].data() as Map<String, dynamic>;
                    final dataPost = DataPost.fromMap(post);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: GestureDetector(
                        onTap: () {
                          // Chuyển đến màn hình chi tiết
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostDetailScreen(post: dataPost),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0), // Loại bỏ bo góc
                            side: BorderSide.none, // Loại bỏ viền mặc định của Card
                          ),
                          elevation: 0, // Loại bỏ đổ bóng để giống giao diện
                          color: Colors.black,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Đường kẻ xám phía trên
                              Container(
                                height: 1.0,
                                color: Colors.grey[600], // Màu xám nhạt cho đường kẻ
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0), // Giữ padding
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Danh mục
                                    Text(
                                      post['category'],
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    // Tiêu đề bài viết
                                    Text(
                                      post['title'],
                                      style: const TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2, // Cho phép tiêu đề xuống dòng nếu cần
                                    ),
                                    const SizedBox(height: 8.0),
                                    // Hình ảnh minh họa
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        post['urlImage'],
                                        height: 200.0,
                                        width: double.infinity, // Hình ảnh chiếm toàn bộ chiều rộng
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                                      ),
                                    ),
                                    const SizedBox(height: 16.0),
                                    // Thời gian, nguồn và số bình luận
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'CNN',
                                              style: TextStyle(
                                                fontSize: 14.0,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(width: 8.0),
                                            Text(
                                              dataPost.date,
                                              style: TextStyle(
                                                fontSize: 14.0,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.comment, color: Colors.grey, size: 20.0),
                                            const SizedBox(width: 4.0),
                                            Text(
                                              '22', // Giá trị số bình luận, bạn có thể thay bằng dữ liệu thực tế
                                              style: TextStyle(
                                                fontSize: 14.0,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(width: 8.0),
                                            Icon(Icons.share, color: Colors.grey, size: 20.0),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Đường kẻ xám phía dưới
                              Container(
                                height: 1.0,
                                color: Colors.grey[600], // Màu xám nhạt cho đường kẻ
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Khám phá Việt Nam",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("news").where("type", isEqualTo: 'VietNam').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Không có dữ liệu', style: TextStyle(color: Colors.white),));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
                }
                final posts = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index].data() as Map<String, dynamic>;
                    final dataPost = DataPost.fromMap(post);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: GestureDetector(
                        onTap: () {
                          // Chuyển đến màn hình chi tiết
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostDetailScreen(post: dataPost),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0), // Loại bỏ bo góc
                            side: BorderSide.none, // Loại bỏ viền mặc định của Card
                          ),
                          elevation: 0, // Loại bỏ đổ bóng để giống giao diện
                          color: Colors.black,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Đường kẻ xám phía trên
                              Container(
                                height: 1.0,
                                color: Colors.grey[600], // Màu xám nhạt cho đường kẻ
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0), // Giữ padding
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Danh mục
                                    Text(
                                      post['category'],
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    // Tiêu đề bài viết
                                    Text(
                                      post['title'],
                                      style: const TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2, // Cho phép tiêu đề xuống dòng nếu cần
                                    ),
                                    const SizedBox(height: 8.0),
                                    // Hình ảnh minh họa
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        post['urlImage'],
                                        height: 200.0,
                                        width: double.infinity, // Hình ảnh chiếm toàn bộ chiều rộng
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                                      ),
                                    ),
                                    const SizedBox(height: 16.0),
                                    // Thời gian, nguồn và số bình luận
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'CNN',
                                              style: TextStyle(
                                                fontSize: 14.0,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(width: 8.0),
                                            Text(
                                              dataPost.date,
                                              style: TextStyle(
                                                fontSize: 14.0,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.comment, color: Colors.grey, size: 20.0),
                                            const SizedBox(width: 4.0),
                                            Text(
                                              '22', // Giá trị số bình luận, bạn có thể thay bằng dữ liệu thực tế
                                              style: TextStyle(
                                                fontSize: 14.0,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(width: 8.0),
                                            Icon(Icons.share, color: Colors.grey, size: 20.0),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Đường kẻ xám phía dưới
                              Container(
                                height: 1.0,
                                color: Colors.grey[600], // Màu xám nhạt cho đường kẻ
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}