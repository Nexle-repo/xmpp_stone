import '../../XmppAttribute.dart';
import '../../XmppElement.dart';

class ReadMessageElement extends XmppElement {
  static String elementName = 'read';

  ReadMessageElement() {
    name = elementName;
  }

  ReadMessageElement.build(String userId) {
    name = elementName;
    addAttribute(XmppAttribute('xmlns', 'rhp:urn:xmpp:$elementName'));
    textValue = userId;
  }

  static XmppElement? parse(parent) {
    return parent.children.firstWhere(
        (child) => (child.name == ReadMessageElement.elementName),
        orElse: () => null);
  }
}
