import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/service_providers/get_service_search_provider.dart';
import 'package:barber_booking_app/models/service_models/response/get_service_search_response.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';

class SearchServicesScreen extends StatefulWidget {
  const SearchServicesScreen({super.key});

  @override
  State<SearchServicesScreen> createState() => _SearchServicesScreenState();
}

class _SearchServicesScreenState extends State<SearchServicesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;
  int _selectedNavIndex = 1;

  List<GetServiceSearchResponse> _allServices = [];
  List<GetServiceSearchResponse> _filteredServices = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onFocusChange);
    _loadServices();
    _searchController.addListener(_filterServices);
  }

  void _onFocusChange() {
    setState(() {
      _isSearchFocused = _searchFocusNode.hasFocus;
    });
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Требуется авторизация';
      });
      return;
    }
    final provider = Provider.of<GetServiceSearchProvider>(context, listen: false);
    final success = await provider.getServices(token);
    if (success == true && mounted) {
      setState(() {
        _allServices = provider.list ?? [];
        _filteredServices = _allServices;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        _errorMessage = provider.errorMessage ?? 'Ошибка загрузки';
        _isLoading = false;
      });
    }
  }

  void _filterServices() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredServices = _allServices;
      });
    } else {
      setState(() {
        _filteredServices = _allServices.where((s) {
          final name = s.name?.toLowerCase() ?? '';
          return name.contains(query);
        }).toList();
      });
    }
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

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();
    _searchController.removeListener(_filterServices);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Поиск услуг'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Введите название услуги...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Opacity(
                  opacity: _isSearchFocused ? 0.3 : 1.0,
                  child: AbsorbPointer(
                    absorbing: _isSearchFocused,
                    child: _buildBody(),
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
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingIndicator(message: 'Загрузка услуг...');
    }
    if (_errorMessage != null) {
      return ErrorWidgetCustom(
        message: _errorMessage!,
        onRetry: _loadServices,
      );
    }
    if (_filteredServices.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.isEmpty
              ? 'Услуги не найдены'
              : 'Ничего не найдено',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredServices.length,
      itemBuilder: (context, index) {
        final service = _filteredServices[index];
        return ServiceSearchCard(service: service);
      },
    );
  }
}

class ServiceSearchCard extends StatelessWidget {
  final GetServiceSearchResponse service;

  const ServiceSearchCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final salon = service.dtoSalonNavigation;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 60,
                height: 60,
                color: Colors.grey[200],
                child: service.photoUrl != null
                    ? Image.network(
                        service.photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.grey),
                      )
                    : const Icon(Icons.image, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name ?? 'Услуга',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${service.durationMinutes ?? 0} мин • ${service.price?.Value ?? 0} ₽',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  if (salon != null)
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/salon_screen',
                          arguments: salon.Id,
                        );
                      },
                      child: Text(
                        salon.SalonName ?? 'Салон',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}