import 'dart:async';

import 'package:universal_io/io.dart';

XmppWebSocket createSocket() {
  throw UnsupportedError('No implementation of the connect api provided');
}

abstract class XmppWebSocket extends Stream<String> {
  Future<XmppWebSocket> connect<S>(
    String host,
    int port, {
    String Function(String event)? map,
    List<String>? wsProtocols,
    String? wsPath,
    String? customScheme,
  });

  void write(Object? message);

  void close();

  Future<SecureSocket?> secure(
      {host,
      SecurityContext? context,
      bool Function(X509Certificate certificate)? onBadCertificate,
      List<String>? supportedProtocols});

  String getStreamOpeningElement(String domain);
}
