import 'dart:async';

import 'package:xmpp_stone/src/Connection.dart';
import 'package:xmpp_stone/src/chat/Message.dart';
import 'package:xmpp_stone/src/data/Jid.dart';
import 'package:xmpp_stone/src/elements/XmppAttribute.dart';
import 'package:xmpp_stone/src/elements/XmppElement.dart';
import 'package:xmpp_stone/src/elements/stanzas/AbstractStanza.dart';
import 'package:xmpp_stone/src/elements/stanzas/MessageStanza.dart';

class ChatImpl implements Chat {
  static String TAG = 'Chat';

  final Connection _connection;
  final Jid _jid;

  @override
  Jid get jid => _jid;
  ChatState? _myState;
  @override
  ChatState? get myState => _myState;

  ChatState? _remoteState;
  @override
  ChatState? get remoteState => _remoteState;

  @override
  List<Message>? messages = [];

  final StreamController<Message> _newMessageController =
      StreamController.broadcast();
  final StreamController<ChatState?> _remoteStateController =
      StreamController.broadcast();

  @override
  Stream<Message> get newMessageStream => _newMessageController.stream;
  @override
  Stream<ChatState?> get remoteStateStream => _remoteStateController.stream;

  ChatImpl(this._jid, this._connection);

  void parseMessage(Message message) {
    if (message.type == MessageStanzaType.CHAT) {
      if (message.text != null && message.text!.isNotEmpty) {
        messages!.add(message);
        _newMessageController.add(message);
      }

      if (message.chatState != null && !(message.isDelayed??false)) {
        _remoteState = message.chatState;
        _remoteStateController.add(message.chatState);
      }
    }
  }

  @override
  void sendMessage(String text) {
    var stanza =
        MessageStanza(AbstractStanza.getRandomId(), MessageStanzaType.CHAT);
    stanza.toJid = _jid;
    stanza.fromJid = _connection.fullJid;
    stanza.body = text;
    var message = Message.fromStanza(stanza);
    messages!.add(message);
    _newMessageController.add(message);
    _connection.writeStanza(stanza);
  }

  @override
  set myState(ChatState? state) {
    var stanza =
        MessageStanza(AbstractStanza.getRandomId(), MessageStanzaType.CHAT);
    stanza.toJid = _jid;
    stanza.fromJid = _connection.fullJid;
    var stateElement = XmppElement();
    stateElement.name = state.toString().split('.').last.toLowerCase();
    stateElement.addAttribute(
        XmppAttribute('xmlns', 'http://jabber.org/protocol/chatstates'));
    stanza.addChild(stateElement);
    _connection.writeStanza(stanza);
    _myState = state;
  }
}

abstract class Chat {
  Jid get jid;
  ChatState? get myState;
  ChatState? get remoteState;
  Stream<Message> get newMessageStream;
  Stream<ChatState?> get remoteStateStream;
  List<Message>? messages;
  void sendMessage(String text);
  set myState(ChatState? state);
}

enum ChatState {
  NONE(-1,''),
  GONE(0,'离开'),
  PRESENCE(1,'出席'),
  COMPOSING(2,'正在输入...'),
  GIF(3,'正在选择gif...'),
  STICKER(4,'正在选择贴纸...'),//选择贴纸
  EMOJI(5,'正在选择表情...'),//选择表情
  SPEAKING(6,'正在讲话...');//正在讲话
  final int code;
  final String desc;
  const ChatState(this.code,this.desc);
  static ChatState getByCode(int code){
    for(var i=0;i<ChatState.values.length;i++){
      if(ChatState.values[i].code==code){
        return ChatState.values[i];
      }
    }
    return ChatState.NONE;
  }
}