import 'package:xmpp_stone/xmpp_stone.dart';

import '../../XmppAttribute.dart';

class NoCopyElement extends XmppElement {
  static String elementName = 'no-copy';
  NoCopyElement() {
    name = elementName;
  }

  NoCopyElement.build() {
    name = elementName;
    addAttribute(XmppAttribute('xmlns', 'urn:xmpp:hints'));
  }

  static XmppElement? parse(parent) {
    return parent.children.firstWhere(
            (child) => (child.name == NoCopyElement.elementName),
        orElse: () => null);
  }

  static MessageStanza? parseForMessage(parent) {
    XmppElement? parentXmpp = parse(parent)!;
    if (parentXmpp != null) {
      return parentXmpp.children.firstWhere((child) => (child is MessageStanza),
          orElse: () => null) as MessageStanza;
    } else {
      return null;
    }
  }
}
