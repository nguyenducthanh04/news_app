import 'package:flutter/material.dart';
import 'package:news_app/screens/app_bar.dart';
import 'package:news_app/screens/explore.dart';
import 'package:news_app/screens/home_tab.dart';
import 'package:news_app/screens/profile.dart';
import 'package:news_app/screens/saved.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0; 

  final List<Widget> _screens = [
    HomeTab(),
    Explore(),
    Saved(),
    ProfileScreen(),
  ];
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: _currentIndex == 3
        ? null // Không hiển thị AppBar ở tab Profile
        : CustomAppBar(), // Hiển thị AppBar ở các tab khác
    body: _screens[_currentIndex],
    bottomNavigationBar: BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex, // Tab đang được chọn
      onTap: (index) {
        setState(() {
          _currentIndex = index; 
        });
      },
      backgroundColor: Colors.black,
      selectedItemColor: Colors.white, 
      unselectedItemColor: Colors.grey, 
      elevation: 10, 
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Trang chủ",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore),
          label: "Khám phá",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.save),
          label: "Đã lưu",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Tài khoản",
        ),
      ],
    ),
  );
}

}

