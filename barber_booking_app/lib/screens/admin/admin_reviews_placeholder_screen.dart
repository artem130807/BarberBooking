import 'package:flutter/material.dart';

class AdminReviewsPlaceholderScreen extends StatelessWidget {
  const AdminReviewsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Отзывы'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Модерация отзывов: фильтры по салону, мастеру, рейтингу и дате. Подключим к админ API.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}
