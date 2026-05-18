import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';

Future<XFile?> compressImageFile(File file,
    {int quality = 80, int maxWidth = 1280, int maxHeight = 1280}) async {
  final targetPath =
      path.join(file.parent.path, "compressed_${path.basename(file.path)}");

  final result = await FlutterImageCompress.compressAndGetFile(
    file.path,
    targetPath,
    quality: quality, // 0-100, higher is better
    minWidth: maxWidth, // maximum width
    minHeight: maxHeight, // maximum height
    keepExif: true, // preserve EXIF info
  );

  if (result != null) {
    return XFile(result.path); // wrap File as XFile
  }

  return null; // return null if compression failed
}
