import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/providers/salon_providers/get_salons_by_service_provider.dart';
import 'package:barber_booking_app/widgets/salon_widgets/salon_card.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';
import 'package:barber_booking_app/widgets/navigation/user_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SalonsByServiceScreen extends StatefulWidget {
  final String serviceName;

  const SalonsByServiceScreen({super.key, required this.serviceName});

  @override
  State<SalonsByServiceScreen> createState() => _SalonsByServiceScreenState();
}

class _SalonsByServiceScreenState extends State<SalonsByServiceScreen> {
  final PageParams _pageParams = PageParams(Page: 1, PageSize: 20);
  final ScrollController _scrollController = ScrollController();
  int _selectedNavIndex = 0;

  GetSalonsByServiceProvider? _byServiceForApiErrors;

  void _onByServiceApiError() {
    if (!mounted) return;
    final p = _byServiceForApiErrors;
    if (p == null) return;
    final msg = p.errorMessage;
    if (msg != null && msg.isNotEmpty) p.showApiError(context, msg);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_byServiceForApiErrors != null) return;
    final p = context.read<GetSalonsByServiceProvider>();
    _byServiceForApiErrors = p;
    p.addListener(_onByServiceApiError);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadSalons();
    });
  }

  void _onNavItemTapped(int index) {
    final previousIndex = _selectedNavIndex;
    setState(() => _selectedNavIndex = index);
    if (index == previousIndex) return;
    UserBottomNavigationBar.navigateByIndex(context, index);
  }

  void _loadSalons() {
    Provider.of<GetSalonsByServiceProvider>(context, listen: false)
        .getSalons(widget.serviceName, _pageParams);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GetSalonsByServiceProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Салоны: ${widget.serviceName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            centerTitle: false,
          ),
          body: _buildBody(provider),
          bottomNavigationBar: UserBottomNavigationBar(
            selectedIndex: _selectedNavIndex,
            onTap: _onNavItemTapped,
          ),
        );
      },
    );
  }

  Widget _buildBody(GetSalonsByServiceProvider provider) {
    if (provider.isLoading && provider.getSalonsResponse == null) {
      return const LoadingIndicator(
        message: 'Поиск салонов с услугой...',
      );
    }

    if (provider.errorMessage != null) {
      return ErrorWidgetCustom(
        message: provider.errorMessage!,
        onRetry: _loadSalons,
      );
    }

    if (provider.getSalonsResponse == null ||
        provider.getSalonsResponse!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Салоны с услугой «${widget.serviceName}» не найдены',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Попробуйте выбрать другую услугу',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
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
                '/salon_screen',
                arguments: salon.Id,
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _byServiceForApiErrors?.removeListener(_onByServiceApiError);
    _scrollController.dispose();
    super.dispose();
  }
}
