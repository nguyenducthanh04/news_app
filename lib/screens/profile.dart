import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return LoginScreen();
    }

    // Lấy thông tin người dùng từ currentUser
    String userName = user.displayName ?? "Người dùng";
    String userEmail = user.email ?? "Không có email";

    // Lấy số lượng bài viết đã lưu từ subcollection 'saved_posts'
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('saved_posts')
          .snapshots(),
      builder: (context, savedPostsSnapshot) {
        // Hiển thị vòng tròn tải khi đang lấy dữ liệu
        if (savedPostsSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Hiển thị thông báo lỗi nếu có lỗi xảy ra
        if (savedPostsSnapshot.hasError) {
          return const Center(
            child: Text(
              "Lỗi khi lấy số lượng bài viết đã lưu.",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        // Đếm số lượng bài viết đã lưu
        int savedCount = savedPostsSnapshot.data?.docs.length ?? 0;

        // Giao diện chính
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Tài khoản",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Column(
                children: [
                  // Profile Picture with Edit Icon
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage('assets/images/user.png'),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            print('Edit button clicked');
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 20,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userEmail,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Stats Section (Interesting, Saved, Following)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatBox("5", "Đã xem"),
                      _buildStatBox(savedCount.toString(), "Đã lưu"),
                      _buildStatBox("12", "Theo dõi"),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Settings Section
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Cài đặt",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildSettingsItem(
                    context,
                    icon: Icons.notifications,
                    title: "Thông báo",
                    onTap: () {
                      print("Notifications Center tapped");
                    },
                  ),
                  _buildSettingsItem(
                    context,
                    icon: Icons.lock,
                    title: "Thay đổi mật khẩu",
                    onTap: () {
                      print("Change Password tapped");
                    },
                  ),
                  _buildSettingsItem(
                    context,
                    icon: Icons.language,
                    title: "Ngôn ngữ",
                    onTap: () {
                      print("Language tapped");
                    },
                  ),
                  _buildSettingsItem(
                    context,
                    icon: Icons.help,
                    title: "FAQs",
                    onTap: () {
                      print("FAQs tapped");
                    },
                  ),
                  const SizedBox(height: 20),
                  // Log Out Button
                  Container(
                    margin: const EdgeInsets.only(bottom: 50),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          // Hiển thị dialog xác nhận
                          bool? confirmLogout = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Xác nhận"),
                                content: const Text("Bạn có chắc chắn muốn đăng xuất không?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false); // Người dùng chọn "Không"
                                    },
                                    child: const Text("Không"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true); // Người dùng chọn "Có"
                                    },
                                    child: const Text("Có"),
                                  ),
                                ],
                              );
                            },
                          );

                          // Kiểm tra nếu người dùng xác nhận đăng xuất
                          if (confirmLogout == true) {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => ProfileScreen()),
                                  (route) => false,
                            );
                            print("Log Out tapped");
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.orange),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout,
                              color: Colors.red,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Đăng xuất",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper method to build stat boxes (Interesting, Saved, Following)
  Widget _buildStatBox(String count, String label) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build settings list items
  Widget _buildSettingsItem(BuildContext context,
      {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.orange,
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}