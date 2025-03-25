import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.only(left: 10),
            child: Text("Aa", style: TextStyle(color: Colors.white),),
          ),
          Center(
            child: Container(
              margin: EdgeInsets.only(left: 8),
              child: Text("VnExpress", style: TextStyle(color: Colors.white),),
            ),
          ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(100.0),
                ),
                child: Image.asset(
                  "assets/images/thongbao.png",
                  width: 40,
                  height: 40,
                ),
              ),
            // ],
          // ),
         // )
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(60.0);
}
