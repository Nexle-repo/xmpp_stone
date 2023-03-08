import 'package:xmpp_stone/src/elements/messages/xmpp_0422/ExternalElement.dart';
import 'package:xmpp_stone/src/elements/messages/xmpp_0422/PinnedElement.dart';
import 'package:xmpp_stone/src/elements/messages/xmpp_0422/QuoteElement.dart';
import 'package:xmpp_stone/src/extensions/external/ExternalInterface.dart';
import 'package:xmpp_stone/src/extensions/quote_message/QuoteMessageInterface.dart';

import '../../../extensions/muc_info_data/MUCInfoDataInterface.dart';
import '../../../extensions/pin_message/PinMessageInterface.dart';
import '../../XmppAttribute.dart';
import '../../XmppElement.dart';
import 'MUCInfoElement.dart';

class ApplyToElement extends XmppElement
    implements
        MUCInfoDataInterface,
        PinMessageInterface,
        ExternalInterface,
        QuoteMessageInterface {
  static String elementName = 'apply-to';
  ApplyToElement() {
    name = elementName;
  }

  ApplyToElement.buildMUCInfo({
    String? subjectChanged,
    String? coverUrlChanged,
  }) {
    name = ApplyToElement.elementName;
    addAttribute(XmppAttribute('xmlns', 'urn:xmpp:fasten:0'));
    addMUCInfo(
      subjectChanged: subjectChanged,
      coverUrlChanged: coverUrlChanged,
    );
  }

  ApplyToElement.buildPinMessage(String id, bool isPinned) {
    name = ApplyToElement.elementName;
    addAttribute(XmppAttribute('xmlns', 'urn:xmpp:fasten:0'));
    addAttribute(XmppAttribute('id', id));
    addPinMessage(isPinned);
  }

  ApplyToElement.buildQuoteMessage(String id, String userId, String username) {
    name = ApplyToElement.elementName;
    addExternalName("body");
    addQuoteMessage();
    addAttribute(XmppAttribute('xmlns', 'urn:xmpp:fasten:0'));
    addAttribute(XmppAttribute('id', id));
    addAttribute(XmppAttribute('userId', userId));
    addAttribute(XmppAttribute('username', username));
  }

  static XmppElement? parse(parent) {
    return parent.children.firstWhere(
        (child) => (child.name == ApplyToElement.elementName),
        orElse: () => null);
  }

  @override
  PinMessageInterface addPinMessage(bool isPinned) {
    addChild(PinnedElement.build(isPinned));
    return this;
  }

  @override
  XmppElement? getPinMessage() {
    // TODO: implement getPinMessage
    throw UnimplementedError();
  }

  @override
  QuoteMessageInterface addQuoteMessage() {
    addChild(QuoteElement.build());
    return this;
  }

  @override
  XmppElement? getQuoteMessage() {
    // TODO: implement getQuoteMessage
    throw UnimplementedError();
  }

  @override
  ExternalInterface addExternalName(String name) {
    addChild(ExternalElement.build(name));
    return this;
  }

  @override
  XmppElement? getExternalName() {
    // TODO: implement getExternalName
    throw UnimplementedError();
  }

  @override
  MUCInfoDataInterface addMUCInfo({
    String? subjectChanged,
    String? coverUrlChanged,
  }) {
    addChild(MUCInfoElement.build(
        subjectChanged: subjectChanged, coverUrlChanged: coverUrlChanged));
    return this;
  }

  @override
  XmppElement? getMUCInfo() {
    // TODO: implement getMUCInfoMessage
    throw UnimplementedError();
  }
}
