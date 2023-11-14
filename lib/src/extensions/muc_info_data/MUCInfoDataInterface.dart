import 'package:xmpp_stone/xmpp_stone.dart';

/// Inspired by this XEP-0422: https://xmpp.org/extensions/xep-0422.html

abstract class MUCInfoDataInterface {
  MUCInfoDataInterface addMUCInfo({
    String? subjectChanged,
    String? coverUrlChanged,
    String? membersAddedEncoded,
    String? membersRemovedEncoded,
    bool? isMuted,
    bool? isMarkRead,
    bool? isMarkUnRead,
  });

  XmppElement? getMUCInfo();
}
