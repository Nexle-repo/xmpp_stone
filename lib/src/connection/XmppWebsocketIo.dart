import 'dart:async';
import 'dart:convert';

import 'package:universal_io/io.dart';
import 'package:xmpp_stone/src/connection/XmppWebsocketApi.dart';

export 'XmppWebsocketApi.dart';

XmppWebSocket createSocket() {
  return XmppWebSocketIo();
}

class XmppWebSocketIo extends XmppWebSocket {
  static String TAG = 'XmppWebSocketIo';
  Socket? _socket;
  SecureSocket? _secureSocket;
  late String Function(String event) _map;

  XmppWebSocketIo();

  @override
  Future<XmppWebSocket> connect<S>(
    String host,
    int port, {
    String Function(String event)? map,
    List<String>? wsProtocols,
    String? wsPath,
    String? customScheme,
  }) async {
    await Socket.connect(host, port).then((Socket socket) {
      _socket = socket;

      if (map != null) {
        _map = map;
      } else {
        _map = (element) => element;
      }
    });

    return Future.value(this);
  }

  @override
  void close() {
    if (_secureSocket != null) {
      _secureSocket!.close();
    } else if (_socket != null) {
      _socket!.close();
    }
  }

  @override
  void write(Object? message){
    try{
      if (_secureSocket != null) {
        // 如果已升级为安全套接字，使用_secureSocket
        _secureSocket!.write(message);
      } else if (_socket != null) {
        // 否则使用原始套接字_socket
        _socket!.write(message);
      }
    }catch(e,st){
      print("出错了：$e,$st");
    }
  }

  @override
  StreamSubscription<String> listen(void Function(String event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    var stream = (_secureSocket ?? _socket)!.cast<List<int>>().transform(utf8.decoder);
    stream = stream.map(_map);

    return stream.listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError);
  }

  @override
  Future<SecureSocket?> secure(
      {host,
      SecurityContext? context,
      bool Function(X509Certificate certificate)? onBadCertificate,
      List<String>? supportedProtocols}) async {
    _secureSocket = await SecureSocket.secure(
        _socket!,
        context: context,
        onBadCertificate: onBadCertificate
    );
    return _secureSocket;
  }

  @override
  String getStreamOpeningElement(String domain) {
    return """<?xml version='1.0'?><stream:stream xmlns='jabber:client' version='1.0' xmlns:stream='http://etherx.jabber.org/streams' to='$domain' xml:lang='en'>""";
  }
}
