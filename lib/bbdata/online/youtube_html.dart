
import 'dart:developer';

import 'package:youtube_explode_dart/youtube_explode_dart.dart';

Future<String> fetchVideoTitle(String url) async {
    try {
      var yt = YoutubeExplode();
      var videoId = VideoId(url);
      var video = await yt.videos.get(videoId);

      String title = video.title;
      return title;
    } catch (e) {
      log("$e");
      return "";
    }
  }


Future<String> getVideoThumbnailUrl(String url) async {
    try {
      var yt = YoutubeExplode();
      var videoId = VideoId(url);
      var video = await yt.videos.get(videoId);

      String? imageUrl = video.thumbnails.highResUrl;
      return imageUrl;
    } catch (e) {
      log("$e");
      return "";
    }
  }