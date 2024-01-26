import 'package:flutter/material.dart';
import '../widgets/BottomNavigationBar.dart';
import '../widgets/news_widget.dart';
import '../models/news_model.dart';
import '../services/news_service.dart';

class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final NewsService newsService = NewsService();
  List<News> newsList = [];
  String selectedCategory = 'general';
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    await loadNews();
  }

  Future<void> loadNews({String? query}) async {
    try {
      List<dynamic> data;

      if (query != null && query.isNotEmpty) {
        data = await newsService.searchNews(query);
      } else {
        data = await newsService.getNews(selectedCategory);
      }

      final List<News> loadedNews = data
          .map((item) => News(
                title: item['title'] ?? '',
                description: item['description'] ?? '',
                url: item['url'] ?? '',
                imageUrl: item['urlToImage'] ?? '',
              ))
          .toList();

      setState(() {
        newsList = loadedNews;
      });
    } catch (e) {
      print('Error loading news: $e');
      _showErrorSnackbar();
    }
  }

  void _showErrorSnackbar() {
    final snackBar = SnackBar(
      content: Text('Failed to load news. Please check your connection.'),
      action: SnackBarAction(
        label: 'Retry',
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          _refresh();
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void changeCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
    loadNews();
  }

  void onSearchTextChanged(String newText) {
    loadNews(query: newText);
  }

  @override
  Widget build(BuildContext context) {
    final String? selectedItem =
        ModalRoute.of(context)!.settings.arguments as String?;
    if (selectedItem != null) {
      loadNews(query: selectedItem);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('News'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: NewsSearchDelegate(onSearchTextChanged),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCategories(),
          Expanded(
            child: RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _refresh,
              child: _buildNewsList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      height: 50.0,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCategoryChip('General', 'general'),
          _buildCategoryChip('Business', 'business'),
          _buildCategoryChip('Technology', 'technology'),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String category) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: selectedCategory == category,
        onSelected: (selected) {
          if (selected) {
            changeCategory(category);
          }
        },
      ),
    );
  }

  Widget _buildNewsList() {
    if (newsList.isEmpty) {
      return Center(
        child: Text('No news available.'),
      );
    } else {
      return ListView.builder(
        itemCount: newsList.length,
        itemBuilder: (context, index) {
          return NewsWidget(news: newsList[index]);
        },
      );
    }
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
}

class NewsSearchDelegate extends SearchDelegate<String> {
  final Function(String) onSearchTextChanged;

  NewsSearchDelegate(this.onSearchTextChanged);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          onSearchTextChanged('');
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: NewsService().searchNews(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No results found.'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              return ListTile(
                title: Text(item['title'] ?? ''),
                subtitle: Text(item['description'] ?? ''),
                onTap: () {
                  onSearchTextChanged(query);
                  close(context, '');
                },
              );
            },
          );
        }
      },
    );
  }
}
