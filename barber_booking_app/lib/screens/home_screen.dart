import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/models/params/salon_params/salon_filter.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/master_providers/get_the_best_masters_provider.dart';
import 'package:barber_booking_app/providers/salon_providers/get_salons_provider.dart';
import 'package:barber_booking_app/screens/master_screens/master_detail_screen.dart';
import 'package:barber_booking_app/widgets/categors_widgets/category_item.dart';
import 'package:barber_booking_app/widgets/master_widgets/master_card.dart';
import 'package:barber_booking_app/widgets/salon_widgets/salon_card.dart';
import 'package:barber_booking_app/screens/salon_screens/search_results_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';
import 'package:barber_booking_app/widgets/section_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;
  final PageParams _pageParams = PageParams(Page: 1, PageSize: 3);
  final SalonFilter filter = SalonFilter();
  int _selectedNavIndex = 0; 

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      Provider.of<GetSalonsProvider>(context, listen: false).getSalons(_pageParams, filter, token);
      Provider.of<GetTheBestMastersProvider>(context, listen: false).getMasters(4, token);
    });
  }

  void _onFocusChange() {
    setState(() {
      _isSearchFocused = _searchFocusNode.hasFocus;
    });
  }

  void _navigateToSalonsByService(BuildContext context, String serviceName) {
    Navigator.pushNamed(
      context,
      '/salons_by_service',
      arguments: serviceName,
    );
  }

  Future<void> _onRefreshHome() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) return;
    await Future.wait([
      Provider.of<GetSalonsProvider>(context, listen: false).getSalons(_pageParams, filter, token),
      Provider.of<GetTheBestMastersProvider>(context, listen: false).getMasters(4, token),
    ]);
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedNavIndex = index;
    });
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(context, '/search_screen');
        break;
      case 2:
        Navigator.pushNamed(context, '/appointments_screen');
        break;
      case 3:
        Navigator.pushNamed(context, '/favorites_screen');
        break;
      case 4:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bestMastersProvider = Provider.of<GetTheBestMastersProvider>(context);
    return Consumer<GetSalonsProvider>(
      builder: (context, salonProvider, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (salonProvider.errorMessage != null && mounted) {
            salonProvider.showApiError(context, salonProvider.errorMessage);
          }
        });

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'BarberBooking',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: false,
            actions: const [
              Icon(Icons.notifications_outlined),
              SizedBox(width: 16),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _onRefreshHome,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Привет, Гость!',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Найди свой идеальный стиль',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      textInputAction: TextInputAction.search,
                      decoration: const InputDecoration(
                        hintText: 'Поиск салона....',
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onSubmitted: (value) {
                        final query = value.trim();
                        if (query.isEmpty) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SearchResultsScreen(query: query),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Stack(
                  children: [
                    Opacity(
                      opacity: _isSearchFocused ? 0.3 : 1.0,
                      child: AbsorbPointer(
                        absorbing: _isSearchFocused,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionHeader(title: 'Категории услуг'),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 90,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                children: [
                                  CategoryItem(
                                    icon: Icons.content_cut,
                                    label: 'Стрижка',
                                    onTap: () => _navigateToSalonsByService(context, 'Стрижка'),
                                  ),
                                  CategoryItem(
                                    icon: Icons.face,
                                    label: 'Бритье',
                                    onTap: () => _navigateToSalonsByService(context, 'Бритье'),
                                  ),
                                  CategoryItem(
                                    icon: Icons.style,
                                    label: 'Усы/борода',
                                    onTap: () => _navigateToSalonsByService(context, 'Усы/борода'),
                                  ),
                                  CategoryItem(
                                    icon: Icons.spa,
                                    label: 'Массаж',
                                    onTap: () => _navigateToSalonsByService(context, 'Массаж'),
                                  ),
                                  CategoryItem(
                                    icon: Icons.child_care,
                                    label: 'Детская',
                                    onTap: () => _navigateToSalonsByService(context, 'Детская'),
                                  ),
                                  CategoryItem(
                                    icon: Icons.star,
                                    label: 'Премиум',
                                    onTap: () => _navigateToSalonsByService(context, 'Премиум'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            SectionHeader(
                              title: 'Салоны в вашем городе',
                              actionText: 'Все',
                              onActionTap: () async {
                                Navigator.pushReplacementNamed(context, '/salons_screen');
                              },
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: _buildSalonsList(salonProvider),
                            ),
                            const SizedBox(height: 24),
                            const SectionHeader(title: 'Лучшие мастера'),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 180,
                              child: _buildBestMastersList(bestMastersProvider),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                    if (_isSearchFocused)
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            _searchFocusNode.unfocus();
                          },
                          child: Container(
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            ),
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

  Widget _buildSalonsList(GetSalonsProvider provider) {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (provider.isLoading && provider.getSalonsResponse == null) {
      return const LoadingIndicator(message: 'Загрузка салонов...');
    }

    if (provider.errorMessage != null) {
      return ErrorWidgetCustom(
        message: provider.errorMessage!,
        onRetry: () => provider.getSalons(_pageParams, filter, token),
      );
    }

    if (provider.getSalonsResponse == null || provider.getSalonsResponse!.isEmpty) {
      return const ErrorWidgetCustom(
        message: 'Салоны в вашем городе не найдены',
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.getSalonsResponse!.length,
      itemBuilder: (context, index) {
        final salon = provider.getSalonsResponse![index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SalonCard(
            salon: salon,
            onTap: () {
              Navigator.pushNamed(
              context,
              '/salon_screen',
              arguments: salon.Id, 
            );
            },
            onBooking: () {
              Navigator.pushNamed(
              context,
              '/salon_masters',
              arguments: salon.Id,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBestMastersList(GetTheBestMastersProvider provider) {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (provider.isLoading && provider.getMasterResponse == null) {
      return const LoadingIndicator(message: 'Загрузка мастеров...');
    }

    if (provider.errorMessage != null) {
      return ErrorWidgetCustom(
        message: provider.errorMessage!,
        onRetry: () => provider.getMasters(4, token),
      );
    }

    if (provider.getMasterResponse == null || provider.getMasterResponse!.isEmpty) {
      return const ErrorWidgetCustom(
        message: 'Лучшие мастера не найдены',
      );
    }

    final masters = provider.getMasterResponse!;
    final itemCount = masters.length > 4 ? 4 : masters.length;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final master = masters[index];
        return MasterCard(
          name: master.UserName ?? 'Без имени',
          specialty: 'Барбер',
          rating: 5.0,
          imageUrl: master.AvatarUrl,
          onTap: () {
          Navigator.pushNamed(
            context,
            '/master_detail',
            arguments: master.Id, 
          );
          },
        );
      },
    );
  }
}