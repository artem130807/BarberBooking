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

  @override
  void initState() {
    super.initState();
    _performSearch();
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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (salonsProvider.errorMessage != null && mounted) {
            salonsProvider.showApiError(context, salonsProvider.errorMessage);
          }
        });

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
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
                child: _buildBody(salonsProvider),
              ),
            ],
          ),
        );
      },
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
    _scrollController.dispose();
    super.dispose();
  }
}