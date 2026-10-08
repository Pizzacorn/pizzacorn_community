import 'package:pizzacorn_community/pizzacorn_community.dart';
import 'dart:ui' as ui;

class CommunityUploadedMedia {
  final List<String> media;
  final List<String> mediaThumbnails;

  CommunityUploadedMedia({required this.media, required this.mediaThumbnails});
}

class CommunityMediaService {
  final ImagePicker picker = ImagePicker();

  Future<List<XFile>> pickImages() async {
    try {
      return await picker.pickMultiImage(
        maxWidth: 2400,
        maxHeight: 2400,
        imageQuality: 90,
      );
    } catch (error) {
      return [];
    }
  }

  Future<List<String>> uploadImages({
    required List<XFile> images,
    required String folder,
  }) async {
    final CommunityUploadedMedia uploadedMedia = await uploadImageVariants(
      images: images,
      folder: folder,
    );
    return uploadedMedia.media;
  }

  Future<CommunityUploadedMedia> uploadImageVariants({
    required List<XFile> images,
    required String folder,
  }) async {
    final List<String> urls = [];
    final List<String> thumbnailUrls = [];
    final String userId = PizzacornCommunityConfig.currentUser.id;

    for (int i = 0; i < images.length; i++) {
      final File file = File(images[i].path);
      final String fileName = '${DateTime.now().microsecondsSinceEpoch}_$i';
      final Reference reference = FirebaseStorage.instance
          .ref()
          .child(folder)
          .child(userId)
          .child('$fileName.jpg');
      await reference.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
      urls.add(await reference.getDownloadURL());

      final ui.Codec codec = await ui.instantiateImageCodec(
        await images[i].readAsBytes(),
        targetWidth: 320,
      );
      final ui.FrameInfo frame = await codec.getNextFrame();
      final thumbnailData = await frame.image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      frame.image.dispose();
      codec.dispose();
      if (thumbnailData == null) {
        throw StateError('No se pudo generar la miniatura de la imagen.');
      }
      final Reference thumbnailReference = FirebaseStorage.instance
          .ref()
          .child(folder)
          .child(userId)
          .child('${fileName}_thumbnail.png');
      await thumbnailReference.putData(
        thumbnailData.buffer.asUint8List(),
        SettableMetadata(contentType: 'image/png'),
      );
      thumbnailUrls.add(await thumbnailReference.getDownloadURL());
    }
    return CommunityUploadedMedia(media: urls, mediaThumbnails: thumbnailUrls);
  }
}

final communityMediaServiceProvider = Provider(
  (ref) => CommunityMediaService(),
);
