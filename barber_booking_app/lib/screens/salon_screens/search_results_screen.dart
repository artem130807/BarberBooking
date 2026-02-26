import 'package:barber_booking_app/providers/authProviders/auth_provider.dart';
import 'package:barber_booking_app/providers/salonProviders/get_salons_search_provider.dart';
import 'package:barber_booking_app/widgets/salon_widgets/salon_card.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barber_booking_app/models/Params/page_params.dart';

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

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  void _performSearch() {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    Provider.of<GetSalonsSearchProvider>(context, listen: false)
        .getSalons(widget.query, _pageParams, token);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GetSalonsSearchProvider>(
      builder: (context, searchProvider, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (searchProvider.errorMessage != null && mounted) {
            searchProvider.showApiError(context, searchProvider.errorMessage);
          }
        });

        return Scaffold(
          appBar: AppBar(
            title: Text('Результаты поиска: "${widget.query}"'),
            centerTitle: false,
          ),
          body: _buildBody(searchProvider),
        );
      },
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
      padding: const EdgeInsets.all(16),
      itemCount: provider.getSalonsResponse!.length,
      itemBuilder: (context, index) {
        final salon = provider.getSalonsResponse![index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SalonCard(
            salon: salon,
            onTap: () {
              // Переход на детали салона
            },
            onBooking: () {
              // Переход на запись
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