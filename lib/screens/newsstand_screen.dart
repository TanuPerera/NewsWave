import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/news_source.dart';
import '../services/news_service.dart';
import '../widgets/BottomNavigationBar.dart';

class NewsstandScreen extends StatefulWidget {
  @override
  _NewsstandScreenState createState() => _NewsstandScreenState();
}

class _NewsstandScreenState extends State<NewsstandScreen> {
  final NewsService newsService = NewsService();
  List<NewsSource> newsSources = [];
  Set<String> followingSources = Set<String>();
  int _currentIndex = 3;

  @override
  void initState() {
    super.initState();
    _loadNewsSources();
  }

  Future<void> _loadNewsSources() async {
    try {
      Set<String> followingSourceIds =
          await newsService.getFollowingSourceIds();

      List<NewsSource>? sourcesData =
          await newsService.getNewsSources(followingSourceIds);

      setState(() {
        newsSources = sourcesData ?? [];
      });
    } catch (e) {
      print('Error loading news sources: $e');
    }
  }

  Future<void> _saveFollowingSourcesToStorage(Set<String> sources) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      List<String> storedFollowingSources =
          prefs.getStringList('followingSources') ?? [];

      storedFollowingSources.addAll(sources);

      storedFollowingSources = storedFollowingSources.toSet().toList();

      await prefs.setStringList('followingSources', storedFollowingSources);
    } catch (e) {
      print('Error saving following sources to storage: $e');
    }
  }

  Future<void> _followSource(String sourceId) async {
    try {
      setState(() {
        followingSources.add(sourceId);
      });

      await _saveFollowingSourcesToStorage(followingSources);
    } catch (e) {
      print('Error following source: $e');
    }
  }

  Future<void> _unfollowSource(String sourceId) async {
    setState(() {
      followingSources.remove(sourceId);
    });

    await _saveFollowingSourcesToStorage(followingSources);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Newsstand'),
        ),
        body: _buildNewsstandList(),
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

  Widget _buildNewsstandList() {
    return ListView.builder(
      itemCount: newsSources.length,
      itemBuilder: (context, index) {
        final newsSource = newsSources[index];
        final isFollowing = followingSources.contains(newsSource.id);

        return Card(
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ListTile(
            title: Text(
              newsSource.name,
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(newsSource.description),
            trailing: IconButton(
              icon: Icon(
                isFollowing ? Icons.favorite : Icons.favorite_border,
                color: isFollowing ? Colors.red : null,
              ),
              onPressed: () {
                isFollowing
                    ? _unfollowSource(newsSource.id)
                    : _followSource(newsSource.id);
              },
            ),
          ),
        );
      },
    );
  }
}
