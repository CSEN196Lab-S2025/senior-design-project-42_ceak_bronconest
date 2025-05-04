import 'package:flutter/material.dart';
import 'package:bronconest_app/models/dorm.dart';

class AdminCard extends StatefulWidget {
  final Dorm dorm;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AdminCard({
    super.key,
    required this.dorm,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<AdminCard> createState() => _AdminCardState();
}

class _AdminCardState extends State<AdminCard> {
  bool showFullContent = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4.0,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.inversePrimary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.dorm.name,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    widget.dorm.shortDescription,
                    maxLines: showFullContent ? null : 3,
                    overflow:
                        showFullContent
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                  ),
                  if (widget.dorm.shortDescription.length > 50)
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
            ),
            // Footer Section
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: widget.onEdit,
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    onPressed: widget.onDelete,
                    icon: const Icon(Icons.delete),
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
