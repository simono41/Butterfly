import 'dart:convert';
import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'document.dart';

part 'asset.freezed.dart';
part 'asset.g.dart';

enum AssetFileType { note, image, pdf, svg }

@freezed
class AssetLocation with _$AssetLocation {
  const factory AssetLocation({
    @Default('') String remote,
    required String path,
    @Default(false) bool absolute,
  }) = _AssetLocation;

  factory AssetLocation.local(String path, [bool absolute = false]) =>
      AssetLocation(path: path, absolute: absolute);

  factory AssetLocation.fromJson(Map<String, dynamic> json) =>
      _$AssetLocationFromJson(json);

  const AssetLocation._();

  String get identifier =>
      remote == '' ? pathWithLeadingSlash : '$remote@$pathWithLeadingSlash';

  String get pathWithLeadingSlash => path.startsWith('/') ? path : '/$path';

  String get pathWithoutLeadingSlash =>
      path.startsWith('/') ? path.substring(1) : path;

  AssetFileType? get fileType {
    final ext = path.split('.').last;
    switch (ext) {
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
      case 'bmp':
      case 'ico':
        return AssetFileType.image;
      case 'pdf':
        return AssetFileType.pdf;
      case 'svg':
        return AssetFileType.svg;
      case 'bfly':
      case 'json':
      case '':
        return AssetFileType.note;
      default:
        return null;
    }
  }

  String get fileName => path.split('/').last.split('.').first;
}

@freezed
class AppDocumentEntity with _$AppDocumentEntity {
  const AppDocumentEntity._();

  const factory AppDocumentEntity.file(AssetLocation location, List<int> data,
      {@Default(false) bool cached}) = AppDocumentFile;

  factory AppDocumentEntity.fileFromMap(
          AssetLocation location, Map<String, dynamic> map,
          {bool cached = false}) =>
      AppDocumentFile(
          location, Uint8List.fromList(utf8.encode(json.encode(map))),
          cached: cached);

  const factory AppDocumentEntity.directory(
          AssetLocation location, List<AppDocumentEntity> assets) =
      AppDocumentDirectory;

  String get fileName => location.path.split('/').last;

  String get fileExtension =>
      fileName.contains('.') ? fileName.split('.').last : '';

  String get fileNameWithoutExtension => fileName.substring(0,
      fileName.contains('.') ? fileName.lastIndexOf('.') : fileName.length - 1);

  String get pathWithLeadingSlash => location.pathWithLeadingSlash;

  String get pathWithoutLeadingSlash => location.pathWithoutLeadingSlash;

  String get parent => pathWithLeadingSlash
      .split('/')
      .sublist(0, pathWithLeadingSlash.split('/').length - 1)
      .join('/');
}

extension EntityFileTypeExtension on AppDocumentEntity {
  AssetFileType? get fileType => location.fileType;
}

extension AppDocumentInfoExtension on AppDocumentFile {
  DocumentInfo? getDocumentInfo() {
    try {
      if (fileType == AssetFileType.note) {
        return DocumentInfo(
            fileNameWithoutExtension, jsonDecode(utf8.decode(data)));
      }
    } catch (_) {}

    return null;
  }
}

@freezed
class DocumentInfo with _$DocumentInfo {
  const DocumentInfo._();

  const factory DocumentInfo(String fileName, Map<String, dynamic> data) =
      _DocumentInfo;

  int get fileVersion => data['fileVersion'] ?? -1;

  String get name => data['name'] ?? fileName;

  String get description => data['description'] ?? '';

  DateTime? get updatedAt => data['updatedAt'] is! int
      ? null
      : DateTime.fromMillisecondsSinceEpoch(data['updatedAt']);

  DateTime? get createdAt => data['createdAt'] is! int
      ? null
      : DateTime.fromMillisecondsSinceEpoch(data['createdAt']);

  AppDocument load() => AppDocument.fromJson(data);

  String get dataAsString => jsonEncode(json);
}
