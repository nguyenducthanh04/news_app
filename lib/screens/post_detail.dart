import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/svg.dart';
import 'package:news_app/data/data_post.dart';

class PostDetailScreen extends StatelessWidget {
  final DataPost post;

  const PostDetailScreen({Key? key, required this.post}) : super(key: key);

  // Hàm lưu bài viết vào Firestore
  Future<void> _savePost(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bạn cần đăng nhập để lưu bài viết")),
      );
      return;
    }

    final userId = user.uid;
    final postId = post.postId.toString();

    try {
      // Kiểm tra xem bài viết đã được lưu chưa
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('saved_posts')
          .doc(postId)
          .get();

      if (doc.exists) {
        // Nếu bài viết đã được lưu, xóa bài viết khỏi danh sách đã lưu
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('saved_posts')
            .doc(postId)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã xóa bài viết khỏi danh sách đã lưu")),
        );
      } else {
        // Nếu bài viết chưa được lưu, lưu bài viết vào subcollection saved_posts
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('saved_posts')
            .doc(postId)
            .set({
          'postId': postId,
          'userId': userId,
          'urlImage': post.urlImage,
          'category': post.category,
          'title': post.title,
          'date': post.date,
          'content': post.content,
          'savedAt': Timestamp.now(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bài viết đã được lưu")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi lưu bài viết: $e")),
      );
    }
  }

  // Hàm xóa bài viết khỏi danh sách yêu thích
  Future<void> _removeFromFavorites(BuildContext context, String postId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userId = user.uid;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('saved_posts')
          .doc(postId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã xóa bài viết khỏi danh sách yêu thích")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi xóa bài viết: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final postId = post.postId.toString();

    // Nếu người dùng đã đăng nhập, sử dụng StreamBuilder để kiểm tra trạng thái lưu bài viết
    if (user != null) {
      final userId = user.uid;
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('saved_posts')
            .doc(postId)
            .snapshots(),
        builder: (context, snapshot) {
          // Kiểm tra trạng thái của bài viết (đã lưu hay chưa)
          bool isSaved = snapshot.hasData && snapshot.data!.exists;

          return _buildScaffold(context, isSaved, postId);
        },
      );
    }

    // Nếu người dùng chưa đăng nhập, hiển thị giao diện mà không cần kiểm tra trạng thái lưu
    return _buildScaffold(context, false, postId);
  }

  // Hàm xây dựng giao diện Scaffold
  Widget _buildScaffold(BuildContext context, bool isSaved, String postId) {
    return Scaffold(
      appBar: AppBar(
        title: Text(post.title, style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: isSaved
                    ? SvgPicture.asset(
                  "assets/images/remove.svg", // Icon "xóa"
                  width: 25,
                  height: 25,
                  colorFilter: const ColorFilter.mode(
                    Colors.white, // Màu bạn muốn áp dụng
                    BlendMode.srcIn, // Chế độ hòa trộn màu
                  ),
                )
                    : Image.asset(
                  "assets/images/saved.png", // Icon "lưu"
                  width: 25,
                  height: 25,
                ),
                onPressed: () {
                  if (isSaved) {
                    // Nếu bài viết đã được lưu, gọi hàm xóa
                    _removeFromFavorites(context, postId);
                  } else {
                    // Nếu bài viết chưa được lưu, gọi hàm lưu
                    _savePost(context);
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.category,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                post.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                post.date,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  post.urlImage,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                post.content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}