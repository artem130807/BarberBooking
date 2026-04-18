import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/salon_providers/get_salons_search_provider.dart';
import 'package:barber_booking_app/widgets/salon_widgets/salon_card.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barber_booking_app/models/params/page_params.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;
  
  const SearchResultsScreen({
    super.key,
    required this.query,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final PageParams _pageParams = PageParams(Page: 1, PageSize: 20);
  final ScrollController _scrollController = ScrollController();
  int _selectedNavIndex = 1;

  GetSalonsSearchProvider? _searchForApiErrors;

  void _onSearchApiError() {
    if (!mounted) return;
    final p = _searchForApiErrors;
    if (p == null) return;
    final msg = p.errorMessage;
    if (msg != null && msg.isNotEmpty) p.showApiError(context, msg);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_searchForApiErrors != null) return;
    final p = context.read<GetSalonsSearchProvider>();
    _searchForApiErrors = p;
    p.addListener(_onSearchApiError);
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

  void _performSearch() {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    Provider.of<GetSalonsSearchProvider>(context, listen: false)
        .getSalons(widget.query, _pageParams);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GetSalonsSearchProvider>(
      builder: (context, searchProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Результаты поиска: "${widget.query}"'),
            centerTitle: false,
          ),
          body: RefreshIndicator(
            onRefresh: () async => _performSearch(),
            child: _buildScrollableBody(searchProvider),
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

  Widget _buildScrollableBody(GetSalonsSearchProvider provider) {
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

  Widget _buildBody(GetSalonsSearchProvider provider) {
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
              arguments: salon.Id);
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
    _searchForApiErrors?.removeListener(_onSearchApiError);
    _scrollController.dispose();
    super.dispose();
  }
}