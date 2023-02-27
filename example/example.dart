import 'dart:async';
import 'dart:convert';

import 'package:console/console.dart';
import 'package:universal_io/io.dart';
import 'package:xmpp_stone/src/logger/Log.dart';
import 'package:xmpp_stone/xmpp_stone.dart';

final String TAG = 'example';

void main(List<String> arguments) {
  Log.logLevel = LogLevel.DEBUG;
  Log.logXmpp = true;
  Log.d(TAG, 'Type user@domain:');
  var userAtDomain = 'rhp#testing_31@dev24.nexlesoft.com';
  Log.d(TAG, 'Type password');
  var password = 'Aa123456@';

  var manager = XMPPClientManager(
    userAtDomain,
    password,
    port: 18899,
    resource: 'xmppstone',
    wsPath: 'xmpp-websocket',
    wsProtocols: ['xmpp'],
    onReady: (XMPPClientManager context) {
      context.listens();
      // context.presenceSend(PresenceShowElement.CHAT, description: 'Working');
    },
    onLog: (String time, String message) {
    },
    onMessage: (XMPPMessageParams message, ListenerType listenerType) async {
    },
    onPresence: (PresenceData presenceData) async {
    },
    onRosterList: (buddies) {
    },
    onArchiveRetrieved: (msg) {
    },
    onPresenceSubscription: (SubscriptionEvent subscriptionEvent) async {
    },
    onPing: () async {},
    // onArchiveRetrieved: (AbstractStanza stanza) {
    //     log('Flutter dart finishing retrieval of archive : ${stanza.buildXmlString()})');
    // },
    onState: (XmppConnectionState state) {
      // print('status of ${this.name} ' + state.toString());
    },
  );
  manager.createSession();
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
