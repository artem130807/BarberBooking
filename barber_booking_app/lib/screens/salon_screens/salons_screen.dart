import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/salon_providers/get_salons_provider.dart';
import 'package:barber_booking_app/widgets/salon_widgets/salon_card.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barber_booking_app/models/params/page_params.dart';

class SalonsScreen extends StatefulWidget {
  
  const SalonsScreen({super.key,});

  @override
  State<SalonsScreen> createState() => _SalonsScreenState();
}

class _SalonsScreenState extends State<SalonsScreen> {
  final PageParams _pageParams = PageParams(Page: 1, PageSize: 20);
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  void _performSearch() {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    Provider.of<GetSalonsProvider>(context, listen: false)
        .getSalons(_pageParams, token);
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
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            title: const Text('Список салонов'),
            centerTitle: false,
          ),
          body: _buildBody(salonsProvider),
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
              arguments: salon.Id);
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