import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Fornece um identificador único do dispositivo persistente por instalação.
final deviceIdProvider = FutureProvider<String>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  const key = 'device_id_uuid';
  
  if (prefs.containsKey(key)) {
    return prefs.getString(key)!;
  }

  // Gera um UUID único para a instalação
  String generatedId = const Uuid().v4();
  final deviceInfo = DeviceInfoPlugin();
  
  try {
    if (kIsWeb) {
      final webInfo = await deviceInfo.webBrowserInfo;
      generatedId = 'web_${webInfo.vendor}_$generatedId';
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      generatedId = 'android_${androidInfo.model}_$generatedId';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      generatedId = 'ios_${iosInfo.identifierForVendor}_$generatedId';
    }
  } catch (e) {
    // Falha em pegar info do device_info_plus, usa só o UUID
    generatedId = 'unknown_$generatedId';
  }

  // Limpa espaços ou caracteres inválidos por segurança
  generatedId = generatedId.replaceAll(RegExp(r'\s+'), '_');

  await prefs.setString(key, generatedId);
  return generatedId;
});