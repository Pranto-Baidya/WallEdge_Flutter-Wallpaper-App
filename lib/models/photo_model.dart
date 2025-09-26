class PhotoModel {
  final int id;
  final int height;
  final int width;
  final String url;
  final String photographer;
  final String? photographerUrl;
  final String? avgColor;
  final String? srcPortrait;
  final String? srcOriginal;
  final String? srcLarge2x;
  final String? srcMedium;

  PhotoModel({
    required this.id,
    required this.height,
    required this.width,
    required this.url,
    required this.photographer,
    this.photographerUrl,
    this.avgColor,
    this.srcPortrait,
    this.srcOriginal,
    this.srcLarge2x,
    this.srcMedium,
  });

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    final src = json['src'] ?? {};
    return PhotoModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      height: (json['height'] as num?)?.toInt() ?? 0,
      width: (json['width'] as num?)?.toInt() ?? 0,
      url: json['url']?.toString() ?? '',
      photographer: json['photographer']?.toString() ?? '',
      photographerUrl: json['photographer_url'] as String?,
      avgColor: json['avg_color'] as String?,
      srcPortrait: src['portrait'] as String?,
      srcOriginal: src['original'] as String?,
      srcLarge2x: src['large2x'] as String?,
      srcMedium: src['medium'] as String?,
    );
  }

  factory PhotoModel.fromMap(Map<String, dynamic> map) {
    return PhotoModel(
      id: map['id'],
      height: map['height'],
      width: map['width'],
      url: map['url'],
      photographer: map['photographer'] ?? '',
      photographerUrl: map['photographerUrl'],
      avgColor: map['avgColor'],
      srcPortrait: map['srcPortrait'],
      srcOriginal: map['srcOriginal'],
      srcLarge2x: map['srcLarge2x'],
      srcMedium: map['srcMedium'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'height': height,
      'width': width,
      'url': url,
      'photographer': photographer,
      'photographerUrl': photographerUrl,
      'avgColor': avgColor,
      'srcPortrait': srcPortrait,
      'srcOriginal': srcOriginal,
      'srcLarge2x': srcLarge2x,
      'srcMedium': srcMedium,
    };
  }
}
