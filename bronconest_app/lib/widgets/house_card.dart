import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bronconest_app/models/house.dart';
import 'package:bronconest_app/styles.dart';
import 'package:bronconest_app/widgets/image_gradient_overlay.dart';

class HouseCard extends StatefulWidget {
  final House house;
  bool isSaved;
  final Function toggleSavedPlace;

  HouseCard({
    super.key,
    required this.house,
    required this.isSaved,
    required this.toggleSavedPlace,
  });

  @override
  State<HouseCard> createState() => _HouseCardState();
}

class _HouseCardState extends State<HouseCard> {
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not launch URL')));
      }
    }
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(100, 0, 0, 0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(3.5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            Text(
              ' $label',
              style: Styles.smallTextStyle.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _launchURL(widget.house.listing);
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
                  imageUrl: widget.house.image,
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
                          widget.house.address,
                          style: Styles.largeTextStyle.copyWith(
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ),
                      Spacer(),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        verticalDirection: VerticalDirection.up,
                        children: [
                          _buildInfoChip(
                            icon: Icons.bed,
                            label: '${widget.house.bedrooms} BR',
                          ),
                          if (widget.house.bathrooms != null)
                            _buildInfoChip(
                              icon: Icons.bathtub,
                              label: '${widget.house.bathrooms} BA',
                            ),
                          if (widget.house.sqft != null)
                            _buildInfoChip(
                              icon: Icons.square_foot,
                              label: '${widget.house.sqft} sqft',
                            ),
                          _buildInfoChip(
                            icon: Icons.attach_money,
                            label: widget.house.price,
                          ),
                          _buildInfoChip(
                            icon: Icons.home,
                            label: widget.house.type,
                          ),
                          if (widget.house.distanceFromSchool != null)
                            _buildInfoChip(
                              icon: Icons.location_on,
                              label:
                                  '${widget.house.distanceFromSchool?.toStringAsFixed(2)} mi',
                            ),
                        ],
                      ),
                    ],
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
                      widget.toggleSavedPlace(widget.house);

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
