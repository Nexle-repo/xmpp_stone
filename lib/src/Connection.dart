import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:synchronized/synchronized.dart';
import 'package:xml/xml.dart' as xml;
import 'package:xmpp_stone/src/ReconnectionManager.dart';
import 'package:xmpp_stone/src/account/XmppAccountSettings.dart';
import 'package:xmpp_stone/src/data/Jid.dart';
import 'package:xmpp_stone/src/elements/nonzas/Nonza.dart';
import 'package:xmpp_stone/src/elements/stanzas/AbstractStanza.dart';
import 'package:xmpp_stone/src/exception/XmppException.dart';
import 'package:xmpp_stone/src/extensions/ping/PingManager.dart';
import 'package:xmpp_stone/src/features/ConnectionNegotiationManager.dart';
import 'package:xmpp_stone/src/features/error/ConnectionStreamErrorHandler.dart';
import 'package:xmpp_stone/src/features/queue/ConnectionExecutionQueue.dart';
import 'package:xmpp_stone/src/features/queue/ConnectionWriteQueue.dart';
import 'package:xmpp_stone/src/features/streammanagement/StreamManagementModule.dart';
import 'package:xmpp_stone/src/logger/Log.dart';
import 'package:xmpp_stone/src/messages/MessageHandler.dart';
import 'package:xmpp_stone/src/parser/StanzaParser.dart';
import 'package:xmpp_stone/src/presence/PresenceManager.dart';
import 'package:xmpp_stone/src/response/BaseResponse.dart';
import 'package:xmpp_stone/src/response/Response.dart';
import 'package:xmpp_stone/src/roster/RosterManager.dart';
import 'package:xmpp_stone/src/utils/Random.dart';

import 'connection/XmppWebSocketIo.dart' as xmppSocket;

enum XmppConnectionState {
  Idle,
  Closed,
  SocketOpening,
  SocketOpened,
  DoneParsingFeatures,
  AuthenticationNotSupported,
  StartTlsFailed,
  PlainAuthentication,
  Authenticating,
  Authenticated,
  AuthenticationFailure,
  Resumed,
  SessionInitialized,
  Ready,
  StreamConflict,
  Closing,
  ForcefullyClosed,
  Reconnecting,
  WouldLikeToOpen,
  WouldLikeToClose,
}

class Connection {
  var lock = Lock(reentrant: true);

  static String TAG = 'XmppStone/Connection';

  static Map<String?, Connection> instances = <String?, Connection>{};

  XmppAccountSettings account;

  late StreamManagementModule streamManagementModule;

  Jid get serverName {
    if (_serverName != null) {
      return Jid.fromFullJid(_serverName!);
    } else {
      return Jid.fromFullJid(fullJid.domain!); //todo move to account.domain!
    }
  } //move this somewhere

  late String connectionId;

  String? _serverName;

  static Connection getInstance(XmppAccountSettings account) {
    var connection = instances[account.fullJid.userAtDomain];
    if (connection == null) {
      connection = Connection(account);
      instances[account.fullJid.userAtDomain] = connection;
    }
    return connection;
  }

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  set errorMessage(String? value) {
    _errorMessage = value;
  }

  bool authenticated = false;

  final StreamController<AbstractStanza?> _inStanzaStreamController =
      StreamController.broadcast();

  final StreamController<AbstractStanza> _outStanzaStreamController =
      StreamController.broadcast();

  final StreamController<Nonza> _inNonzaStreamController =
      StreamController.broadcast();

  final StreamController<Nonza> _outNonzaStreamController =
      StreamController.broadcast();

  final StreamController<XmppConnectionState> _connectionStateStreamController =
      StreamController.broadcast();

  final StreamController<BaseResponse> _responseStreamController =
      StreamController.broadcast();

  Stream<AbstractStanza?> get inStanzasStream {
    return _inStanzaStreamController.stream;
  }

  Stream<Nonza> get inNonzasStream {
    return _inNonzaStreamController.stream;
  }

  Stream<Nonza> get outNonzasStream {
    return _outNonzaStreamController.stream;
  }

  Stream<AbstractStanza> get outStanzasStream {
    return _outStanzaStreamController.stream;
  }

  Stream<XmppConnectionState> get connectionStateStream {
    return _connectionStateStreamController.stream;
  }

  Stream<BaseResponse> get responseStream {
    return _responseStreamController.stream;
  }

  Jid get fullJid => account.fullJid;

  late ConnectionNegotiationManager connectionNegotiationManager;
  late ConnectionExecutionQueue connExecutionQueue;
  late ConnectionWriteQueue connWriteQueue;
  ConnectionStreamErrorHandler? connectionStreamErrorHandler;

  fullJidRetrieved(Jid jid) {
    account.resource = jid.resource;
  }

  xmppSocket.XmppWebSocket? _socket;

