import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:barber_booking_app/models/review_models/request/update_review_request.dart';
import 'package:barber_booking_app/models/review_models/response/get_reviews_user_response.dart';
import 'package:barber_booking_app/providers/review_providers/update_review_user_provider.dart';
import 'package:barber_booking_app/widgets/review_widgets/star_rating_input.dart';

class EditReviewScreen extends StatefulWidget {
  final GetReviewsUserResponse review;

  const EditReviewScreen({super.key, required this.review});

  @override
  State<EditReviewScreen> createState() => _EditReviewScreenState();
}

class _EditReviewScreenState extends State<EditReviewScreen> {
  late int _salonRating;
  late int _masterRating;
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _salonRating = widget.review.SalonRating ?? 5;
    _masterRating = widget.review.MasterRating ?? 5;
    _salonRating = _salonRating.clamp(1, 5);
    _masterRating = _masterRating.clamp(1, 5);
    _commentController = TextEditingController(text: widget.review.Comment ?? '');
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final request = UpdateReviewRequest(
      salonRating: _salonRating,
      masterRating: _masterRating,
      comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
    );
    final updated = await Provider.of<UpdateReviewUserProvider>(context, listen: false)
        .updateReview(widget.review.Id, request);
    if (!mounted) return;
    if (updated == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Отзыв обновлён'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } else {
      Provider.of<UpdateReviewUserProvider>(context, listen: false)
          .showApiError(context, Provider.of<UpdateReviewUserProvider>(context, listen: false).errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UpdateReviewUserProvider>(
      builder: (context, provider, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (provider.errorMessage != null && mounted) {
            provider.showApiError(context, provider.errorMessage);
          }
        });

        final cs = Theme.of(context).colorScheme;
        final salonName = widget.review.dtoSalonNavigation?.SalonName ?? 'Салон';
        final masterName = widget.review.masterProfileNavigation?.MasterName ?? 'Мастер';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Редактировать отзыв'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: cs.outline.withOpacity(0.3)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          salonName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                        if (masterName.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Мастер: $masterName',
                            style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                StarRatingInput(
                  label: 'Оценка салона',
                  value: _salonRating,
                  onChanged: (v) => setState(() => _salonRating = v),
                ),
                const SizedBox(height: 24),
                StarRatingInput(
                  label: 'Оценка мастера',
                  value: _masterRating,
                  onChanged: (v) => setState(() => _masterRating = v),
                ),
                const SizedBox(height: 24),
                Text(
                  'Комментарий',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _commentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Напишите ваш отзыв...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: cs.surfaceContainerHighest,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: provider.isLoading ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: provider.isLoading
                        ? const Text('Сохранение...')
                        : const Text('Сохранить'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
