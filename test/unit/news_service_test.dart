import 'package:flutter_test/flutter_test.dart';
import 'package:newswave/services/news_service.dart';

void main() {
  group('NewsService', () {
    test('getNews should return a list of news articles', () async {
      final newsService = NewsService();
      final news = await newsService.getNews('general');
      expect(news, isList);
    });
  });
}