  // for testing purpose
  set socket(xmppSocket.XmppWebSocket? value) {
    _socket = value;
  }

  StreamSubscription? _socketSubscription;
  StreamSubscription? _secureSocketSubscription;

  XmppConnectionState _state = XmppConnectionState.Idle;

  ReconnectionManager? reconnectionManager;

  bool isForcedClose = false;

  Connection(this.account) {
    RosterManager.getInstance(this);
    PresenceManager.getInstance(this);
    MessageHandler.getInstance(this);
    PingManager.getInstance(this);
    connectionNegotiationManager = ConnectionNegotiationManager(this, account);
    reconnectionManager = ReconnectionManager(this);
    connExecutionQueue = ConnectionExecutionQueue(this);
    connWriteQueue = ConnectionWriteQueue(this, _outStanzaStreamController);

    connectionId = generateId();
    // Assign configured timeout
    ResponseHandler.responseTimeoutMs = account.responseTimeoutMs;
    ResponseHandler.setResponseStream(_responseStreamController);
    ConnectionWriteQueue.idealWriteIntervalMs = account.writeQueueMs;
    Log.v(this.toString(), 'Create new connection instance');
  }

  @override
  String toString() {
    return '$TAG/$connectionId';
  }

  _openStream() {
    var streamOpeningString = """
<?xml version='1.0'?>
<stream:stream xmlns='jabber:client' version='1.0' xmlns:stream='http://etherx.jabber.org/streams'
to='${fullJid.domain}'
xml:lang='en'
>
""";
    write(streamOpeningString);
  }

  String restOfResponse = '';

  String extractWholeChild(String response) {
    return response;
  }

  String prepareStreamResponse(String response) {
    Log.xmppReceiving(response);
    var response1 = extractWholeChild(restOfResponse + response);
    if (response1.contains('</stream:stream>')) {
      close();
      return '';
    }
    if (response1.contains('stream:stream') &&
        !(response1.contains('</stream:stream>'))) {
      response1 = response1 +
          '</stream:stream>'; // fix for crashing xml library without ending
    }

    //fix for multiple roots issue
    response1 = '<xmpp_stone>$response1</xmpp_stone>';
    return response1;
  }

  reconnect() {
    if (!isOpened()) {
      // Prevent open socket run too many times
      connExecutionQueue.put(ConnectionExecutionQueueContent(
          openSocket, true, {}, 'openSocket',
          expectedState: XmppConnectionState.Ready));
      connExecutionQueue.resume();
    }
  }
  //连接
  connect() {
    isForcedClose = false;
    if (_state == XmppConnectionState.Closing) {
      _state = XmppConnectionState.WouldLikeToOpen;
    }
    if (_state == XmppConnectionState.Closed) {
      _state = XmppConnectionState.Idle;
    }
    if (_state == XmppConnectionState.Idle) {
      // Prevent open socket run too many times
      connExecutionQueue.put(ConnectionExecutionQueueContent(
          openSocket, true, {}, 'openSocket',
          expectedState: XmppConnectionState.Ready));
      connExecutionQueue.resume();
    }
  }
  //打开
  openSocket() async {
    if (isForcedClose) return;
    connectionNegotiationManager.init();
    if (_state == XmppConnectionState.SocketOpening) {
      return;
    }
    setState(XmppConnectionState.SocketOpening);
    try {
      // if not closed in meantime
      if (_state != XmppConnectionState.Closed) {
        _socket = xmppSocket.createSocket();
        connectionStreamErrorHandler = ConnectionStreamErrorHandler.init(this);
        setState(XmppConnectionState.SocketOpened);
        await _socket?.connect(
          account.host ?? account.domain ?? '',
          account.port,
          wsProtocols: account.wsProtocols,
          wsPath: account.wsPath,
          map: prepareStreamResponse,
          customScheme: account.customScheme,
        ).then((socket) {
            if (_state != XmppConnectionState.Closed) {
              setState(XmppConnectionState.SocketOpened);
              _socket = socket;
              _socketSubscription = socket.listen(
                  handleResponse,
                  onError: (e,stackTrace){
                    Log.d(TAG, 'error : $e,$stackTrace');
                  },
                  onDone: (){
                    handleConnectionDone();
                  }
              );
              _openStream();
            } else {
              Log.d(TAG, 'Closed in meantime');
              socket.close();
            }
          },
          onError: (error, _) => handleConnectionError(error.toString()),
        );
      } else {
        print(_state);
        Log.d(this.toString(), 'Closed in meantime');
        writeClose(_socket);
      }
    } on SocketException catch (error) {
      Log.e(this.toString(), 'Socket Exception' + error.toString());
      handleConnectionError(error.toString());
    } catch (e) {
      Log.e(this.toString(), 'Exception in open socket' + e.toString());
      handleConnectionError(e.toString());
      ;
    }
  }
  //加密连接
  startSecureSocket() {
    Log.d(TAG, 'startSecureSocket');
    _socket?.secure(
      context: SecurityContext()
        ..useCertificateChainBytes(utf8.encode(account.publicKey??''))
        ..usePrivateKeyBytes(utf8.encode(account.privateKey??'')),
      onBadCertificate: _validateBadCertificate
    ).then((secureSocket) {
      if (secureSocket == null) return;

      _socketSubscription?.cancel();
      _secureSocketSubscription = secureSocket.cast<List<int>>().transform(utf8.decoder).map(prepareStreamResponse).listen(
        handleResponse,
        onError: (error) => {
          handleSecuredConnectionError(error.toString()),
        },
        onDone: handleSecuredConnectionDone,
      );
      _openStream();
    });
  }
  //强制关闭
  forceClose() {
    isForcedClose = true;
    connExecutionQueue.clear();
    setState(XmppConnectionState.WouldLikeToClose);
    _close();
  }
  //关闭连接
  close() async {
    // Prevent open socket run too many times
    connExecutionQueue.put(ConnectionExecutionQueueContent(
        _close, true, {}, '_close',
        expectedState: XmppConnectionState.Closed));
    connExecutionQueue.resume();
  }

