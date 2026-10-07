import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:new_sara/l10n/app_localizations.dart';

class VideoItem {
  final String language;
  final String title;
  final String url;

  const VideoItem({
    required this.language,
    required this.title,
    required this.url,
  });
}

class VideoScreen extends StatelessWidget {
  final String language;

  const VideoScreen({super.key, required this.language});

  final List<VideoItem> allVideos = const [
    // VideoItem(
    //   language: 'HINDI',
    //   title: 'Hindi Video Sample',
    //   url: 'https://www.youtube.com/watch?v=-Ub5N5Qa5T8',
    // ),
    VideoItem(
      language: 'ENGLISH',
      title: 'English Video Sample',
      url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    ),
  ];

  void _launchURL(String url, BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw l10n?.couldNotLaunchUrl(url) ?? 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filteredVideos = allVideos
        .where(
          (video) => video.language.toLowerCase() == language.toLowerCase(),
        )
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade300,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n?.videos ?? "Videos",
          style: const TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: filteredVideos.isEmpty
            ? Center(
                child: Text(
                  l10n?.noVideosAvailable ?? "No videos available for this language",
                ),
              )
            : ListView.builder(
                itemCount: filteredVideos.length,
                itemBuilder: (context, index) {
                  final video = filteredVideos[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Text(
                              video.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xffFF6f00),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Divider(),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _launchURL(video.url, context),
                            child: Center(
                              child: Text(
                                video.url,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
