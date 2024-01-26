import 'package:flutter/material.dart';
import 'package:share/share.dart';
import '../models/news_model.dart';
import '../screens/webview_screen.dart';

class NewsWidget extends StatelessWidget {
  final News news;

  NewsWidget({required this.news});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () => _openArticle(context),
        onLongPress: () => _shareArticle(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImage(),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
        child: news.imageUrl.isNotEmpty
            ? Image.network(
                news.imageUrl,
                fit: BoxFit.cover,
              )
            : Container(
                color: Colors.grey[300],
                child: Center(
                  child: Icon(
                    Icons.image,
                    size: 40.0,
                    color: Colors.grey,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            news.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            news.description,
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  void _shareArticle(BuildContext context) {
    final String textToShare = '${news.title}\n${news.url}';
    Share.share(textToShare);
  }

  void _openArticle(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewScreen(url: news.url),
      ),
    );
  }
}
