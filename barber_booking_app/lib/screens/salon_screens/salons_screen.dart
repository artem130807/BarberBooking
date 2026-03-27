import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/models/params/salon_params/salon_filter.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/salon_providers/get_salons_provider.dart';
import 'package:barber_booking_app/widgets/salon_widgets/salon_card.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum SortType { none, rating, popular, price }

class SalonsScreen extends StatefulWidget {
  const SalonsScreen({super.key});

  @override
  State<SalonsScreen> createState() => _SalonsScreenState();
}

class _SalonsScreenState extends State<SalonsScreen> {
  final PageParams _pageParams = PageParams(Page: 1, PageSize: 20);
  SortType _selectedSort = SortType.none;
  bool _isActiveOnly = false;
  final ScrollController _scrollController = ScrollController();
  int _selectedNavIndex = 0;

  GetSalonsProvider? _salonsForApiErrors;

  void _onSalonsApiError() {
    if (!mounted) return;
    final p = _salonsForApiErrors;
    if (p == null) return;
    final msg = p.errorMessage;
    if (msg != null && msg.isNotEmpty) p.showApiError(context, msg);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_salonsForApiErrors != null) return;
    final p = context.read<GetSalonsProvider>();
    _salonsForApiErrors = p;
    p.addListener(_onSalonsApiError);
  }

  @override
  void initState() {
    super.initState();
    _performSearch();
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

  void _applyFilter() {
    final filter = SalonFilter(
      IsActive: _isActiveOnly,
      MaxRating: _selectedSort == SortType.rating,
      Popular: _selectedSort == SortType.popular,
      MinPrice: _selectedSort == SortType.price,
    );
    _performSearch(filter: filter);
  }

  void _performSearch({SalonFilter? filter}) {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final effectiveFilter = filter ?? SalonFilter();
    Provider.of<GetSalonsProvider>(context, listen: false)
        .getSalons(_pageParams, effectiveFilter, token);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GetSalonsProvider>(
      builder: (context, salonsProvider, child) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Список салонов'),
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.clear_all),
                onPressed: () {
                  setState(() {
                    _selectedSort = SortType.none;
                    _isActiveOnly = false;
                  });
                  _applyFilter();
                },
              ),
            ],
          ),
          body: Column(
            children: [
            
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Только активные'),
                      selected: _isActiveOnly,
                      onSelected: (selected) {
                        setState(() => _isActiveOnly = selected);
                        _applyFilter();
                      },
                    ),
                    FilterChip(
                      label: const Text('По рейтингу'),
                      selected: _selectedSort == SortType.rating,
                      onSelected: (selected) {
                        setState(() => _selectedSort = selected ? SortType.rating : SortType.none);
                        _applyFilter();
                      },
                    ),
                    FilterChip(
                      label: const Text('Популярные'),
                      selected: _selectedSort == SortType.popular,
                      onSelected: (selected) {
                        setState(() => _selectedSort = selected ? SortType.popular : SortType.none);
                        _applyFilter();
                      },
                    ),
                    FilterChip(
                      label: const Text('Дешевле'),
                      selected: _selectedSort == SortType.price,
                      onSelected: (selected) {
                        setState(() => _selectedSort = selected ? SortType.price : SortType.none);
                        _applyFilter();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _performSearch(),
                  child: _buildScrollableBody(salonsProvider),
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedNavIndex,
            onTap: _onNavItemTapped,
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

  Widget _buildScrollableBody(GetSalonsProvider provider) {
    final body = _buildBody(provider);
    if (body is ListView) {
      return body;
    }
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: body,
      ),
    );
  }

  Widget _buildBody(GetSalonsProvider provider) {
    if (provider.isLoading && provider.getSalonsResponse == null) {
      return const LoadingIndicator(message: 'Поиск салонов...');
    }

    if (provider.errorMessage != null) {
      return ErrorWidgetCustom(
        message: provider.errorMessage!,
        onRetry: _performSearch,
      );
    }

    if (provider.getSalonsResponse == null || provider.getSalonsResponse!.isEmpty) {
      return const Center(
        child: Text(
          'Ничего не найдено',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
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
              arguments: salon.Id);
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _salonsForApiErrors?.removeListener(_onSalonsApiError);
    _scrollController.dispose();
    super.dispose();
  }
}