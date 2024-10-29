import '../../XmppAttribute.dart';
import '../../XmppElement.dart';

class RecalledElement extends XmppElement {
  static String elementName = 'retract';
  RecalledElement() {
    name = elementName;
  }

  RecalledElement.build(String fromUserId, String listId) {
    name = RecalledElement.elementName;
    addAttribute(XmppAttribute('xmlns', 'urn:xmpp:message-retract:0'));
    addAttribute(XmppAttribute('from', fromUserId));
    textValue = listId;
  }

  static XmppElement? parse(parent) {
    return parent.children.firstWhere(
        (child) => (child.name == RecalledElement.elementName),
        orElse: () => null);
  }
}
