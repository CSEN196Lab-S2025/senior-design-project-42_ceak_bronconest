import 'package:bronconest_app/widgets/image_gradient_overlay.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bronconest_app/pages/dorm_reviews_page.dart';
import 'package:bronconest_app/pages/chat_page.dart';
import 'package:bronconest_app/models/dorm.dart';
import 'package:bronconest_app/styles.dart';
import 'package:bronconest_app/globals.dart';

class PlaceCard extends StatefulWidget {
  PlaceCard({
    super.key,
    required this.dorm,
    required this.isSaved,
    required this.toggleSavedPlace,
    this.showScoreRow = true,
    this.schoolId,
  });

  Dorm dorm;
  bool isSaved;
  Function toggleSavedPlace;
  bool showScoreRow;
  String? schoolId;

  @override
  State<PlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends State<PlaceCard> {
  @override
  void initState() {
    super.initState();
    widget.dorm.schoolId = widget.schoolId ?? school;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => DormReviewsPage(
                  dorm: widget.dorm,
                  schoolId: widget.schoolId,
                ),
          ),
        );
      },
      child: Card(
        elevation: 5.0,
        margin: EdgeInsets.all(8.0),
        clipBehavior: Clip.antiAlias,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: SizedBox(
            height: 200,
            width: double.infinity,
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: widget.dorm.coverImage,
                  fit: BoxFit.cover,
                  width: 2000, // lol this makes the cover fit the width
                  placeholder:
                      (context, url) => Center(
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                ImageGradientOverlay(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 40.0),
                        child: Text(
                          widget.dorm.name,
                          style: Styles.largeTextStyle.copyWith(
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ),
                      Spacer(),
                      if (widget.showScoreRow)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          spacing: 8.0,
                          children:
                              widget.dorm.ratingScores
                                  .sublist(0, 3)
                                  .map(
                                    (e) => Container(
                                      decoration: BoxDecoration(
                                        color: Color.fromARGB(100, 0, 0, 0),
                                        borderRadius: BorderRadius.circular(
                                          10.0,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(3.5),
                                        child: Row(
                                          children: [
                                            Icon(e.icon, color: Colors.white),
                                            Text(
                                              ' ${e.scoreString}',
                                              style: Styles.smallTextStyle
                                                  .copyWith(
                                                    color: Colors.white,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                    ],
                  ),
                ),
                if (widget.schoolId != null)
                  Align(
                    alignment: Alignment.topRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chat, color: Colors.white),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => ChatPage(
                                      schoolId: widget.schoolId!,
                                      dorm: widget.dorm,
                                    ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                      widget.isSaved ? Icons.favorite : Icons.favorite_border,
                      color: Colors.white,
                      size: 30.0,
                    ),

                    onPressed: () {
                      widget.toggleSavedPlace(widget.dorm);

                      widget.isSaved = !widget.isSaved;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
