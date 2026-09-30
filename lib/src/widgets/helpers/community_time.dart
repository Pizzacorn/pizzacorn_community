import 'package:pizzacorn_community/pizzacorn_community.dart';

String formatCommunityTimeAgo(DateTime createdAt) {
  final Duration difference = DateTime.now().difference(createdAt);
  if (difference.inMinutes < 1) {
    return 'Ahora';
  }
  if (difference.inHours < 1) {
    return '${difference.inMinutes}m';
  }
  if (difference.inDays < 1) {
    return '${difference.inHours}h';
  }
  if (difference.inDays < 7) {
    return DateFormat('EEE', 'es_ES').format(createdAt);
  }
  return DateFormat('d MMM', 'es_ES').format(createdAt);
}
