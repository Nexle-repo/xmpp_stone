import '../../XmppAttribute.dart';
import '../../XmppElement.dart';

class DisplayedMessageElement extends XmppElement {
  static String elementName = 'displayed';

  DisplayedMessageElement() {
    name = elementName;
  }

  DisplayedMessageElement.build(String id) {
    name = elementName;
    addAttribute(XmppAttribute('xmlns', 'urn:xmpp:chat-markers:0'));
    addAttribute(XmppAttribute('id', 'id'));
  }

  static XmppElement? parse(parent) {
    return parent.children.firstWhere(
        (child) => (child.name == DisplayedMessageElement.elementName),
        orElse: () => null);
  }
}
