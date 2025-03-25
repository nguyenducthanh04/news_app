import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app/data/data_post.dart';
import 'package:news_app/screens/post_detail.dart';
import 'package:intl/intl.dart'; // Import cho DateFormat
import 'package:intl/date_symbol_data_local.dart'; // Import cho initializeDateFormatting

// Widget riêng cho phần "Tin tức" (Banner)
class NewsBanner extends StatelessWidget {
  const NewsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Tin tức",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('news')
              .limit(5) // Giới hạn số lượng banner (ví dụ: 5)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No news found for banner'));
            }

            // Ánh xạ dữ liệu từ Firestore thành danh sách DataPost
            final bannerData = snapshot.data!.docs.map((doc) {
              return DataPost.fromMap(doc.data() as Map<String, dynamic>);
            }).toList();

            // Hiển thị danh sách banner bằng ListView.builder
            return SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: bannerData.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Chuyển đến màn hình chi tiết khi nhấn vào banner
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PostDetailScreen(post: bannerData[index]),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              bannerData[index].urlImage,
                              width: 300,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            left: 10,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bannerData[index].category,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  bannerData[index].title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String searchQuery = ''; // Biến lưu từ khóa tìm kiếm
  bool isLocaleInitialized = false; // Biến kiểm tra xem locale đã khởi tạo chưa

  @override
  void initState() {
    super.initState();
    // Khởi tạo localization cho định dạng ngày tháng
    _initializeLocale();
  }

  // Hàm khởi tạo locale bất đồng bộ
  Future<void> _initializeLocale() async {
    await initializeDateFormatting('vi', null);
    setState(() {
      isLocaleInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TextField để tìm kiếm
            Container(
              child: TextField(
                style: const TextStyle(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm...', // Gợi ý trong ô tìm kiếm
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                ),
                onChanged: (value) {
                  // Cập nhật từ khóa tìm kiếm và rebuild giao diện
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
            const SizedBox(height: 30),

            // Phần 1: Tin tức (Banner) - Sử dụng widget riêng
            const NewsBanner(),
            const SizedBox(height: 20),

            // Phần 2: Tin hot
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Tin hot",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('news').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No posts found'));
                }

                final dataPost = snapshot.data!.docs.map((doc) {
                  return DataPost.fromMap(doc.data() as Map<String, dynamic>);
                }).toList();

                // Lọc danh sách bài viết dựa trên từ khóa tìm kiếm
                final filteredDataPost = dataPost.where((post) {
                  final title = post.title.toLowerCase();
                  final category = post.category.toLowerCase();
                  return title.contains(searchQuery) ||
                      category.contains(searchQuery);
                }).toList();

                if (filteredDataPost.isEmpty) {
                  return const Center(child: Text('Không tìm thấy bài viết nào'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredDataPost.length,
                  itemBuilder: (context, index) {
                    // Định dạng ngày tháng nếu cần
                    String? formattedDate;
                    if (filteredDataPost[index].date.isNotEmpty) {
                      try {
                        final dateTime = DateTime.parse(filteredDataPost[index].date);
                        if (isLocaleInitialized) {
                          formattedDate = DateFormat('dd/MM/yyyy', 'vi').format(dateTime);
                        } else {
                          formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
                        }
                      } catch (e) {
                        formattedDate = filteredDataPost[index].date;
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PostDetailScreen(post: filteredDataPost[index]),
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
                                      filteredDataPost[index].category,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    // Tiêu đề bài viết
                                    Text(
                                      filteredDataPost[index].title,
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
                                        filteredDataPost[index].urlImage,
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
                                              formattedDate ?? filteredDataPost[index].date,
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