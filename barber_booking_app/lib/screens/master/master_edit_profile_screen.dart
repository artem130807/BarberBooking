import 'dart:io';

import 'package:barber_booking_app/models/master_interface_models/request/update_master_profile_request.dart';
import 'package:barber_booking_app/screens/master/master_navigation.dart';
import 'package:barber_booking_app/models/master_models/response/get_master_response.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/providers/master_providers/master_session_provider.dart';
import 'package:barber_booking_app/services/master_services/master_profile_update_service.dart';
import 'package:barber_booking_app/services/media/admin_media_upload_service.dart';
import 'package:barber_booking_app/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class MasterEditProfileScreen extends StatefulWidget {
  const MasterEditProfileScreen({super.key, required this.profile});

  final GetMasterResponse profile;

  @override
  State<MasterEditProfileScreen> createState() =>
      _MasterEditProfileScreenState();
}

class _MasterEditProfileScreenState extends State<MasterEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _bio;
  late final TextEditingController _spec;
  final MasterProfileUpdateService _service = MasterProfileUpdateService();
  final AdminMediaUploadService _upload = AdminMediaUploadService();
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedAvatar;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _bio = TextEditingController(text: widget.profile.Bio ?? '');
    _spec = TextEditingController(text: widget.profile.Specialization ?? '');
  }

  @override
  void dispose() {
    _bio.dispose();
    _spec.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final x = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 88,
    );
    if (x != null) setState(() => _pickedAvatar = x);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final token = context.read<AuthProvider>().token;
    final id = widget.profile.Id;
    if (id == null || id.isEmpty) return;
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нужна авторизация')),
      );
      return;
    }
    setState(() => _saving = true);
    String? avatarUrl = widget.profile.AvatarUrl;
    if (_pickedAvatar != null) {
      final up = await _upload.uploadImage(
        filePath: _pickedAvatar!.path,
      );
      if (!mounted) return;
      if (up.url == null) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(up.error ?? 'Не удалось загрузить фото')),
        );
        return;
      }
      avatarUrl = up.url;
    }
    final body = UpdateMasterProfileRequest(
      Bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
      Specialization: _spec.text.trim().isEmpty ? null : _spec.text.trim(),
      AvatarUrl: avatarUrl,
    );
    final r = await _service.patch(masterId: id, body: body);
    if (!mounted) return;
    setState(() => _saving = false);
    if (r == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось сохранить')),
      );
      return;
    }
    await context.read<MasterSessionProvider>().load();
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: cs.outline.withValues(alpha: 0.2)),
    );
    return MasterScreenScaffold(
      selectedTabIndex: MasterNav.profile,
      appBar: AppBar(
        title: const Text('Редактирование'),
      ),
      body: _saving
          ? const Center(child: LoadingIndicator(message: 'Сохранение…'))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'Фото профиля',
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    shape: cardShape,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: cs.outline.withValues(alpha: 0.35),
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: Builder(
                              builder: (context) {
                                ImageProvider? bg;
                                if (_pickedAvatar != null) {
                                  bg = FileImage(File(_pickedAvatar!.path));
                                } else if (widget.profile.AvatarUrl != null &&
                                    widget.profile.AvatarUrl!.isNotEmpty) {
                                  bg = NetworkImage(widget.profile.AvatarUrl!);
                                }
                                return CircleAvatar(
                                  radius: 42,
                                  backgroundColor: cs.surfaceContainerHighest,
                                  backgroundImage: bg,
                                  child: bg == null
                                      ? Icon(Icons.person_rounded,
                                          size: 46, color: cs.primary)
                                      : null,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickAvatar,
                              icon: const Icon(Icons.photo_library_outlined),
                              label: const Text('Выбрать из галереи'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'Информация',
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    shape: cardShape,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _spec,
                            decoration: const InputDecoration(
                              labelText: 'Специализация',
                              border: OutlineInputBorder(),
                              isDense: false,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _bio,
                            decoration: const InputDecoration(
                              labelText: 'О себе',
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                            ),
                            maxLines: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Сохранить'),
                  ),
                ],
              ),
            ),
    );
  }
}
