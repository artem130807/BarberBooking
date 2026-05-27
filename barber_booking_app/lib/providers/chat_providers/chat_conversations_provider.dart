import 'dart:collection';

import 'package:barber_booking_app/models/base/base_provider.dart';
import 'package:barber_booking_app/models/chat_models/chat_conversation_summary.dart';
import 'package:barber_booking_app/services/chat_services/chat_conversation_service.dart';

class ChatConversationsProvider extends BaseProvider {
  ChatConversationsProvider({ChatConversationService? service})
      : _service = service ?? ChatConversationService();

  final ChatConversationService _service;

  final List<ChatConversationSummary> _conversations = [];
  int _totalUnread = 0;

  UnmodifiableListView<ChatConversationSummary> get conversations =>
      UnmodifiableListView(_conversations);

  int get totalUnread => _totalUnread;

  Future<void> refresh() async {
    startLoading();
    await _refreshCore();
    finishLoading();
    notifyListeners();
  }

  Future<void> refreshUnreadCount() async {
    _totalUnread = await _service.getTotalUnreadMessages();
    notifyListeners();
  }

  Future<ChatConversationSummary?> createOrFindConversation({
    required String participantId,
    required String participantName,
  }) async {
    final trimmedName = participantName.trim();

    final existing = _findByName(trimmedName);
    if (existing != null) return existing;

    final foundBySearch = await _findBySearch(trimmedName);
    if (foundBySearch != null) {
      await _refreshCore();
      notifyListeners();
      return foundBySearch;
    }

    final created = await _service.createConversation(participantId);
    if (!created) {
      await _refreshCore();
      notifyListeners();
      return _findByName(trimmedName);
    }

    await _refreshCore();
    notifyListeners();

    return _findByName(trimmedName) ?? _conversations.firstOrNull;
  }

  Future<void> _refreshCore() async {
    final items = await _service.getConversations();
    _conversations
      ..clear()
      ..addAll(items);
    _totalUnread = await _service.getTotalUnreadMessages();
  }

  ChatConversationSummary? _findByName(String name) {
    if (name.isEmpty) return null;
    final normalized = _normalizeName(name);
    for (final c in _conversations) {
      if (_normalizeName(c.userName) == normalized) {
        return c;
      }
    }
    return null;
  }

  Future<ChatConversationSummary?> _findBySearch(String name) async {
    if (name.isEmpty) return null;
    final result = await _service.searchConversationsByName(name);
    if (result.isEmpty) return null;
    final normalized = _normalizeName(name);
    for (final c in result) {
      if (_normalizeName(c.userName) == normalized) {
        return c;
      }
    }
    return result.first;
  }

  String _normalizeName(String value) {
    return value.trim().toLowerCase();
  }
}

extension _FirstOrNullExt<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

