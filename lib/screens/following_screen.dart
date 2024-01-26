import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/BottomNavigationBar.dart';

class FollowingScreen extends StatefulWidget {
  @override
  _FollowingScreenState createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  List<String> followingItems = [];
  bool isLoading = false;
  bool isError = false;
  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    _loadFollowingItems();
  }

  Future<void> _loadFollowingItems() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? storedFollowingItems =
          prefs.getStringList('followingSources');

      if (storedFollowingItems != null) {
        setState(() {
          followingItems = storedFollowingItems;
          isLoading = false;
        });
      } else {
        setState(() {
          followingItems = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading following items: $e');
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  Future<void> _refresh() async {
    await _loadFollowingItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Following'),
      ),
      body: _buildFollowingItemsList(),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
      ),
    );
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/headlines');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/following');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/newsstand');
        break;
    }
  }

  Widget _buildFollowingItemsList() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (isError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error,
              size: 40.0,
              color: Colors.red,
            ),
            SizedBox(height: 8.0),
            Text(
              'Failed to load following items. Please try again.',
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _loadFollowingItems,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    } else if (followingItems.isEmpty) {
      return Center(
        child: Text(
          'No following items available.',
          style: TextStyle(fontSize: 16.0),
        ),
      );
    } else {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
          itemCount: followingItems.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _onFollowingItemClicked(followingItems[index]),
              child: Card(
                elevation: 4.0,
                margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ListTile(
                  title: Text(
                    followingItems[index],
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.favorite,
                      color: Colors.red, // Set color to red for following items
                    ),
                    onPressed: () => _unfollowItem(followingItems[index]),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
  }

  void _onFollowingItemClicked(String item) {
    Navigator.pushNamed(context, '/home', arguments: item);
  }

  Future<void> _unfollowItem(String item) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedFollowingItems =
        prefs.getStringList('followingSources');

    if (storedFollowingItems != null && storedFollowingItems.contains(item)) {
      storedFollowingItems.remove(item);
      await prefs.setStringList('followingSources', storedFollowingItems);
      setState(() {
        followingItems = storedFollowingItems;
      });
    }
  }
}
