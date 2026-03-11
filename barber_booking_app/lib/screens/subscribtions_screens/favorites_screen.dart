import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/master_subscription_providers/get_subscriptions_provider.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';
import 'package:barber_booking_app/widgets/master_widgets/master_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int _selectedNavIndex = 3;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;
    await Provider.of<GetSubscriptionsProvider>(context, listen: false)
        .getSubscriptions(token);
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedNavIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/search');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/appointments_screen');
        break;
      case 3:
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GetSubscriptionsProvider>(
      builder: (context, provider, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (provider.errorMessage != null && mounted) {
            provider.showApiError(context, provider.errorMessage);
          }
        });

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Избранные мастера'),
          ),
          body: _buildBody(provider),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedNavIndex,
            onTap: _onNavItemTapped,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Поиск'),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Записи'),
              BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Избранное'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(GetSubscriptionsProvider provider) {
    if (provider.isLoading && provider.list == null) {
      return const Center(child: LoadingIndicator(message: 'Загрузка избранного...'));
    }

    if (provider.errorMessage != null && provider.list == null) {
      return Center(
        child: ErrorWidgetCustom(
          message: provider.errorMessage!,
          onRetry: _loadFavorites,
        ),
      );
    }

    if (provider.list == null || provider.list!.isEmpty) {
      return const Center(
        child: Text(
          'У вас пока нет избранных мастеров',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    final subscriptions = provider.list!;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: subscriptions.length,
      itemBuilder: (context, index) {
        final sub = subscriptions[index];
        final masterNav = sub.masterNavigation;
        if (masterNav == null) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: MasterCard(
            name: masterNav.MasterName ?? 'Без имени',
            specialty: 'Мастер',
            rating: masterNav.Rating ?? 0.0,
            ratingCount: null,
            imageUrl: masterNav.AvatarUrl,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/master_detail',
                arguments: masterNav.Id,
              );
            },
          ),
        );
      },
    );
  }
}