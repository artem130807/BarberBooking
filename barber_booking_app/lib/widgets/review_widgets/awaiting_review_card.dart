import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:barber_booking_app/models/appointment_models/response/get_appointment_awaiting_review_response.dart';

class AwaitingReviewCard extends StatelessWidget {
  final GetAppointmentAwaitingReviewResponse item;
  final VoidCallback? onLeaveReview;

  const AwaitingReviewCard({
    super.key,
    required this.item,
    this.onLeaveReview,
  });

  @override
  Widget build(BuildContext context) {
    final salon = item.salonNavigationResponse;
    final master = item.masterNavigationResponse;
    final service = item.serviceNavigationResponse;
    final dateStr = _formatDate(item.AppointmentDate);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.event_available,
                    color: Colors.amber.shade700,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (salon?.SalonName != null) ...[
                        _buildLinkChip(
                          context: context,
                          icon: Icons.store_outlined,
                          label: salon!.SalonName!,
                          onTap: salon.Id != null
                              ? () => Navigator.pushNamed(
                                    context,
                                    '/salon_screen',
                                    arguments: salon.Id,
                                  )
                              : null,
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (master != null && master.MasterName != null) ...[
                        _buildLinkChip(
                          context: context,
                          icon: Icons.person_outline,
                          label: master.MasterName!,
                          onTap: master.Id != null
                              ? () => Navigator.pushNamed(
                                    context,
                                    '/master_detail',
                                    arguments: master.Id!,
                                  )
                              : null,
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (service?.Name != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.content_cut,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                service!.Name!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            if (service.Price?.Value != null)
                              Text(
                                '${service.Price!.Value!.toStringAsFixed(0)} ₽',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ],
                      if (dateStr.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              dateStr,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onLeaveReview,
                icon: const Icon(Icons.rate_review_outlined, size: 20),
                label: const Text('Оставить отзыв'),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildLinkChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    final isTappable = onTap != null;
    return Material(
      color: isTappable ? Colors.grey.shade100 : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isTappable ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isTappable ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isTappable) ...[
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey.shade600),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    DateTime dt;
    if (date is DateTime) {
      dt = date;
    } else if (date is String) {
      try {
        dt = DateTime.parse(date);
      } catch (_) {
        return date;
      }
    } else {
      return '';
    }
    return DateFormat('dd.MM.yyyy, HH:mm').format(dt);
  }
}
