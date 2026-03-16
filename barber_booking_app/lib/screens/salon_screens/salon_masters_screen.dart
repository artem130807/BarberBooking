import 'package:barber_booking_app/models/params/master_params/master_filter.dart';
import 'package:barber_booking_app/providers/master_providers/get_masters_provider.dart';
import 'package:barber_booking_app/screens/service_screens/service_selection_screen.dart';
import 'package:barber_booking_app/widgets/booking_button.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:barber_booking_app/widgets/master_widgets/master_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum MasterSort { none, rating, popular }

class SalonMastersScreen extends StatefulWidget {
  final String salonId;

  const SalonMastersScreen({super.key, required this.salonId});

  @override
  State<SalonMastersScreen> createState() => _SalonMastersScreenState();
}

class _SalonMastersScreenState extends State<SalonMastersScreen> {
  MasterSort _selectedSort = MasterSort.none;
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadMasters();
  }

  void _onNavItemTapped(int index) {
    setState(() => _selectedNavIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/search_screen');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/appointments_screen');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/favorites_screen');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  void _loadMasters() {
    final filter = MasterFilter(
      MaxRating: _selectedSort == MasterSort.rating,
      Popular: _selectedSort == MasterSort.popular,
    );
    Provider.of<GetMastersProvider>(context, listen: false)
        .loadMasters(widget.salonId, filter);
  }

  void _applySort(MasterSort sort) {
    if (_selectedSort == sort) {
      _selectedSort = MasterSort.none;
    } else {
      _selectedSort = sort;
    }
    _loadMasters();
  }

  void _clearFilters() {
    setState(() {
      _selectedSort = MasterSort.none;
    });
    _loadMasters();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GetMastersProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Выбор мастера'),
            actions: [
              if (_selectedSort != MasterSort.none)
                IconButton(
                  icon: const Icon(Icons.clear_all),
                  onPressed: _clearFilters,
                ),
            ],
          ),
          body: Column(
            children: [
              // Панель фильтров
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('С высокой оценкой'),
                      selected: _selectedSort == MasterSort.rating,
                      onSelected: (_) => setState(() {
                        _applySort(MasterSort.rating);
                      }),
                    ),
                    FilterChip(
                      label: const Text('Популярные'),
                      selected: _selectedSort == MasterSort.popular,
                      onSelected: (_) => setState(() {
                        _applySort(MasterSort.popular);
                      }),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _buildBody(provider),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedNavIndex,
            onTap: _onNavItemTapped,
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

  Widget _buildBody(GetMastersProvider provider) {
    if (provider.isLoading && provider.masters == null) {
      return const Center(child: LoadingIndicator(message: 'Загрузка мастеров...'));
    }

    if (provider.errorMessage != null) {
      return Center(
        child: ErrorWidgetCustom(
          message: provider.errorMessage!,
          onRetry: () => _loadMasters(),
        ),
      );
    }

    if (provider.masters == null || provider.masters!.isEmpty) {
      return const Center(
        child: ErrorWidgetCustom(
          message: 'В этом салоне пока нет мастеров',
        ),
      );
    }

    final masters = provider.masters!;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: masters.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final master = masters[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              MasterCard(
                name: master.UserName ?? 'Без имени',
                specialty: master.Specialization ?? 'Мастер',
                rating: master.Rating ?? 0,
                ratingCount: master.RatingCount ?? 0,
                imageUrl: master.AvatarUrl,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/master_detail',
                    arguments: master,
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BookingButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ServiceSelectionScreen(
                          masterName: master.UserName ?? 'Мастер',
                          masterId: master.Id ?? '',
                          salonId: master.SalonId ?? '',
                        ),
                      ),
                    );
                  },
                  text: 'Записаться',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}