import 'package:barber_booking_app/utils/api_media_url.dart';
import 'package:barber_booking_app/models/salon_models/request/update_salon_request.dart';
import 'package:barber_booking_app/models/salon_models/response/salon_photo_dto.dart';
import 'package:barber_booking_app/models/salon_models/response/salon_admin_stats_response.dart';
import 'package:barber_booking_app/models/vo_models/dto_address.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/salon_providers/get_salon_admin_stats_provider.dart';
import 'package:barber_booking_app/services/media/admin_media_upload_service.dart';
import 'package:barber_booking_app/services/salon_services/salon_photos_service.dart';
import 'package:barber_booking_app/widgets/salon_widgets/salon_photo_carousel.dart';
import 'package:barber_booking_app/widgets/error_widget.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

String _formatSalonAddressLine(DtoAddress? a) {
  if (a == null) return '—';
  final parts = <String>[
    if (a.City != null && a.City!.trim().isNotEmpty) a.City!.trim(),
    if (a.Street != null && a.Street!.trim().isNotEmpty) a.Street!.trim(),
    if (a.HouseNumber != null && a.HouseNumber!.trim().isNotEmpty) a.HouseNumber!.trim(),
    if (a.Apartment != null && a.Apartment!.trim().isNotEmpty) 'кв. ${a.Apartment!.trim()}',
  ];
  if (parts.isEmpty) return '—';
  return parts.join(', ');
}

class AdminSalonDetailScreen extends StatefulWidget {
  const AdminSalonDetailScreen({super.key, required this.salonId});

  final String salonId;

  @override
  State<AdminSalonDetailScreen> createState() => _AdminSalonDetailScreenState();
}

class _AdminSalonDetailScreenState extends State<AdminSalonDetailScreen> {
  final ImagePicker _picker = ImagePicker();
  final AdminMediaUploadService _upload = AdminMediaUploadService();
  final SalonPhotosService _salonPhotosService = SalonPhotosService();
  List<SalonPhotoDto> _photos = [];
  bool _loadingPhotos = true;
  int _carouselIndex = 0;
  bool _photoBusy = false;
  static const int _maxSalonPhotos = 5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  List<String> _resolvedPhotoUrls() {
    return _photos
        .map((p) => resolveApiMediaUrl(p.photoUrl))
        .whereType<String>()
        .toList();
  }

  Future<void> _loadPhotos() async {
    setState(() => _loadingPhotos = true);
    final r = await _salonPhotosService.getPhotos(widget.salonId);
    if (!mounted) return;
    setState(() {
      _loadingPhotos = false;
      _photos = r?.items ?? [];
      if (_carouselIndex >= _photos.length) {
        _carouselIndex = _photos.isEmpty ? 0 : _photos.length - 1;
      }
    });
  }

  Future<void> _load() async {
    await Future.wait([
      context.read<GetSalonAdminStatsProvider>().load(widget.salonId),
      _loadPhotos(),
    ]);
  }

