import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  CustomBottomNavigationBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'For you',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Headlines',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.star),
          label: 'Following',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.public),
          label: 'Newsstand',
        ),
      ],
    );
  }
}
