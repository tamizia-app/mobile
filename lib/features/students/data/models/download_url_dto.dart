class DownloadUrlDto {
  const DownloadUrlDto({required this.downloadUrl});

  factory DownloadUrlDto.fromJson(Map<String, dynamic> json) {
    final value = json['download_url'];
    if (value is! String) {
      throw const FormatException('Invalid download URL response.');
    }
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme) {
      throw const FormatException('Invalid download URL response.');
    }
    return DownloadUrlDto(downloadUrl: uri);
  }

  final Uri downloadUrl;
}
