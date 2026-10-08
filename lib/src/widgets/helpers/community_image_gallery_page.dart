import 'package:pizzacorn_community/pizzacorn_community.dart';

class CommunityImageGalleryPage extends StatefulWidget {
  final List<String> media;
  final int initialIndex;

  CommunityImageGalleryPage({super.key, required this.media, this.initialIndex = 0});

  @override
  State<CommunityImageGalleryPage> createState() => CommunityImageGalleryPageState();
}

class CommunityImageGalleryPageState extends State<CommunityImageGalleryPage> {
  late final PageController pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    pageController = PageController(initialPage: currentIndex);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLOR_BACKGROUND,
      appBar: AppBarBack(context: context, title: '${currentIndex + 1} / ${widget.media.length}'),
      body: PageView.builder(
        controller: pageController,
        itemCount: widget.media.length,
        onPageChanged: (index) => setState(() => currentIndex = index),
        itemBuilder: (context, index) => InteractiveViewer(
          minScale: 1,
          maxScale: 5,
          child: Center(
            child: Image.network(
              widget.media[index],
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.broken_image, color: COLOR_SUBTEXT, size: 50),
            ),
          ),
        ),
      ),
    );
  }
}
