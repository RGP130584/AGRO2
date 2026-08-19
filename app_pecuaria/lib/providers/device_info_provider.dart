import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fornece um identificador único do dispositivo para fins de auditoria.
/// Conforme a regra de governança "Audit Trail Completo".
final deviceIdProvider = FutureProvider<String>((ref) async {
  final deviceInfo = DeviceInfoPlugin();
  try {
    if (kIsWeb) {
      final webInfo = await deviceInfo.webBrowserInfo;
      return webInfo.vendor ?? webInfo.userAgent ?? 'web_device';
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id; // Um ID único para a instalação do app no Android
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'ios_device';
    }
  } catch (e) {
    // Em caso de erro, retorna um fallback para não quebrar a operação.
    return 'unknown_device_error';
  }
  return 'unknown_platform';
});