import 'package:flutter/material.dart';
import 'package:bronconest_app/models/review.dart';

class ReviewTile extends StatefulWidget {
  final Review review;

  const ReviewTile({super.key, required this.review});

  @override
  State<ReviewTile> createState() => _ReviewTileState();
}

class _ReviewTileState extends State<ReviewTile> {
  bool showFullContent = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ExpansionTile(
        title: Text(
          'User: ${widget.review.userId == "" ? 'Anonymous' : widget.review.userId}',
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.review.content,
              maxLines: showFullContent ? null : 3,
              overflow:
                  showFullContent
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
            ),
            if (widget.review.content.length > 100)
              GestureDetector(
                onTap: () {
                  setState(() {
                    showFullContent = !showFullContent;
                  });
                },
                child: Text(
                  showFullContent ? 'Show less' : 'Show more...',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Walkability: ${widget.review.walkability}'),
            Text('Cleanliness: ${widget.review.cleanliness}'),
            Text('Quietness: ${widget.review.quietness}'),
            Text('Comfort: ${widget.review.comfort}'),
            Text('Safety: ${widget.review.safety}'),
            Text('Amenities: ${widget.review.amenities}'),
            Text('Community: ${widget.review.community}'),
          ],
        ),
      ),
    );
  }
}
