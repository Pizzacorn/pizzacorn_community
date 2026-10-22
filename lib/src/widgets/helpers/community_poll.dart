import 'package:pizzacorn_community/pizzacorn_community.dart';

class CommunityPoll extends StatefulWidget {
  final CommunityModel communityModel;

  CommunityPoll({super.key, required this.communityModel});

  @override
  State<CommunityPoll> createState() => CommunityPollState();
}

class CommunityPollState extends State<CommunityPoll> {
  bool isSaving = false;
  String error = '';

  @override
  Widget build(BuildContext context) {
    final repository = CommunityRepository();
    final postId = widget.communityModel.id;
    final userId = PizzacornCommunityConfig.currentUser.id;
    if (postId.isEmpty) return SizedBox.shrink();
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: repository.database.collection(CommunityRepository.collectionName)
          .doc(postId).snapshots(),
      builder: (context, postSnapshot) {
        final data = postSnapshot.data?.data();
        final options = data?['pollOptions'] is List
            ? List<String>.from(data!['pollOptions'])
            : widget.communityModel.pollOptions;
        final counts = data?['pollCounts'] is List
            ? List<int>.from(data!['pollCounts'])
            : widget.communityModel.pollCounts;
        if (options.isEmpty) return SizedBox.shrink();
        int total = 0;
        for (int i = 0; i < counts.length; i++) {
          total += counts[i];
        }
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: userId.isEmpty ? null : repository.database
              .collection(CommunityRepository.collectionName).doc(postId)
              .collection(CommunityRepository.subcollectionVotes).doc(userId)
              .snapshots(),
          builder: (context, voteSnapshot) {
            final selected = voteSnapshot.data?.data()?['optionIndex'];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: options.length,
                  itemBuilder: (context, i) => Padding(
                    padding: EdgeInsets.only(bottom: SPACE_SMALLEST),
                    child: InkWell(
                      onTap: isSaving || userId.isEmpty ? null : () async {
                        setState(() { isSaving = true; error = ''; });
                        try {
                          await repository.vote(postId: postId, optionIndex: i);
                        } catch (exception) {
                          if (mounted) setState(() => error = exception.toString());
                        } finally {
                          if (mounted) setState(() => isSaving = false);
                        }
                      },
                      child: Stack(children: [
                        Container(
                          height: 42,
                          decoration: BoxDecoration(
                            color: COLOR_BACKGROUND_SECONDARY,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: selected == i ? COLOR_ACCENT : COLOR_BORDER),
                          ),
                        ),
                        Positioned.fill(child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: total == 0 || i >= counts.length ? 0 : counts[i] / total,
                          child: DecoratedBox(decoration: BoxDecoration(
                            color: COLOR_ACCENT.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(8),
                          )),
                        )),
                        Positioned.fill(child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: SPACE_SMALL),
                          child: Row(children: [
                            Expanded(child: TextBody(options[i])),
                            TextCaption('${total == 0 || i >= counts.length ? 0 : (counts[i] * 100 / total).round()}%'),
                          ]),
                        )),
                      ]),
                    ),
                  ),
                ),
                TextCaption('$total votos'),
                if (error.isNotEmpty) TextCaption(error, color: COLOR_ERROR),
              ],
            );
          },
        );
      },
    );
  }
}