  Future<void> _addSalonPhoto() async {
    if (_photos.length >= _maxSalonPhotos) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нельзя добавить больше 5 фотографий')),
      );
      return;
    }
    final token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нужна авторизация')),
      );
      return;
    }
    final x = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 88,
    );
    if (x == null || !mounted) return;
    setState(() => _photoBusy = true);
    final up = await _upload.uploadImage(filePath: x.path);
    if (!mounted) return;
    if (up.url == null) {
      setState(() => _photoBusy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(up.error ?? 'Не удалось загрузить фото')),
      );
      return;
    }
    final r = await _salonPhotosService.createPhoto(
      salonId: widget.salonId,
      photoUrl: up.url!,
    );
    if (!mounted) return;
    setState(() => _photoBusy = false);
    if (r.ok) {
      await _loadPhotos();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Фото добавлено'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(r.error ?? 'Не удалось сохранить фото')),
      );
    }
  }

  Future<void> _deleteCurrentPhoto() async {
    if (_photos.isEmpty) return;
    final i = _carouselIndex.clamp(0, _photos.length - 1);
    final photo = _photos[i];
    final token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нужна авторизация')),
      );
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить фото?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _photoBusy = true);
    final r = await _salonPhotosService.deletePhoto(photoId: photo.id);
    if (!mounted) return;
    setState(() => _photoBusy = false);
    if (r.ok) {
      await _loadPhotos();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Фото удалено'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(r.error ?? 'Не удалось удалить фото')),
      );
    }
  }

  Future<void> _openEditSalon(SalonAdminStatsResponse s) async {
    final token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нужна авторизация')),
      );
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => _SalonEditDialog(
        salonId: widget.salonId,
        initial: s,
      ),
    );
    if (ok == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Данные салона сохранены'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final df = DateFormat('dd.MM.yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Consumer<GetSalonAdminStatsProvider>(
          builder: (context, p, _) {
            final n = p.stats?.Name;
            return Text(n != null && n.isNotEmpty ? n : 'Салон');
          },
        ),
      ),
      body: Consumer<GetSalonAdminStatsProvider>(
        builder: (context, prov, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (prov.errorMessage != null && mounted) {
              prov.showApiError(context, prov.errorMessage);
            }
          });

          if (prov.isLoading && prov.stats == null) {
            return const Center(child: LoadingIndicator(message: 'Загрузка...'));
          }

          if (prov.errorMessage != null && prov.stats == null) {
            return Center(
              child: ErrorWidgetCustom(
                message: prov.errorMessage!,
                onRetry: _load,
              ),
            );
          }

          final s = prov.stats;
          if (s == null) {
            return const Center(child: Text('Нет данных'));
          }

          final urls = _resolvedPhotoUrls();
          final atLimit = _photos.length >= _maxSalonPhotos;
          final carouselH =
              (MediaQuery.sizeOf(context).width - 32) * 9 / 16;

          return RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        'Фото салона',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: cs.onSurfaceVariant,
                            ),
                      ),
                    ),
                    if (_photos.isNotEmpty)
                      Text(
                        '${_photos.length}/$_maxSalonPhotos',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_loadingPhotos && _photos.isEmpty)
                        SizedBox(
                          height: carouselH,
                          width: double.infinity,
                          child: ColoredBox(
                            color: cs.surfaceContainerHighest,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: cs.primary,
                              ),
                            ),
                          ),
                        )
                      else
                        SalonPhotoCarousel(
                          imageUrls: urls,
                          height: carouselH,
                          borderRadius: BorderRadius.zero,
                          onPageChanged: (i) => setState(() => _carouselIndex = i),
                        ),
                      if (_photoBusy)
                        Positioned.fill(
                          child: ColoredBox(
                            color: Colors.black38,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      if (!_loadingPhotos && urls.isNotEmpty)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Material(
                            color: Colors.black45,
                            shape: const CircleBorder(),
                            child: IconButton(
                              onPressed: _photoBusy ? null : _deleteCurrentPhoto,
                              icon: const Icon(Icons.delete_outline, color: Colors.white),
                              tooltip: 'Удалить текущее фото',
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: (_photoBusy || atLimit) ? null : _addSalonPhoto,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: Text(
                    atLimit
                        ? 'Достигнут лимит (5 фото)'
                        : 'Добавить из галереи',
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 0,
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: cs.outline.withValues(alpha: 0.12)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                s.Name != null && s.Name!.trim().isNotEmpty
                                    ? s.Name!.trim()
                                    : '—',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: () => _openEditSalon(s),
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              label: const Text('Изменить'),
                            ),
                          ],
                        ),
                        if (s.Description != null &&
                            s.Description!.trim().isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            s.Description!.trim(),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 20,
                              color: cs.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _formatSalonAddressLine(s.Address),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 20,
                              color: cs.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                (s.Phone != null &&
                                        s.Phone!.Number.trim().isNotEmpty)
                                    ? s.Phone!.Number.trim()
                                    : '—',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.star_rounded,
                        label: 'Рейтинг',
                        value: s.Rating != null
                            ? s.Rating!.toStringAsFixed(1)
                            : '—',
                        subtitle: '${s.RatingCount ?? 0} оценок',
                        color: cs.primaryContainer,
                        onPrimary: cs.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        icon: s.IsActive == true
                            ? Icons.check_circle_outline
                            : Icons.pause_circle_outline,
                        label: 'Статус',
                        value: s.IsActive == true ? 'Активен' : 'Неактивен',
                        subtitle: s.CreatedAt != null
                            ? 'с ${df.format(s.CreatedAt!.toLocal())}'
                            : '',
                        color: cs.secondaryContainer,
                        onPrimary: cs.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Показатели',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 10),
                _MetricTile(
                  icon: Icons.content_cut_rounded,
                  title: 'Услуги',
                  value: '${s.ServicesCount ?? 0}',
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/admin_salon_services',
                    arguments: widget.salonId,
                  ),
                ),
                _MetricTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Мастера',
                  value: '${s.MastersCount ?? 0}',
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/admin_salon_masters',
                    arguments: widget.salonId,
                  ),
                ),
                _MetricTile(
                  icon: Icons.event_note_outlined,
                  title: 'Записи',
                  value: '${s.AppointmentsCount ?? 0}',
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/admin_salon_appointments',
                    arguments: widget.salonId,
                  ),
                ),
                _MetricTile(
                  icon: Icons.reviews_outlined,
                  title: 'Отзывы',
                  value: '${s.ReviewsCount ?? 0}',
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/admin_salon_reviews',
                    arguments: widget.salonId,
                  ),
                ),
                _MetricTile(
                  icon: Icons.insights_outlined,
                  title: 'Статистика',
                  value: '',
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/admin_salon_statistics',
                    arguments: widget.salonId,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.onPrimary,
  });

  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color color;
  final Color onPrimary;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.85),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: onPrimary, size: 22),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: onPrimary.withValues(alpha: 0.85),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: onPrimary,
              ),
            ),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: onPrimary.withValues(alpha: 0.75),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    final valueStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        );
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outline.withValues(alpha: 0.12)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: cs.primary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Text(
                  title,
                  style: titleStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    value,
                    style: valueStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant, size: 22),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SalonEditDialog extends StatefulWidget {
  const _SalonEditDialog({
    required this.salonId,
    required this.initial,
  });

  final String salonId;
  final SalonAdminStatsResponse initial;

  @override
  State<_SalonEditDialog> createState() => _SalonEditDialogState();
}

