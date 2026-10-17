import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class CapturedImage extends Equatable {
  const CapturedImage({
    required this.path,
    required this.bytes,
    required this.mimeType,
  });

  final String path;
  final Uint8List bytes;
  final String mimeType;

  @override
  List<Object?> get props => [path, mimeType, bytes.length];
}

enum CaptureSource { camera, gallery }
