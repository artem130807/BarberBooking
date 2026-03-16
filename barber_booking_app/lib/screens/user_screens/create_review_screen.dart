import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:barber_booking_app/models/appointment_models/response/get_appointment_awaiting_review_response.dart';
import 'package:barber_booking_app/models/review_models/request/create_review_request.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/review_providers/create_review_user_provider.dart';
import 'package:barber_booking_app/widgets/review_widgets/star_rating_input.dart';

class CreateReviewScreen extends StatefulWidget {
  final GetAppointmentAwaitingReviewResponse appointment;

  const CreateReviewScreen({super.key, required this.appointment});

  @override
  State<CreateReviewScreen> createState() => _CreateReviewScreenState();
}

class _CreateReviewScreenState extends State<CreateReviewScreen> {
  int _salonRating = 5;
  int _masterRating = 5;
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Необходима авторизация'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final request = CreateReviewRequest(
      AppointmentId: widget.appointment.id,
      SalonId: widget.appointment.salonNavigationResponse?.Id,
      MasterProfileId: widget.appointment.masterNavigationResponse?.Id,
      SalonRating: _salonRating,
      MasterRating: _masterRating,
      Comment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
    );
    final created = await Provider.of<CreateReviewUserProvider>(context, listen: false)
        .createReview(request, token);
    if (!mounted) return;
    if (created) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Отзыв добавлен'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } else {
      Provider.of<CreateReviewUserProvider>(context, listen: false).showApiError(
        context,
        Provider.of<CreateReviewUserProvider>(context, listen: false).errorMessage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateReviewUserProvider>(
      builder: (context, provider, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (provider.errorMessage != null && mounted) {
            provider.showApiError(context, provider.errorMessage);
          }
        });

        final salonName = widget.appointment.salonNavigationResponse?.SalonName ?? 'Салон';
        final masterName = widget.appointment.masterNavigationResponse?.MasterName ?? 'Мастер';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Оставить отзыв'),
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
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          salonName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (masterName.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Мастер: $masterName',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
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
                    color: Theme.of(context).colorScheme.onSurface,
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
                    fillColor: Colors.grey.shade50,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: provider.isLoading ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: provider.isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Отправить отзыв'),
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
