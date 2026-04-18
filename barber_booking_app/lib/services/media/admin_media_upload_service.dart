import 'dart:convert';
import 'dart:io';

import 'package:barber_booking_app/config/api_config.dart';
import 'package:barber_booking_app/services/auth_services/auth_http_headers.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

/// Загрузка в [MediaController.UploadImage].
///
/// Важно: `MultipartFile.fromPath` без [MediaType] отправляет `application/octet-stream`,
/// а API принимает только `image/jpeg|png|webp`. Поэтому задаём тип и имя файла явно.
class AdminMediaUploadService {
  static MediaType _mediaTypeForPath(String filePath) {
    final lower = filePath.toLowerCase();
    if (lower.endsWith('.png')) return MediaType('image', 'png');
    if (lower.endsWith('.webp')) return MediaType('image', 'webp');
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return MediaType('image', 'jpeg');
    }
    return MediaType('image', 'jpeg');
  }

  static String _fileName(String filePath) {
    final seg = File(filePath).uri.pathSegments;
    if (seg.isNotEmpty) return seg.last;
    return 'image.jpg';
  }

  /// `url` — при успехе; `error` — текст с сервера или HTTP.
  Future<({String? url, String? error})> uploadImage({
    required String filePath,
  }) async {
    final auth = await AuthHttpHeaders.bearerAuthOnly();
    if (auth == null) {
      return (url: null, error: 'Нет авторизации');
    }
    final uri = Uri.parse('$kApiBaseUrl/api/Media/upload-image');
    final req = http.MultipartRequest('POST', uri);
    req.headers.addAll(auth);
    req.files.add(
      await http.MultipartFile.fromPath(
        'file',
        filePath,
        filename: _fileName(filePath),
        contentType: _mediaTypeForPath(filePath),
      ),
    );
    final streamed = await req.send();
    final resp = await http.Response.fromStream(streamed);
    if (resp.statusCode != 200) {
      final err = _parseError(resp.body);
      return (url: null, error: err ?? 'Ошибка ${resp.statusCode}');
    }
    try {
      final map = json.decode(resp.body) as Map<String, dynamic>;
      final url = map['url'] as String?;
      if (url == null || url.isEmpty) {
        return (url: null, error: 'Пустой ответ сервера');
      }
      return (url: url, error: null);
    } catch (e) {
      return (url: null, error: e.toString());
    }
  }

  String? _parseError(String body) {
    try {
      final decoded = json.decode(body);
      if (decoded is Map) {
        final e = decoded['error'] ?? decoded['title'] ?? decoded['message'];
        if (e != null) return e.toString();
      }
      if (decoded is String) return decoded;
    } catch (_) {}
    if (body.isNotEmpty && body.length < 400) return body;
    return null;
  }
}
