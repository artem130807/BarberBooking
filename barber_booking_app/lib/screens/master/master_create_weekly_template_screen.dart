import 'package:barber_booking_app/models/master_interface_models/request/create_weekly_template_request.dart';
import 'package:barber_booking_app/screens/master/master_navigation.dart';
import 'package:barber_booking_app/providers/auth_providers/auth_provider.dart';
import 'package:barber_booking_app/services/master_services/weekly_template_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MasterCreateWeeklyTemplateScreen extends StatefulWidget {
  const MasterCreateWeeklyTemplateScreen({super.key});

  @override
  State<MasterCreateWeeklyTemplateScreen> createState() =>
      _MasterCreateWeeklyTemplateScreenState();
}

class _MasterCreateWeeklyTemplateScreenState
    extends State<MasterCreateWeeklyTemplateScreen> {
  final WeeklyTemplateService _service = WeeklyTemplateService();
  final TextEditingController _name = TextEditingController();
  bool _active = true;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название')),
      );
      return;
    }
    final token = context.read<AuthProvider>().token;
    setState(() => _saving = true);
    final (id, err) = await _service.createTemplate(
      token: token,
      body: CreateWeeklyTemplateRequest(name: name, isActive: _active),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err)),
      );
      return;
    }
    if (id != null && id.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Шаблон создан')),
      );
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return MasterScreenScaffold(
      selectedTabIndex: MasterNav.slots,
      appBar: AppBar(
        title: const Text('Новый шаблон'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Сначала задаётся только название. Дни недели и время можно добавить позже — от 1 до 7 дней.',
            style: TextStyle(
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _name,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Название',
              hintText: 'Например, «Стандартная неделя»',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) {
              if (!_saving) _save();
            },
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Активен'),
            subtitle: Text(
              'Неактивные шаблоны можно оставить как черновики',
              style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
            ),
            value: _active,
            onChanged: _saving ? null : (v) => setState(() => _active = v),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Создать'),
          ),
        ],
      ),
    );
  }
}
