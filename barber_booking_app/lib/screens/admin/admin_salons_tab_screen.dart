import 'package:barber_booking_app/models/params/page_params.dart';
import 'package:barber_booking_app/models/params/salon_params/salon_filter.dart';
import 'package:barber_booking_app/models/salon_models/response/get_salons_response.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/salon_providers/get_salons_provider.dart';
import 'package:barber_booking_app/providers/salon_providers/get_salons_search_provider.dart';
import 'package:barber_booking_app/screens/admin/admin_create_salon_screen.dart';
import 'package:barber_booking_app/screens/admin/admin_navigation.dart';
import 'package:barber_booking_app/screens/admin/admin_shell_layout.dart';
import 'package:barber_booking_app/utils/api_media_url.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminSalonsTabScreen extends StatefulWidget {
  const AdminSalonsTabScreen({super.key});

  @override
  State<AdminSalonsTabScreen> createState() => _AdminSalonsTabScreenState();
}

class _AdminSalonsTabScreenState extends State<AdminSalonsTabScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final PageParams _pageParams = PageParams(Page: 1, PageSize: 50);
  final SalonFilter _filter = SalonFilter();
  String? _activeSearchQuery;
  bool _initializing = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    setState(() => _activeSearchQuery = null);
    _searchController.clear();
    Provider.of<GetSalonsSearchProvider>(context, listen: false).clearResults();
    await Provider.of<GetSalonsProvider>(context, listen: false)
        .getSalons(_pageParams, _filter, token);
    if (mounted) setState(() => _initializing = false);
  }

  Future<void> _onSubmittedSearch(String raw) async {
    final query = raw.trim();
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final search = Provider.of<GetSalonsSearchProvider>(context, listen: false);
    if (query.isEmpty) {
      setState(() => _activeSearchQuery = null);
      search.clearResults();
      await Provider.of<GetSalonsProvider>(context, listen: false)
          .getSalons(_pageParams, _filter, token);
      return;
    }
    setState(() => _activeSearchQuery = query);
    await search.getSalons(query, _pageParams, token);
  }

  Future<void> _onRefresh() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (_activeSearchQuery != null && _activeSearchQuery!.isNotEmpty) {
      await Provider.of<GetSalonsSearchProvider>(context, listen: false)
          .getSalons(_activeSearchQuery, _pageParams, token);
    } else {
      await Provider.of<GetSalonsProvider>(context, listen: false)
          .getSalons(_pageParams, _filter, token);
    }
  }

  Future<void> _openCreateSalon() async {
    final id = await Navigator.of(context, rootNavigator: true).push<String?>(
      MaterialPageRoute<String?>(
        builder: (ctx) => const AdminShellLayout(
          selectedTab: AdminNav.salons,
          child: AdminCreateSalonScreen(),
        ),
      ),
    );
    if (!mounted) return;
    if (id != null && id.isNotEmpty) {
      await _onRefresh();
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true)
          .pushNamed('/admin_salon_detail', arguments: id);
    }
  }

  Widget _buildSalonRow(GetSalonsResponse salon) {
    final theme = Theme.of(context);
    final photo = resolveApiMediaUrl(salon.MainPhotoUrl);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          final id = salon.Id;
          if (id == null || id.isEmpty) return;
          Navigator.pushNamed(context, '/admin_salon_detail', arguments: id);
        },
        child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 56,
            height: 56,
            child: photo != null && photo.isNotEmpty
                ? Image.network(
                    photo,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => ColoredBox(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.store, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  )
                : ColoredBox(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(Icons.store, color: theme.colorScheme.onSurfaceVariant),
                  ),
          ),
        ),
        title: Text(
          salon.Name ?? '—',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          salon.Address?.Street ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
        ),
        trailing: salon.Rating != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    salon.Rating!.toStringAsFixed(1),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              )
            : null,
      ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<GetSalonsProvider, GetSalonsSearchProvider>(
      builder: (context, salonsProvider, searchProvider, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (salonsProvider.errorMessage != null && mounted) {
            salonsProvider.showApiError(context, salonsProvider.errorMessage);
          }
        });

        final inSearch = _activeSearchQuery != null && _activeSearchQuery!.isNotEmpty;
        final loading = inSearch
            ? searchProvider.isLoading
            : salonsProvider.isLoading;
        final list = inSearch
            ? (searchProvider.getSalonsResponse ?? [])
            : (salonsProvider.getSalonsResponse ?? []);
        final initialError = !inSearch &&
            salonsProvider.errorMessage != null &&
            salonsProvider.getSalonsResponse == null;
        final showBootstrapLoading =
            !inSearch && _initializing && !salonsProvider.isLoading;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Салоны'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                tooltip: 'Добавить салон',
                onPressed: _openCreateSalon,
                icon: const Icon(Icons.add_business_rounded),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openCreateSalon,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Добавить салон'),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Поиск салона....',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _onSubmittedSearch('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: _onSubmittedSearch,
                  ),
                ),
              ),
              Expanded(
                child: _buildBody(
                  loading,
                  initialError,
                  list,
                  salonsProvider,
                  showBootstrapLoading,
                  inSearch,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(
    bool loading,
    bool initialError,
    List<GetSalonsResponse> list,
    GetSalonsProvider salonsProvider,
    bool showBootstrapLoading,
    bool inSearch,
  ) {
    if (showBootstrapLoading ||
        (loading && list.isEmpty && !initialError)) {
      return const Center(child: LoadingIndicator(message: 'Загрузка салонов...'));
    }
    if (initialError) {
      return Center(
        child: ErrorWidgetCustom(
          message: salonsProvider.errorMessage!,
          onRetry: _loadAll,
        ),
      );
    }
    if (list.isEmpty) {
      final cs = Theme.of(context).colorScheme;
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.storefront_outlined,
                size: 64,
                color: cs.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 16),
              Text(
                inSearch ? 'Ничего не найдено' : 'Пока нет салонов',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                inSearch
                    ? 'Попробуйте другой запрос или сбросьте поиск'
                    : 'Создайте первый салон — дальше можно добавить услуги и мастеров',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              if (!inSearch) ...[
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _openCreateSalon,
                  icon: const Icon(Icons.add_business_rounded),
                  label: const Text('Добавить салон'),
                ),
              ],
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 88),
        itemCount: list.length,
        itemBuilder: (context, index) => _buildSalonRow(list[index]),
      ),
    );
  }
}
