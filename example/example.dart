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
  var userAtDomain = 'rhp#testing_30@dev24.nexlesoft.com';
  Log.d(TAG, 'Type password');
  var password = 'Aa123456@';
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
  var connection = Connection(account);
  connection.connect();
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
      var vCardManager = VCardManager(_connection);
      vCardManager.getSelfVCard().then((vCard) {
        Log.d(TAG, 'Your info ${vCard.buildXmlString()}');
      });
      var messageHandler = MessageHandler.getInstance(_connection);
      var rosterManager = RosterManager.getInstance(_connection);
      messageHandler.messagesStream.listen(_messagesListener.onNewMessage);
      sleep(const Duration(seconds: 1));
      var receiver = 'rhp#testing_11@dev24.nexlesoft.com';
      var receiverJid = Jid.fromFullJid(receiver);
      rosterManager.addRosterItem(Buddy(receiverJid)).then((result) {
        if (result.description != null) {
          Log.d(TAG, 'add roster ${result.description}');
        }
      });
      sleep(const Duration(seconds: 1));
      vCardManager.getVCardFor(receiverJid).then((vCard) {
        Log.d(TAG, 'Receiver info ${vCard.buildXmlString()}');
      });
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
