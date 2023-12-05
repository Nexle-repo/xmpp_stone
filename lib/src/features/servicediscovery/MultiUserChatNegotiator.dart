import 'dart:async';

import 'package:xmpp_stone/src/elements/nonzas/Nonza.dart';

import '../../../xmpp_stone.dart';
import '../Negotiator.dart';
import 'Feature.dart';

class MultiUserChatNegotiator extends Negotiator {
  static const TAG = 'MultiUserChatNegotiator';

  static final Map<Connection?, MultiUserChatNegotiator> _instances =
      <Connection?, MultiUserChatNegotiator>{};

  static MultiUserChatNegotiator getInstance(Connection? connection) {
    var instance = _instances[connection];
    if (instance == null) {
      instance = MultiUserChatNegotiator(connection);
      _instances[connection] = instance;
    }
    return instance;
  }

  final Connection? _connection;

  bool enabled = false;

  late StreamSubscription<AbstractStanza?> _subscription;
  late IqStanza _myUnrespondedIqStanza;

  MultiUserChatNegotiator(this._connection) {
    expectedName = 'http://jabber.org/protocol/muc';
  }

  @override
  List<Nonza> match(List<Nonza> requests) {
    return (requests.where((element) =>
        element is Feature &&
        ((element).xmppVar == expectedName))).toList();
  }

  @override
  void negotiate(List<Nonza> nonzas) {
    if (match(nonzas).isNotEmpty) {
      state = NegotiatorState.NEGOTIATING;
      sendInquiry();
      _subscription = _connection!.inStanzasStream.listen(checkStanzas);
    }
  }

  @override
  void discover() {
    sendInquiry();
    _subscription = _connection!.inStanzasStream.listen(checkStanzas);
  }

  void sendInquiry() {
    var iqStanza = IqStanza(AbstractStanza.getRandomId(), IqStanzaType.GET);
    iqStanza.addAttribute(
        XmppAttribute('from', _connection!.account.fullJid.userAtDomain));
    iqStanza
        .addAttribute(XmppAttribute('to', _connection!.account.fullJid.domain));
    // IF you want to get specific room info
    // iqStanza
    //     .addAttribute(XmppAttribute('to', _connection!.account.mucDomain));
    var element = XmppElement();
    element.name = 'query';
    element.addAttribute(
        XmppAttribute('xmlns', 'http://jabber.org/protocol/disco#items'));
    iqStanza.addChild(element);
    _myUnrespondedIqStanza = iqStanza;
    _connection!.writeStanza(iqStanza);
  }

  void checkStanzas(AbstractStanza? stanza) {
    if (stanza is IqStanza && stanza.id == _myUnrespondedIqStanza.id) {
      enabled = stanza.type == IqStanzaType.RESULT;
      state = NegotiatorState.DONE;
      _subscription.cancel();
    }
  }
}
