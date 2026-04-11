import 'package:barber_booking_app/models/salon_models/request/create_salon_request.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/services/salon_services/admin_create_salon_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminCreateSalonScreen extends StatefulWidget {
  const AdminCreateSalonScreen({super.key});

  @override
  State<AdminCreateSalonScreen> createState() => _AdminCreateSalonScreenState();
}

class _AdminCreateSalonScreenState extends State<AdminCreateSalonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _city = TextEditingController();
  final _street = TextEditingController();
  final _house = TextEditingController();
  final _apt = TextEditingController();
  final _phone = TextEditingController();
  final _photoUrl = TextEditingController();
  final _service = AdminCreateSalonService();
  bool _saving = false;

  static const double _gap = 14;
  static final RegExp _houseRe = RegExp(r'^[0-9А-Яа-я/\-]+$');
  static final RegExp _phoneRe = RegExp(
    r'^(\+7|7|8)?[\s\-]?\(?\d{3}\)?[\s\-]?\d{3}[\s\-]?\d{2}[\s\-]?\d{2}$',
  );

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _city.dispose();
    _street.dispose();
    _house.dispose();
    _apt.dispose();
    _phone.dispose();
    _photoUrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нужна авторизация')),
      );
      return;
    }
    setState(() => _saving = true);
    final apt = _apt.text.trim();
    final body = CreateSalonRequest(
      name: _name.text.trim(),
      description: _desc.text.trim(),
      mainPhotoUrl: _photoUrl.text.trim(),
      dtoAddress: CreateSalonAddressDto(
        city: _city.text.trim(),
        street: _street.text.trim(),
        houseNumber: _house.text.trim(),
        apartment: apt.isEmpty ? null : apt,
      ),
      phone: CreateSalonPhoneDto(number: _phone.text.trim()),
    );
    final r = await _service.create(body, token);
    if (!mounted) return;
    setState(() => _saving = false);
    if (r.ok && r.data?.id != null && r.data!.id!.isNotEmpty) {
      Navigator.of(context).pop<String>(r.data!.id);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(r.error ?? 'Не удалось создать салон'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новый салон'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Text(
              'Заполните данные салона. После создания можно добавить услуги и мастеров в карточке салона.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Название салона',
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
              maxLines: 4,
            ),
            const SizedBox(height: _gap),
            Text(
              'Адрес',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 10),
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
                helperText: 'Только цифры, кириллица, / и -',
              ),
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isEmpty) return 'Укажите номер дома';
                if (!_houseRe.hasMatch(t)) return 'Некорректный формат номера дома';
                return null;
              },
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
                labelText: 'Телефон салона',
                border: OutlineInputBorder(),
                helperText: 'Формат РФ, например +79001234567',
              ),
              keyboardType: TextInputType.phone,
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isEmpty) return 'Укажите телефон';
                if (!_phoneRe.hasMatch(t)) {
                  return 'Номер не соответствует формату';
                }
                return null;
              },
            ),
            const SizedBox(height: _gap),
            TextFormField(
              controller: _photoUrl,
              decoration: const InputDecoration(
                labelText: 'Ссылка на фото (необязательно)',
                border: OutlineInputBorder(),
                helperText: 'Можно оставить пустым и загрузить фото позже',
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _saving ? null : _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _saving
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.onPrimary,
                      ),
                    )
                  : const Text('Создать салон'),
            ),
          ],
        ),
      ),
    );
  }
}
