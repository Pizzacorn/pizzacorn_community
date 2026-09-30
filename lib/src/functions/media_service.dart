import 'package:pizzacorn_community/pizzacorn_community.dart';

class CommunityMediaService {
  final ImagePicker picker = ImagePicker();

  Future<List<XFile>> pickImages() async {
    try {
      return await picker.pickMultiImage(
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 78,
      );
    } catch (error) {
      return [];
    }
  }

  Future<List<String>> uploadImages({
    required List<XFile> images,
    required String folder,
  }) async {
    final List<String> urls = [];
    final String userId = PizzacornCommunityConfig.currentUser.id;

    for (int i = 0; i < images.length; i++) {
      final File file = File(images[i].path);
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
      final Reference reference = FirebaseStorage.instance
          .ref()
          .child(folder)
          .child(userId)
          .child(fileName);
      await reference.putFile(file);
      urls.add(await reference.getDownloadURL());
    }
    return urls;
  }
}

final communityMediaServiceProvider = Provider(
  (ref) => CommunityMediaService(),
);
