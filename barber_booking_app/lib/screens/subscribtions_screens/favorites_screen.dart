import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/master_subscription_providers/get_subscriptions_provider.dart';
import 'package:barber_booking_app/providers/master_subscription_providers/delete_subscription_provider.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';
import 'package:barber_booking_app/models/master_models/response/get_masterProfile_subscription_Info_response.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int _selectedNavIndex = 3;
  final Set<String> _markedForDeletionIds = {};

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

  Future<void> _applyDeletions() async {
    if (_markedForDeletionIds.isEmpty) return;
    final deleteProvider = Provider.of<DeleteSubscriptionProvider>(context, listen: false);
    for (final id in _markedForDeletionIds) {
      await deleteProvider.deleteSubscription(id);
    }
    _markedForDeletionIds.clear();
    await _loadFavorites();
  }

  void _onNavItemTapped(int index) async {
    await _applyDeletions();
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
            actions: [
              if (_markedForDeletionIds.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () async {
                    await _applyDeletions();
                  },
                ),
            ],
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
        return FavoriteMasterCard(
          subscriptionId: sub.id!,
          masterInfo: masterNav,
          isMarkedForDeletion: _markedForDeletionIds.contains(sub.id),
          onToggleMarked: (marked) {
            setState(() {
              if (marked) {
                _markedForDeletionIds.add(sub.id!);
              } else {
                _markedForDeletionIds.remove(sub.id!);
              }
            });
          },
        );
      },
    );
  }
}

class FavoriteMasterCard extends StatelessWidget {
  final String subscriptionId;
  final GetMasterprofileSubscriptionInfoResponse masterInfo;
  final bool isMarkedForDeletion;
  final ValueChanged<bool> onToggleMarked;

  const FavoriteMasterCard({
    super.key,
    required this.subscriptionId,
    required this.masterInfo,
    required this.isMarkedForDeletion,
    required this.onToggleMarked,
  });

  @override
  Widget build(BuildContext context) {
    final master = masterInfo;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: master.AvatarUrl != null
                  ? NetworkImage(master.AvatarUrl!)
                  : null,
              child: master.AvatarUrl == null
                  ? const Icon(Icons.person, size: 30, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/master_detail',
                        arguments: master.Id,
                      );
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        master.MasterName ?? 'Мастер',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        (master.Rating ?? 0).toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (master.SalonNavigation != null)
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/salon_screen',
                          arguments: master.SalonNavigation!.Id,
                        );
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          master.SalonNavigation!.SalonName ?? 'Салон',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                isMarkedForDeletion ? Icons.favorite_border : Icons.favorite,
                color: isMarkedForDeletion ? Colors.grey : Colors.red,
              ),
              onPressed: () => onToggleMarked(!isMarkedForDeletion),
            ),
          ],
        ),
      ),
    );
  }
}