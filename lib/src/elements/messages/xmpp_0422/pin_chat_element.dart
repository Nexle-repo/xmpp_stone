import '../../XmppAttribute.dart';
import '../../XmppElement.dart';

class PinChatElement extends XmppElement {
  static String elementName = 'pin-chat';
  PinChatElement() {
    name = elementName;
  }

  PinChatElement.build({
    required String chatId,
    required bool pinned,
    required String userPinned,
  }) {
    name = elementName;
    addAttribute(XmppAttribute('xmlns', 'rhp:urn:xmpp:$elementName'));
    addAttribute(XmppAttribute('id', chatId));
    addAttribute(XmppAttribute('pinned', pinned ? '1' : '0'));
    addAttribute(XmppAttribute('userPinned', userPinned));
  }

  static XmppElement? parse(parent) {
    return parent.children.firstWhere(
        (child) => (child.name == PinChatElement.elementName),
        orElse: () => null);
  }
}
