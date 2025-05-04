import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bronconest_app/pages/dorm_reviews_page.dart';
import 'package:bronconest_app/models/dorm.dart';
import 'package:bronconest_app/styles.dart';

class PlaceCard extends StatefulWidget {
  PlaceCard({
    super.key,
    required this.dorm,
    required this.isSaved,
    required this.toggleSavedPlace,
  });

  Dorm dorm;
  bool isSaved;
  Function toggleSavedPlace;

  @override
  State<PlaceCard> createState() => _PlaceCardState();
}

class RatingScore {
  String name;
  double score;
  late String scoreString;
  IconData icon;

  RatingScore({required this.name, required this.score, required this.icon}) {
    scoreString = score.toStringAsFixed(1);
  }
}

class _PlaceCardState extends State<PlaceCard> {
  late List<RatingScore> ratingScores = [];

  @override
  void initState() {
    super.initState();

    ratingScores = [
      RatingScore(
        name: 'walkability',
        score: widget.dorm.walkabilityAvg,
        icon: Icons.directions_walk,
      ),
      RatingScore(
        name: 'cleaniness',
        score: widget.dorm.cleanlinessAvg,
        icon: Icons.shower,
      ),
      RatingScore(
        name: 'quietness',
        score: widget.dorm.quietnessAvg,
        icon: Icons.music_off,
      ),
      RatingScore(
        name: 'comfort',
        score: widget.dorm.comfortAvg,
        icon: Icons.fireplace,
      ),
      RatingScore(
        name: 'safety',
        score: widget.dorm.safetyAvg,
        icon: Icons.lock,
      ),
      RatingScore(
        name: 'amenities',
        score: widget.dorm.amenitiesAvg,
        icon: Icons.local_cafe,
      ),
      RatingScore(
        name: 'community',
        score: widget.dorm.communityAvg,
        icon: Icons.groups,
      ),
    ];

    // sort by descending order
    ratingScores.sort((a, b) => b.score.compareTo(a.score));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DormReviewsPage(dorm: widget.dorm),
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
                      (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                        colors: [
                          Color.fromARGB(75, 0, 0, 0),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Expanded(
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          spacing: 10.0,
                          children:
                              ratingScores
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
                ),
                Align(
                  alignment: Alignment.topRight,
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
