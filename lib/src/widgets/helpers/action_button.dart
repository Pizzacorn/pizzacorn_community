import 'package:pizzacorn_community/pizzacorn_community.dart';

class CommunityActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  CommunityActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(RADIUS),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color ?? COLOR_SUBTEXT),
            Space(SPACE_SMALLEST),
            TextBody(label, color: color ?? COLOR_SUBTEXT),
          ],
        ),
      ),
    );
  }
}
