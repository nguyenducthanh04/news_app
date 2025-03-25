import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app/data/data_post.dart';
import 'package:news_app/screens/post_detail.dart';

class Saved extends StatelessWidget {
  const Saved({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin người dùng hiện tại
    User? user = FirebaseAuth.instance.currentUser;

    // Kiểm tra nếu người dùng chưa đăng nhập
    if (user == null) {
      return const Center(
        child: Text(
          "Vui lòng đăng nhập để xem bài viết đã lưu.",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    // In UID để kiểm tra
    print("Current user UID: ${user.uid}");

    return StreamBuilder<QuerySnapshot>(
      // Truy cập subcollection 'saved_posts' bên trong document của người dùng trong collection 'users'
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('saved_posts')
          .snapshots(),
      builder: (context, snapshot) {
        // Hiển thị vòng tròn tải khi đang lấy dữ liệu
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Hiển thị thông báo lỗi nếu có lỗi xảy ra
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Lỗi khi lấy bài viết đã lưu: ${snapshot.error}",
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        // Hiển thị thông báo nếu không có bài viết nào
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "Không có bài viết nào được lưu.",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        // Chuyển đổi dữ liệu từ Firestore thành danh sách DataPost
        List<DataPost> dataPost = snapshot.data!.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return DataPost(
            postId: int.tryParse(data['postId'] ?? '0') ?? 0, // Lấy postId từ dữ liệu
            urlImage: data['urlImage'] ?? "assets/images/post0.jpg",
            category: data['category'] ?? "Không xác định",
            type: data['type'] ?? "Không xác định",
            title: data['title'] ?? "Không có tiêu đề",
            date: data['date'] ?? "Không có ngày",
            content: data['content'] ?? "Không có nội dung", // Không có trường content, để mặc định
          );
        }).toList();

        // Giữ nguyên giao diện cũ
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Bài viết đã lưu",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: dataPost.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: GestureDetector(
                        onTap: () {
                          // Chuyển đến màn hình chi tiết
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PostDetailScreen(post: dataPost[index]),
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
                                      dataPost[index].category,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    // Tiêu đề bài viết
                                    Text(
                                      dataPost[index].title,
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
                                        dataPost[index].urlImage,
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
                                              dataPost[index].date,
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
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}