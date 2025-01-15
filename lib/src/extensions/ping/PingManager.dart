import 'package:xmpp_stone/src/data/Jid.dart';
import 'package:xmpp_stone/src/elements/XmppAttribute.dart';
import 'package:xmpp_stone/src/elements/XmppElement.dart';
import 'package:xmpp_stone/src/elements/stanzas/AbstractStanza.dart';
import 'package:xmpp_stone/src/elements/stanzas/IqStanza.dart';
import 'package:xmpp_stone/src/Connection.dart';
import 'package:xmpp_stone/src/extensions/ping/PingListener.dart';

class PingManager {
  final Connection _connection;

  PingListener? listener;

  static final Map<Connection, PingManager> _instances =
      <Connection, PingManager>{};

  PingManager(this._connection) {
    _connection.connectionStateStream.listen(_connectionStateProcessor);
    _connection.inStanzasStream.listen(_processStanza);
  }

  static PingManager getInstance(Connection connection) {
    var manager = _instances[connection];
    if (manager == null) {
      manager = PingManager(connection);
      _instances[connection] = manager;
    }
    return manager;
  }

  void _connectionStateProcessor(XmppConnectionState event) {
    // connection state processor.
  }

  void _processStanza(AbstractStanza? stanza) async {
    if (stanza is IqStanza) {
      if (stanza.type == IqStanzaType.GET) {
        var ping = stanza.getChild('ping');
        if (ping != null) {
          var iqStanza = IqStanza(stanza.id, IqStanzaType.RESULT);
          iqStanza.fromJid = _connection.fullJid;
          iqStanza.toJid = stanza.fromJid;
          await _connection.writeStanzaWithQueue(iqStanza);

          if (listener != null) {
            listener!.onPing(stanza);
          }
        }
      } else if (stanza.type == IqStanzaType.ERROR) {
        //todo handle error cases
      }
    }
  }

  Future sendPingMessage() async {
    var iqStanza = IqStanza(AbstractStanza.getRandomId(), IqStanzaType.GET)
      ..fromJid = _connection.fullJid
      ..toJid = Jid.fromFullJid(_connection.fullJid.domain ?? '')
      ..addChild(XmppElement()
        ..name = 'ping'
        ..addAttribute(
            XmppAttribute('xmlns', 'urn:xmpp:ping')));
    await _connection.writeStanzaWithQueue(iqStanza);
  }

  void listen(PingListener _listener) {
    if (listener != null) {
      listener = null;
    }
    listener = _listener;
  }
}
