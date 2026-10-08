import 'package:pizzacorn_community/pizzacorn_community.dart';

Widget buildCommunityImageGrid(
  BuildContext context, {
  required List<String> media,
  List<String> mediaThumbnails = const [],
}) {
  if (media.isEmpty) return SizedBox.shrink();
  final int count = media.length > 4 ? 4 : media.length;

  Widget imageAt(int index) => InkWell(
    onTap: () => goTo(context, CommunityImageGalleryPage(media: media, initialIndex: index)),
    child: ImageCustom(
      imageUrl: index < mediaThumbnails.length && mediaThumbnails[index].isNotEmpty
          ? mediaThumbnails[index]
          : media[index],
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
    ),
  );

  Widget gap() => SizedBox(width: 2, height: 2);

  return ClipRRect(
    borderRadius: BorderRadius.circular(RADIUS),
    child: SizedBox(
      height: 150,
      width: double.infinity,
      child: count == 1
          ? imageAt(0)
          : count == 2
          ? Row(children: [Expanded(child: imageAt(0)), gap(), Expanded(child: imageAt(1))])
          : count == 3
          ? Row(children: [
              Expanded(child: imageAt(0)), gap(),
              Expanded(child: Column(children: [
                Expanded(child: imageAt(1)), gap(), Expanded(child: imageAt(2)),
              ])),
            ])
          : Column(children: [
              Expanded(child: Row(children: [
                Expanded(child: imageAt(0)), gap(), Expanded(child: imageAt(1)),
              ])),
              gap(),
              Expanded(child: Row(children: [
                Expanded(child: imageAt(2)), gap(), Expanded(child: imageAt(3)),
              ])),
            ]),
    ),
  );
}

Widget buildCommunityImageGridStructure(
  BuildContext context, {
  required List<String> media,
  required int count,
}) {
  return buildCommunityImageGrid(
    context,
    media: media.take(count).toList(),
  );
}

Widget buildCommunityImage(BuildContext context, {required String url}) {
  return InkWell(
    onTap: () => goTo(context, CommunityImageGalleryPage(media: [url])),
    child: ImageCustom(
      imageUrl: url,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
    ),
  );
}
