import 'package:pizzacorn_community/pizzacorn_community.dart';

class CommunitySelectedImages extends StatelessWidget {
  final List<XFile> images;
  final void Function({required int index}) onRemoveImage;
  final double height;
  final double width;

  CommunitySelectedImages({
    super.key,
    required this.images,
    required this.onRemoveImage,
    this.height = 180,
    this.width = 220,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return SizedBox.shrink();

    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: SPACE_SMALL),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(RADIUS),
                  child: Image.file(
                    File(images[index].path),
                    width: width,
                    height: height,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: ButtonCustomIcon(
                    icon: Icons.close_rounded,
                    size: 16,
                    padding: 6,
                    color: Colors.white,
                    colorBackground: Colors.black.withValues(alpha: 0.45),
                    onPressed: () {
                      onRemoveImage(index: index);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
