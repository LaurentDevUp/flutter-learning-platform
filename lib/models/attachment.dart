enum AttachmentType {
  pdf,
  video,
  youtube,
  image,
}

class Attachment {
  final String id;
  final String ficheId;
  final String fileName;
  final AttachmentType fileType;
  final String fileUrl;
  final String? localPath;
  final int? fileSize;
  final bool isDownloaded;
  final DateTime createdAt;

  Attachment({
    required this.id,
    required this.ficheId,
    required this.fileName,
    required this.fileType,
    required this.fileUrl,
    this.localPath,
    this.fileSize,
    required this.isDownloaded,
    required this.createdAt,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'],
      ficheId: json['fiche_id'],
      fileName: json['file_name'],
      fileType: AttachmentType.values.firstWhere(
        (e) => e.toString().split('.').last == json['file_type'],
      ),
      fileUrl: json['file_url'],
      localPath: json['local_path'],
      fileSize: json['file_size'],
      isDownloaded: json['is_downloaded'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fiche_id': ficheId,
      'file_name': fileName,
      'file_type': fileType.toString().split('.').last,
      'file_url': fileUrl,
      'local_path': localPath,
      'file_size': fileSize,
      'is_downloaded': isDownloaded,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Attachment copyWith({
    String? id,
    String? ficheId,
    String? fileName,
    AttachmentType? fileType,
    String? fileUrl,
    String? localPath,
    int? fileSize,
    bool? isDownloaded,
    DateTime? createdAt,
  }) {
    return Attachment(
      id: id ?? this.id,
      ficheId: ficheId ?? this.ficheId,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      fileUrl: fileUrl ?? this.fileUrl,
      localPath: localPath ?? this.localPath,
      fileSize: fileSize ?? this.fileSize,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
