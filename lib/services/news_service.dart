import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/news_source.dart';

class NewsService {
  static const String _apiKey = '457e2fc1f5674a5e8d3c050ebffd4f6b';
  static const List<String> _prohibitedWords = ['removed'];

  Future<List<dynamic>> getNews(String selectedCategory,
      {String? category}) async {
    try {
      final Map<String, String> parameters = {
        'apiKey': _apiKey,
        'language': 'en',
        'category': selectedCategory,
        if (category != null) 'category': category,
      };

      final Uri url = Uri.https(
        'newsapi.org',
        '/v2/top-headlines',
        parameters,
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> articles = jsonDecode(response.body)['articles'];

        final List<dynamic> filteredArticles = articles.where((article) {
          final String title = article['title'] ?? '';
          final String description = article['description'] ?? '';

          return !_containsProhibitedWords(title) &&
              !_containsProhibitedWords(description);
        }).toList();

        return filteredArticles;
      } else {
        print('Failed to load news - ${response.statusCode}: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error loading news: $e');
      return [];
    }
  }

  Future<List<dynamic>> searchNews(String query) async {
    try {
      final Map<String, String> parameters = {
        'apiKey': _apiKey,
        'language': 'en',
        'q': query,
      };

      final Uri url = Uri.https(
        'newsapi.org',
        '/v2/everything',
        parameters,
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> articles = jsonDecode(response.body)['articles'];

        final List<dynamic> filteredArticles = articles.where((article) {
          final String title = article['title'] ?? '';
          final String description = article['description'] ?? '';

          return !_containsProhibitedWords(title) &&
              !_containsProhibitedWords(description);
        }).toList();

        return filteredArticles;
      } else {
        print(
            'Failed to search news - ${response.statusCode}: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error searching news: $e');
      return [];
    }
  }

  Future<List<dynamic>> getHeadlines() async {
    try {
      final Map<String, String> parameters = {
        'apiKey': _apiKey,
        'country': 'us',
      };

      final Uri url = Uri.https(
        'newsapi.org',
        '/v2/top-headlines',
        parameters,
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> articles = jsonDecode(response.body)['articles'];

        final List<dynamic> filteredArticles = articles.where((article) {
          final String title = article['title'] ?? '';
          final String description = article['description'] ?? '';

          return !_containsProhibitedWords(title) &&
              !_containsProhibitedWords(description);
        }).toList();

        return filteredArticles;
      } else {
        print(
            'Failed to load headlines - ${response.statusCode}: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error loading headlines: $e');
      return [];
    }
  }

  Future<List<NewsSource>?> getNewsSources(Set<String> followingSources) async {
    try {
      final Map<String, String> parameters = {
        'apiKey': _apiKey,
        'country': 'us',
      };

      final Uri url = Uri.https(
        'newsapi.org',
        '/v2/top-headlines/sources',
        parameters,
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> sourcesData = jsonDecode(response.body)['sources'];

        List<NewsSource> newsSources = sourcesData
            .where((source) => !followingSources.contains(source['id']))
            .map((source) {
          return NewsSource(
            id: source['id'] ?? '',
            name: source['name'] ?? '',
            description: source['description'] ?? '',
          );
        }).toList();

        return newsSources;
      } else {
        print(
            'Failed to load news sources - ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error loading news sources: $e');
      return null;
    }
  }

  Future<Set<String>> getFollowingSourceIds() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String>? followingIds =
          prefs.getStringList('followingSources');

      if (followingIds == null) {
        return {};
      }

      return followingIds.toSet();
    } catch (e) {
      print('Error getting following source IDs: $e');
      return {};
    }
  }

  bool _containsProhibitedWords(String text) {
    return _prohibitedWords
        .any((word) => text.toLowerCase().contains(word.toLowerCase()));
  }
}
