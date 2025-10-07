
class PaginatedVideoModel{
  final int page;
  final int perPage;
  final List<VideoModel> videos;
  final String? nextPage;

  PaginatedVideoModel({
    required this.page,
    required this.perPage,
    required this.videos,
    this.nextPage
  });

  factory PaginatedVideoModel.fromJson(Map<String,dynamic> json){
    return PaginatedVideoModel(
        page: (json['page'] as num).toInt(),
        perPage: (json['per_page'] as num).toInt(),
        videos: List<VideoModel>.from(json['videos'].map((i)=>VideoModel.fromJson(i))),
        nextPage: json["next_page"] as String?
    );
  }
}


class VideoModel{
  final int id;
  final int duration;
  final int width;
  final int height;
  final String image;
  final List<VideoFiles> videoFiles;
  final List<VideoPreviewPicture> videoPictures;

  VideoModel({
    required this.id,
    required this.duration,
    required this.width,
    required this.height,
    required this.image,
    required this.videoFiles,
    required this.videoPictures
  });

  factory VideoModel.fromJson(Map<String,dynamic> json){
    return VideoModel(
        id: (json['id'] as num).toInt(),
        duration: (json['duration'] as num).toInt(),
        width: (json['width'] as num).toInt(),
        height: (json['height'] as num).toInt(),
        image: json['image'].toString(),
        videoFiles: List<VideoFiles>.from(json['video_files'].map((i)=>VideoFiles.fromJson(i))),
        videoPictures: (json["video_pictures"] as List<dynamic>).map((i)=>VideoPreviewPicture.fromJson(i)).toList()
    );
  }
}

class VideoFiles{
  final int id;
  final String quality;
  final double fps;
  final String link;

  VideoFiles({
    required this.id,
    required this.quality,
    required this.fps,
    required this.link
  });

  factory VideoFiles.fromJson(Map<String,dynamic> json){
    return VideoFiles(
        id: (json['id'] as num).toInt(),
        quality: json['quality'] as String,
        fps: (json['fps'] as num).toDouble(),
        link: json['link'] as String
    );
  }
}

class VideoPreviewPicture{
  final int id;
  final String picture;

  VideoPreviewPicture({
    required this.id,
    required this.picture
  });

  factory VideoPreviewPicture.fromJson(Map<String,dynamic> json){
    return VideoPreviewPicture(
        id: (json['id'] as num).toInt(),
        picture: json['picture'] as String
    );
  }
}