  _close() async {
    _cleanSubscription();
    if (_state == XmppConnectionState.SocketOpening) {
      throw Exception('Closing is not possible during this state');
    } else {
      if (_state == XmppConnectionState.StreamConflict ||
          (_state != XmppConnectionState.Closed &&
              _state != XmppConnectionState.ForcefullyClosed &&
              _state != XmppConnectionState.Closing)) {
        // Close socket and re-open
        connectionNegotiationManager.cleanNegotiators();
        setState(XmppConnectionState.Closing);
        if (_socket != null) {
          writeClose(_socket);
        }
        _socket = null;
        authenticated = false;
      }
    }
  }

  //清空订阅
  _cleanSubscription() {
    if (_secureSocketSubscription != null) {
      _secureSocketSubscription!.cancel();
      _secureSocketSubscription = null;
    }
    if (_socketSubscription != null) {
      _socketSubscription!.cancel();
      _socketSubscription = null;
    }
  }

  bool startMatcher(xml.XmlElement element) {
    var name = element.name.local;
    return name == 'stream';
  }

  bool stanzaMatcher(xml.XmlElement element) {
    var name = element.name.local;
    return name == 'iq' || name == 'message' || name == 'presence';
  }

  bool nonzaMatcher(xml.XmlElement element) {
    var name = element.name.local;
    return name != 'iq' && name != 'message' && name != 'presence';
  }

  bool featureMatcher(xml.XmlElement element) {
    var name = element.name.local;
    return (name == 'stream:features' || name == 'features');
  }

  String _unparsedXmlResponse = '';

  handleResponse(String response) {
    String fullResponse;
    if (_unparsedXmlResponse.isNotEmpty) {
      if (response.length > 12) {
        fullResponse = '$_unparsedXmlResponse${response.substring(12)}'; //
      } else {
        fullResponse = _unparsedXmlResponse;
      }
      _unparsedXmlResponse = '';
    } else {
      fullResponse = response;
    }

    if (fullResponse.isNotEmpty) {
      xml.XmlNode? xmlResponse;
      Log.d(this.toString(), 'Receiving full response:\n: ${fullResponse}');
      try {
        xmlResponse = xml.XmlDocument.parse(
                fullResponse.replaceAll(RegExp(r'<\?(xml.+?)>'), ''))
            .firstChild;
      } catch (e) {
        _unparsedXmlResponse += fullResponse.substring(
            0, fullResponse.length - 13); //remove  xmpp_stone end tag
        xmlResponse = xml.XmlElement(xml.XmlName('error'));
      }
//      xmlResponse.descendants.whereType<xml.XmlElement>().forEach((element) {
//        Log.d("element: " + element.name.local);
//      });


      //TODO: Probably will introduce bugs!!!
      final inNonza = xmlResponse!.children
          .whereType<xml.XmlElement>()
          .where((element) => nonzaMatcher(element))
          .map((xmlElement) => Nonza.parse(xmlElement));
      inNonza.forEach((nonza) => _inNonzaStreamController.add(nonza));


      // //TODO: Improve parser for children only
      final initialStream = xmlResponse.descendants
          .whereType<xml.XmlElement>()
          .where((element) => startMatcher(element));
      initialStream.forEach((element) => processInitialStream(element));

      final inStanza = xmlResponse.children
          .whereType<xml.XmlElement>()
          .where((element) => stanzaMatcher(element))
          .map((xmlElement) => StanzaParser.parseStanza(xmlElement));
      inStanza.forEach((stanza) => _inStanzaStreamController.add(stanza));

      final featureNegotiate = xmlResponse.descendants
          .whereType<xml.XmlElement>()
          .where((element) => featureMatcher(element));

      featureNegotiate.forEach((feature) =>
          connectionNegotiationManager.negotiateFeatureList(feature));
    }
  }
  //处理初始流
  processInitialStream(xml.XmlElement initialStream) {
    Log.d(this.toString(), 'processInitialStream');
    var from = initialStream.getAttribute('from');
    if (from != null) {
      _serverName = from;
    }
  }
  //xmpp连接打开
  bool isOpened() {
    return _state != XmppConnectionState.Closed &&
        _state != XmppConnectionState.ForcefullyClosed &&
        _state != XmppConnectionState.Closing &&
        _state != XmppConnectionState.SocketOpening;
  }
  //关闭流
  Future writeClose(xmppSocket.XmppWebSocket? socket) async {
    socket?.write('</stream:stream>');
    socket?.close();
  }

