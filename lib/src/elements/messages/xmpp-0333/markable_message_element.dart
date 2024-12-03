import '../../XmppAttribute.dart';
import '../../XmppElement.dart';

class MarkableMessageElement extends XmppElement {
  static String elementName = 'markable';

  MarkableMessageElement() {
    name = elementName;
  }

  MarkableMessageElement.build() {
    name = elementName;
    addAttribute(XmppAttribute('xmlns', 'urn:xmpp:chat-markers:0'));
  }

  static XmppElement? parse(parent) {
    return parent.children.firstWhere(
        (child) => (child.name == MarkableMessageElement.elementName),
        orElse: () => null);
  }
}