class _SalonEditDialogState extends State<_SalonEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _desc;
  late final TextEditingController _city;
  late final TextEditingController _street;
  late final TextEditingController _house;
  late final TextEditingController _apt;
  late final TextEditingController _phone;
  bool _saving = false;

  static const double _gap = 14;

  @override
  void initState() {
    super.initState();
    final s = widget.initial;
    _name = TextEditingController(text: s.Name ?? '');
    _desc = TextEditingController(text: s.Description ?? '');
    final a = s.Address;
    _city = TextEditingController(text: a?.City ?? '');
    _street = TextEditingController(text: a?.Street ?? '');
    _house = TextEditingController(text: a?.HouseNumber ?? '');
    _apt = TextEditingController(text: a?.Apartment ?? '');
    _phone = TextEditingController(text: s.Phone?.Number ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _city.dispose();
    _street.dispose();
    _house.dispose();
    _apt.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    if (await auth.ensureValidAccessToken() == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нужна авторизация')),
      );
      return;
    }
    setState(() => _saving = true);
    final prov = context.read<GetSalonAdminStatsProvider>();
    final apt = _apt.text.trim();
    final body = UpdateSalonRequest(
      name: _name.text.trim(),
      description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
      address: UpdateSalonAddressRequest(
        city: _city.text.trim(),
        street: _street.text.trim(),
        houseNumber: _house.text.trim(),
        apartment: apt.isEmpty ? null : apt,
      ),
      phoneNumber: _phone.text.trim().isEmpty
          ? null
          : UpdateSalonPhoneRequest(number: _phone.text.trim()),
    );
    final ok = await prov.updateSalon(widget.salonId, body);
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      Navigator.of(context).pop(true);
    } else if (prov.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(prov.errorMessage!),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('Редактирование салона'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Название',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Укажите название' : null,
              ),
              const SizedBox(height: _gap),
              TextFormField(
                controller: _desc,
                decoration: const InputDecoration(
                  labelText: 'Описание',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: _gap),
              Text(
                'Адрес',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _city,
                decoration: const InputDecoration(
                  labelText: 'Город',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Укажите город' : null,
              ),
              const SizedBox(height: _gap),
              TextFormField(
                controller: _street,
                decoration: const InputDecoration(
                  labelText: 'Улица',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Укажите улицу' : null,
              ),
              const SizedBox(height: _gap),
              TextFormField(
                controller: _house,
                decoration: const InputDecoration(
                  labelText: 'Дом',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Укажите дом' : null,
              ),
              const SizedBox(height: _gap),
              TextFormField(
                controller: _apt,
                decoration: const InputDecoration(
                  labelText: 'Квартира / офис',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: _gap),
              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(
                  labelText: 'Телефон',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: cs.onPrimary,
                  ),
                )
              : const Text('Сохранить'),
        ),
      ],
    );
  }
}