  write(message) {
    Log.xmppSending(message);
    try {
      if (isOpened()) {
        Log.d(this.toString(),
            'Writing to stanza/socket[${DateTime.now().toIso8601String()}]:\n${message}');
        _socket!.write(message);
      } else {
        throw FailWriteSocketException();
      }
    } catch (e,stackTrace) {
      close();
      Log.e(this.toString(), 'Write exception $e,$stackTrace');
      throw FailWriteSocketException();
    }
  }


  /// - stanza: AbstractStanza => Stanza in xml structure to write
  writeStanza(AbstractStanza stanza) {
    _outStanzaStreamController.add(stanza);
    write(stanza.buildXmlString());
  }

  Future writeStanzaWithQueue(AbstractStanza stanza) async {
    connWriteQueue
        .put(WriteContent(id: stanza.id ?? "", content: stanza, sent: false));
    await connWriteQueue.resume();
  }

  writeNonza(Nonza nonza) {
    _outNonzaStreamController.add(nonza);
    write(nonza.buildXmlString());
  }

  setState(XmppConnectionState state) {
    _state = state;
    _fireConnectionStateChangedEvent(state);
    _processState(state);
    Log.d(this.toString(), 'State: ${_state}');
  }

  XmppConnectionState get state {
    return _state;
  }

  _processState(XmppConnectionState state) {
    if (state == XmppConnectionState.Authenticated) {
      authenticated = true;
      _openStream();
    }
  }

  processError(xml.XmlDocument xmlResponse) {
    //todo find error stanzas
  }

  fireNewStanzaEvent(AbstractStanza stanza) {
    _inStanzaStreamController.add(stanza);
  }

  _fireConnectionStateChangedEvent(XmppConnectionState state) {
    _connectionStateStreamController.add(state);
  }

  bool elementHasAttribute(xml.XmlElement element, xml.XmlAttribute attribute) {
    var list = element.attributes.firstWhereOrNull((attr) =>
        attr.name.local == attribute.name.local &&
        attr.value == attribute.value);
    return list != null;
  }

  sessionReady() {
    setState(XmppConnectionState.SessionInitialized);
    //now we should send presence
  }

  doneParsingFeatures() {
    if (_state == XmppConnectionState.SessionInitialized) {
      setState(XmppConnectionState.Ready);
    }
  }

  startTlsFailed() {
    setState(XmppConnectionState.StartTlsFailed);
    close();
  }

  handleStreamConflictErrorThrown() {
    if (_state == XmppConnectionState.Closing ||
        _state == XmppConnectionState.StreamConflict) {
      return;
    }
    connectionStreamErrorHandler!.dispose();
    setState(XmppConnectionState.StreamConflict);

    close();
  }

  authenticating() {
    setState(XmppConnectionState.Authenticating);
  }

  bool _validateBadCertificate(X509Certificate certificate) {
    return true;
  }

  handleConnectionDone() {
    Log.d(this.toString(), 'Handle connection done');
    handleCloseState();
  }

  handleSecuredConnectionDone() {
    Log.d(this.toString(), 'Handle secured connection done');
    handleCloseState();
  }

  handleConnectionError(String error) {
    Log.e(this.toString(), 'Handle connection error: $error');
    handleCloseState();
  }

  handleCloseState() {
    if (_state == XmppConnectionState.WouldLikeToOpen) {
      setState(XmppConnectionState.Closed);
      connect();
    } else if (_state != XmppConnectionState.Closing) {
      setState(XmppConnectionState.ForcefullyClosed);
    } else {
      setState(XmppConnectionState.Closed);
    }
  }

  handleSecuredConnectionError(String error) {
    Log.d(this.toString(), 'Handle Secured Error  $error');
    handleCloseState();
  }

  bool isAsyncSocketState() {
    return _state == XmppConnectionState.SocketOpening ||
        _state == XmppConnectionState.Closing;
  }
}
