import 'package:pizzacorn_community/pizzacorn_community.dart';

Widget buildCommunityImageGrid(
  BuildContext context, {
  required List<String> media,
}) {
  if (media.isEmpty) return SizedBox.shrink();
  final int count = media.length > 4 ? 4 : media.length;

  return ClipRRect(
    borderRadius: BorderRadius.circular(RADIUS),
    child: SizedBox(
      height: 150,
      width: double.infinity,
      child: buildCommunityImageGridStructure(
        context,
        media: media,
        count: count,
      ),
    ),
  );
}

Widget buildCommunityImageGridStructure(
  BuildContext context, {
  required List<String> media,
  required int count,
}) {
  if (count == 1) return buildCommunityImage(context, url: media[0]);
  if (count == 2) {
    return Row(
      children: [
        Expanded(child: buildCommunityImage(context, url: media[0])),
        VerticalDivider(width: 2, color: Colors.transparent),
        Expanded(child: buildCommunityImage(context, url: media[1])),
      ],
    );
  }
  if (count == 3) {
    return Row(
      children: [
        Expanded(child: buildCommunityImage(context, url: media[0])),
        VerticalDivider(width: 2, color: Colors.transparent),
        Expanded(
          child: Column(
            children: [
              Expanded(child: buildCommunityImage(context, url: media[1])),
              Divider(height: 2, color: Colors.transparent),
              Expanded(child: buildCommunityImage(context, url: media[2])),
            ],
          ),
        ),
      ],
    );
  }
  return Column(
    children: [
      Expanded(
        child: Row(
          children: [
            Expanded(child: buildCommunityImage(context, url: media[0])),
            VerticalDivider(width: 2, color: Colors.transparent),
            Expanded(child: buildCommunityImage(context, url: media[1])),
          ],
        ),
      ),
      Divider(height: 2, color: Colors.transparent),
      Expanded(
        child: Row(
          children: [
            Expanded(child: buildCommunityImage(context, url: media[2])),
            VerticalDivider(width: 2, color: Colors.transparent),
            Expanded(child: buildCommunityImage(context, url: media[3])),
          ],
        ),
      ),
    ],
  );
}

Widget buildCommunityImage(BuildContext context, {required String url}) {
  return InkWell(
    onTap: () => goTo(context, FullScreenImagePage(url)),
    child: ImageCustom(
      imageUrl: url,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
    ),
  );
}
