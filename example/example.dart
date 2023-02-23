import 'dart:async';
import 'dart:convert';

import 'package:console/console.dart';
import 'package:universal_io/io.dart';
import 'package:xmpp_stone/src/logger/Log.dart';
import 'package:xmpp_stone/xmpp_stone.dart';

final String TAG = 'example';

void main(List<String> arguments) {
  Log.logLevel = LogLevel.DEBUG;
  Log.logXmpp = false;
  Log.d(TAG, 'Type user@domain:');
  var userAtDomain = 'rhp#testing_12@dev24.nexlesoft.com';
  Log.d(TAG, 'Type password');
  var password = '1111';
  var jid = Jid.fromFullJid(userAtDomain);
  var account = XmppAccountSettings(
    userAtDomain,
    jid.local,
    jid.domain,
    password,
    18899,
    resource: 'xmppstone',
    wsPath: 'xmpp-websocket',
    wsProtocols: ['xmpp'],
  );
  var manager = XMPPClientManager(
    userAtDomain,
    password,
    port: 18899,
    resource: 'xmppstone',
    wsPath: 'xmpp-websocket',
    wsProtocols: ['xmpp'],
    onReady: (XMPPClientManager context) {
      context.listens();
      context.presenceSend(PresenceShowElement.CHAT, description: 'Working');
    },
    onLog: (String time, String message) {
      print('[onLog]: $message');
    },
    onMessage: (XMPPMessageParams message, ListenerType listenerType) async {
      print('[recieved message]: ${message.message!.body} ---- ${message.message?.getBodyCarbon()} - [TYPE]: $listenerType');
      print('${listenerType.toString()}');
    },
    onPresence: (PresenceData presenceData) async {
      if (presenceData.presenceStanza != null) {
        print('[presenceData] ${presenceData.presenceStanza?.buildXmlString()}');
      }
    },
    onRosterList: (buddies) {
      print("[onRosterList] ${buddies.length}");
    },
    onArchiveRetrieved: (msg) {
      print("[onArchiveRetrieved] $msg");
    },
    onPresenceSubscription: (SubscriptionEvent subscriptionEvent) async {
      print("[onPresenceSubscription] $subscriptionEvent");
    },
    onPing: () async {},
    // onArchiveRetrieved: (AbstractStanza stanza) {
    //     log('Flutter dart finishing retrieval of archive : ${stanza.buildXmlString()})');
    // },
    onState: (XmppConnectionState state) {
      print('[XmppConnectionState] $state');
      // print('status of ${this.name} ' + state.toString());
    },
  );
  manager.createSession();
  /*
  var connection = Connection(account);
  connection.connect();
  connection.inStanzasStream.listen((event) async {
    final stanza = event is MessageStanza ? event as MessageStanza? : null;
    Log.d(TAG, 'inStanzasStream: ${event?.buildXmlString()} ---- ${stanza
        ?.buildXmlString()}');
  });
  MessagesListener messagesListener = ExampleMessagesListener();
  ExampleConnectionStateChangedListener(connection, messagesListener);
  var presenceManager = PresenceManager.getInstance(connection);
  presenceManager.subscriptionStream.listen((streamEvent) {
    if (streamEvent.type == SubscriptionEventType.REQUEST) {
      Log.d(TAG, 'Accepting presence request');
      presenceManager.acceptSubscription(streamEvent.jid);
    }
  });
  var receiver = 'rhp#testing_11@dev24.nexlesoft.com';
  var receiverJid = Jid.fromFullJid(receiver);
  var messageHandler = MessageHandler.getInstance(connection);
  _getConsoleStream().asBroadcastStream().listen((String str) {
    messageHandler.sendMessage(receiverJid, str);
  });

   */
}

class ExampleConnectionStateChangedListener
    implements ConnectionStateChangedListener {
  final Connection _connection;
  final MessagesListener _messagesListener;

  ExampleConnectionStateChangedListener(
    this._connection,
    this._messagesListener,
  ) {
    _connection.connectionStateStream.listen(onConnectionStateChanged);
  }

  @override
  void onConnectionStateChanged(XmppConnectionState state) {
    if (state == XmppConnectionState.Ready) {
      Log.d(TAG, 'Connected');
      var presenceManager = PresenceManager.getInstance(_connection);
      presenceManager.presenceStream.listen(_onPresence);
    }
  }

  void _onPresence(PresenceData event) {
    Log.d(
      TAG,
      'presence Event from ${event.jid!.fullJid} PRESENCE: ${event.showElement}',
    );
  }
}

Stream<String> _getConsoleStream() {
  return Console.adapter.byteStream().map((bytes) {
    var str = ascii.decode(bytes);
    str = str.substring(0, str.length - 1);
    return str;
  });
}

class ExampleMessagesListener implements MessagesListener {
  @override
  void onNewMessage(MessageStanza? message) {
    if (message?.body == null) return;
    Log.d(
      TAG,
      format(
          'New Message from {color.blue}${message?.fromJid?.userAtDomain}{color.end} message: {color.red}${message?.body}{color.end}'),
    );
  }
}
