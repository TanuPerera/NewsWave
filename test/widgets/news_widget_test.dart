import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newswave/models/news_model.dart';
import 'package:newswave/widgets/news_widget.dart';

void main() {
  testWidgets('NewsWidget displays news title and description',
      (WidgetTester tester) async {
    final news = News(
      title: 'Test Title',
      description: 'Test Description',
      url: 'https://example.com',
      imageUrl: '',
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: NewsWidget(news: news),
      ),
    ));

    expect(find.text('Test Title'), findsOneWidget);
    expect(find.text('Test Description'), findsOneWidget);
  });
}
