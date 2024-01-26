import 'package:flutter/material.dart';
import '../services/news_service.dart';
import '../widgets/BottomNavigationBar.dart';

class HeadlinesScreen extends StatefulWidget {
  @override
  _HeadlinesScreenState createState() => _HeadlinesScreenState();
}

class _HeadlinesScreenState extends State<HeadlinesScreen> {
  final NewsService newsService = NewsService();
  List<String> headlines = [];
  bool isLoading = false;
  bool isError = false;
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadHeadlines();
  }

  Future<void> _loadHeadlines() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      List<dynamic> headlinesData = await newsService.getHeadlines();

      setState(() {
        headlines =
            headlinesData.map((item) => item['title'].toString()).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading headlines: $e');
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  Future<void> _refresh() async {
    await _loadHeadlines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Headlines'),
        ),
        body: _buildHeadlinesList(),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onBottomNavTapped,
        ));
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

  Widget _buildHeadlinesList() {
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
              'Failed to load headlines. Please try again.',
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _loadHeadlines,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    } else if (headlines.isEmpty) {
      return Center(
        child: Text(
          'No headlines available.',
          style: TextStyle(fontSize: 16.0),
        ),
      );
    } else {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
          itemCount: headlines.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 4.0,
              margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ListTile(
                title: Text(
                  headlines[index],
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                // Add more details or customize the ListTile as needed
              ),
            );
          },
        ),
      );
    }
  }
}
