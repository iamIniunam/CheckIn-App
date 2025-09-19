import 'package:attendance_app/platform/utils/location_service.dart';
import 'package:flutter/material.dart';

class LocationVerifiedBadge extends StatelessWidget {
  const LocationVerifiedBadge({super.key, required this.distance});

  final double distance;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green.shade600,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'Location verified: ${LocationService.formatDistance(distance)}',
            style: TextStyle(
              color: Colors.green.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
